Shader "Bansi/ReactiveShieldShader"
{
    Properties
    {    	
        _Color ("Color", Color) = (1,1,1,1)

        [Header(Pulsating hexagon effect)][Space]
        _PulseTex ("Pulse Texture", 2D) = "white" {}
        _PulseIntensity ("Pulse Intensity", float) = 3.0
        _PulseAnimationSpeed ("Pulse Animation Speed", float) = 2.0
        _PulseOffsetTextureImpact ("Pulse Offset Texture Impact", float) = 1.0

        [Header(Pulsating edges effect)]
        _HexEdgeTex ("Hex Edge Texture", 2D) = "white" {}
        _HexEdgeColor ("Hex Edge Color", Color) = (1,1,1,1)
        _HexEdgeIntensity ("Hex Edge Intensity", float) = 2.0
        _HexEdgeAnimationSpeed ("Hex Edge Animation Speed", float) = 2.0
        _HexEdgeDurationMultiplier ("Hex Edge Duration Multiplier", Range(0.0, 1.0)) = 0.8
        _HexEdgePosScale ("Hex Edge Position Scale", float) = 60.0

        [Header(Boarder Gradient)]
        _BorderTex ("Border Texture", 2D) = "white" {}
        _BorderIntensity ("Border Intensity", float) = 5.0
        _BorderExponent ("Border Exponent", float) = 6.0

        [Header(Impact Points)]
        _ImpactTex ("Impact Texture", 2D) = "white" {}
        _ImpactColor ("Impact Color", Color) = (1,1,1,1)
        _ImpactRadius ("Impact Radius", float) = 0.25
        _ImpactIntensity ("Impact Intensity", float) = 2.0
        _ImpactWaveWidth ("Impact Wave Width", float) = 0.02
    }
    SubShader
    {
        Tags 
        { 
        	"RenderType"="Transparent" 
        	"Queue"="Transparent"
        }

        LOD 100

        // Additive blending
        Blend SrcAlpha One
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 vertexObjectPosition : TEXCOORD1;
            };

            fixed4 _Color;

            sampler2D _PulseTex;
            float4 _PulseTex_ST;
            fixed _PulseIntensity;
            fixed _PulseAnimationSpeed;
            fixed _PulseOffsetTextureImpact;

            sampler2D _HexEdgeTex;
            float4 _HexEdgeTex_ST;
            fixed4 _HexEdgeColor;
            fixed _HexEdgeIntensity;
            fixed _HexEdgeAnimationSpeed;
            fixed _HexEdgeDurationMultiplier;
            fixed _HexEdgePosScale;

            sampler2D _BorderTex;
            fixed4 _BorderTex_ST;
            fixed _BorderIntensity;
            fixed _BorderExponent;

            static const int MAX_NUMBER_OF_IMPACT_POINTS = 16;
            int _NumberOfActiveImpactPoints;
            fixed4 _ImpactPoints[MAX_NUMBER_OF_IMPACT_POINTS]; // Impact point (x,y,z,w) => "xyz" is position in local space, "w" is elapsed time from impact
            
            sampler2D _ImpactTex;
            float4 _ImpactTex_ST;
            fixed4 _ImpactColor;
            fixed _ImpactRadius;
            fixed _ImpactWaveWidth;
            fixed _ImpactIntensity;

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _PulseTex);
                o.vertexObjectPosition = v.vertex;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
            	fixed horizontalDistanceFromPivot = abs(i.vertexObjectPosition.x);
            	fixed verticalDistanceFromPivot = abs(i.vertexObjectPosition.y);

            	// Textures sampling
                fixed4 pulseTexture = tex2D(_PulseTex, i.uv);
                fixed4 hexEdgeTexture = tex2D(_HexEdgeTex, i.uv);
                fixed4 borderTexture = tex2D(_BorderTex, i.uv);
                fixed4 impactTexture = tex2D(_ImpactTex, i.uv);

                // Pulsating vave coming from center of the object and moving horizontally to both sides. 
                // Pulse is offseted by each hexagon color value.
                fixed4 pulseTerm = pulseTexture * _Color * _PulseIntensity * 
                	abs(sin(_Time.y * _PulseAnimationSpeed - horizontalDistanceFromPivot + pulseTexture.r * _PulseOffsetTextureImpact));

                // Radiating hex edge effect
                fixed hexEdgeDelayMultiplier = 1.0 - _HexEdgeDurationMultiplier;
                fixed4 hexEdgeTerm = hexEdgeTexture * _HexEdgeColor *_HexEdgeIntensity * (1 / _HexEdgeDurationMultiplier) *
                	max(sin((horizontalDistanceFromPivot + verticalDistanceFromPivot) * _HexEdgePosScale - _Time.y * _HexEdgeAnimationSpeed) - hexEdgeDelayMultiplier, 0.0);

                // Border gradient effect
                fixed4 borderTerm = pow(borderTexture.a, _BorderExponent) * _Color * _BorderIntensity;

                // Adding effect of impact points
                fixed3 impactPointsTerm = fixed3(0.0, 0.0, 0.0);
                for(int index = 0; index < _NumberOfActiveImpactPoints; index++)
                {
                    fixed impactPointCurrentRadius = _ImpactRadius * _ImpactPoints[index].w;     
                    fixed impactPointMinRadius = impactPointCurrentRadius - _ImpactWaveWidth * 0.5;
                    fixed impactPointMaxRadius = impactPointCurrentRadius + _ImpactWaveWidth * 0.5;  
                    fixed distanceFromImpact = length(i.vertexObjectPosition.xyz - _ImpactPoints[index].xyz);  

                    if(distanceFromImpact >= impactPointMinRadius && distanceFromImpact <= impactPointMaxRadius)
                    {
                        fixed distanceFromMaxRadius = impactPointMaxRadius - distanceFromImpact;
                        fixed2 impactPointUvs = fixed2(1.0, 1.0) * saturate(distanceFromImpact / impactPointCurrentRadius);
                        impactPointsTerm.rgb += impactTexture * _ImpactColor * _ImpactIntensity * (1.0 - _ImpactPoints[index].w) * (1.0 - (distanceFromMaxRadius / _ImpactWaveWidth));
                    }
                }

                return fixed4(_Color.rgb + pulseTerm.rgb + hexEdgeTerm.rgb + borderTerm.rgb + impactPointsTerm.rgb, _Color.a);
            }
            ENDCG
        }
    }
}
