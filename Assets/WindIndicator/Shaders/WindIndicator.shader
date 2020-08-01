Shader "Bansi/WindIndicator"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_MetallicTex("Metallic Texture", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
		_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpPower("Normal Strength", float) = 1.0
		_OcclusionTex("Occlusion Texture", 2D) = "black" {}
		_OcclusionStrength("Occlusion Strength", float) = 1.0
		_WindSpeed("Wind Speed", Range(0.0, 1.0)) = 1.0
		_MaxWindWavingSpeed ("Waving Speed At Max Wind", float) = 25.0
		_MaxWindSpeedWavingAmplitude("Waving Amplitude At Max Wind", float) = 0.3
		_MaxWindWavingFrequency("Waving Frequency At Max Wind", float) = 5.0
		_NoWindMaxShrukage ("No wind max shrunkage", float) = 5.0	
			
    }
    SubShader
    {
        Tags 
        { 
        	"RenderType"="Opaque" 
        }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert
        #pragma target 3.0

        sampler2D _MainTex;
		sampler2D _MetallicTex;
		sampler2D _BumpMap;
		sampler2D _OcclusionTex;

        struct Input
        {
            float2 uv_MainTex;
			float2 uv_BumpMap;
			float2 uv_OcclusionTex;
			float2 uv_MetallicTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

		float _BumpPower;
		float _OcclusionStrength;
		float _WindSpeed;
		float _MaxWindWavingSpeed;
		float _MaxWindSpeedWavingAmplitude;
		float _MaxWindWavingFrequency;
		float _NoWindMaxShrukage;

		static const float DEG_TO_RAD = 0.0174533;
		static const float PI_CONST = 3.14159265358;

		// Helper function used to rotate point around object pivot
		float2 RotateAroundPivot(float2 vertexPosition, float angleInDegrees)
		{
			// Get sin and cosine of an angle
			float angleCos, angleSin;
			float angleInRadians = angleInDegrees * DEG_TO_RAD;			
			sincos(angleInRadians, angleSin, angleCos);

			// Calculate rotation matrix and use it to get rotated point
			float2x2 rotationMatrix = float2x2(angleCos, -angleSin, angleSin, angleCos);
			return mul(rotationMatrix, vertexPosition);
		}

		void vert(inout appdata_full v, out Input data)
		{
			UNITY_INITIALIZE_OUTPUT(Input, data);

			float4 objectPosition = v.vertex;
			float maxObjectSpaceZ = 453.0;
			float distanceFromHolder = -saturate(objectPosition.y / maxObjectSpaceZ);
			float inverseWindSpeedPercentage = 1.0 - _WindSpeed;

			// Waving motion left right
			float horizontalOffset = sin(_Time.y * _MaxWindWavingSpeed * _WindSpeed + (distanceFromHolder * _MaxWindWavingFrequency * _WindSpeed)) 
				* _MaxWindSpeedWavingAmplitude * _WindSpeed * distanceFromHolder;
			objectPosition.x += horizontalOffset;

			// Horizontal shrinkage based on wind speed
			float shrunkage = inverseWindSpeedPercentage * _NoWindMaxShrukage * distanceFromHolder;
			objectPosition.y += min(_NoWindMaxShrukage, shrunkage);

			float2 rotatedPosition = RotateAroundPivot(float2(objectPosition.y, objectPosition.z), -80 * inverseWindSpeedPercentage);
			objectPosition.yz = rotatedPosition.xy;

			v.vertex = objectPosition;
		}

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;

			fixed3 normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
			normal.z /= _BumpPower;
			o.Normal = normalize(normal);

			fixed4 metal = tex2D(_MetallicTex, IN.uv_MetallicTex);
			o.Metallic = metal.r;
            o.Smoothness = metal.a * _Glossiness;

			fixed4 occlusion = tex2D(_OcclusionTex, IN.uv_OcclusionTex);
			o.Occlusion = occlusion.r * _OcclusionStrength;

            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
