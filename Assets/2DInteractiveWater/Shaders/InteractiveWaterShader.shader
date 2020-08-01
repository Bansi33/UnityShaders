Shader "Bansi/InteractiveWaterShader"
{
    Properties
    {
	    _MainTex ("Base Texture", 2D) = "white" {}
		_FoamBorder ("Foam Border (UV)", Range(0.0, 1.0)) = 0.5
        _FoamColor ("Foam Color", Color) = (1,1,1,1)

		_WaterHeight ("Water Height", float) = -3.0
		_WaterDepth ("WaterDepth", Range(5.0, 20.0)) = 10.0

		_WaveTextureUp ("Wave Texture Up", 2D) = "white" {}
		_WaveTextureDown ("Wave Texture Down", 2D) = "white" {}
		_WaveAplitude ("Wave Amplitude", Range(0.0, 10.0)) = 3.0
		_WaveWidth ("Wave Width", Range(0.0, 20.0)) = 5.0

		_AnimationLength ("Animation Length", Range(1.0, 512.0)) = 256.0
    }
    SubShader
		{
			Tags
			{
				"RenderType" = "Transparent"
				"RenderQueue" = "Transparent"
				"IgnoreProjector" = "True"
			}

			LOD 300
			ZWrite On
			Blend SrcAlpha OneMinusSrcAlpha

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "UnityCG.cginc"

			// Restricting wave count for performance
			const static int MAX_ALLOWED_WAVES = 4;

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _FoamColor;
			float _FoamBorder;
			float _WaterHeight;
			float _WaterDepth;
			sampler2D _WaveTextureUp;
			sampler2D _WaveTextureDown;
			float _WaveAplitude;
			float _WaveWidth;
			float _AnimationLength;

			// These parameters are provided through script
			float _AnimationFrame[MAX_ALLOWED_WAVES];
			float4 _IsImpactPointActive; // Each color channel represents activity of impact point, 1 is active is 0 inactive
			float4 _AnimationTypes; // Each color channel represents type of animation, 1 is Up, 0 is Down
			float4 _AmplitudePercentages; // Each color channel represents percentage of max amplitude defined in shader
			float _ImpactPoints[MAX_ALLOWED_WAVES];

			struct appdata
			{
				float2 texcoord : TEXCOORD0;
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float2 texcoord : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata IN)
			{
				v2f output;

				if (IN.texcoord.y > 0.5)
				{
					float offset = 0.0;

					for (int i = 0; i < MAX_ALLOWED_WAVES; i++)
					{
						if ((i == 0 && _IsImpactPointActive.r < 0.5) ||
						   (i == 1 && _IsImpactPointActive.g < 0.5) ||
						   (i == 2 && _IsImpactPointActive.b < 0.5) ||
						   (i == 3 && _IsImpactPointActive.a < 0.5))
						{
							continue;
						}

						float vertexWorldX = mul(unity_ObjectToWorld, IN.vertex).x;
						float distanceFromImpact = abs((vertexWorldX - _ImpactPoints[i]) / (2.0 * _WaveWidth));

						// If point is in range of wave, offset it
						if (distanceFromImpact <= 0.5)
						{
							// Set top vertices to water level + animation offset
							float textureRow = _AnimationFrame[i] / _AnimationLength;

							float waveAmplitude = i == 0 ? _AmplitudePercentages.r :
												  i == 1 ? _AmplitudePercentages.g :
												  i == 2 ? _AmplitudePercentages.b :
												  _AmplitudePercentages.a;

							if ((i == 0 && _AnimationTypes.r > 0.5) ||
							   (i == 1 && _AnimationTypes.g > 0.5) ||
							   (i == 2 && _AnimationTypes.b > 0.5) ||
							   (i == 3 && _AnimationTypes.a > 0.5))
							{
								float4 possibleOffset = tex2Dlod(_WaveTextureUp, float4(distanceFromImpact + 0.5, textureRow, 0.0, 0));
								float2 scaledOffset = possibleOffset.xy * waveAmplitude;
								// Positive offset is stored in red channel, negative in green
								offset += possibleOffset.x > 0.0 ? scaledOffset.x : -scaledOffset.y;
							}
							else
							{
								float4 possibleOffset = tex2Dlod(_WaveTextureDown, float4(distanceFromImpact + 0.5, textureRow, 0.0, 0));
								float2 scaledOffset = possibleOffset.xy * waveAmplitude;
								// Positive offset is stored in red channel, negative in green
								offset += possibleOffset.x > 0.0 ? scaledOffset.x : -scaledOffset.y;
							}
						}
					}

					IN.vertex.y = _WaterHeight + _WaveAplitude * offset;
				}
				else
				{
					// Set bottom vertices to desired water depth
					IN.vertex.y = (_WaterHeight - _WaterDepth);
				}

				output.vertex = UnityObjectToClipPos(IN.vertex);
				output.texcoord = TRANSFORM_TEX(IN.texcoord, _MainTex);

				return output;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, IN.texcoord);
				color.rgb = IN.texcoord.y > _FoamBorder ? _FoamColor.rgb : color.rgb;
				return color;
			}

			ENDCG
		} 
	}

    FallBack "Diffuse"
}