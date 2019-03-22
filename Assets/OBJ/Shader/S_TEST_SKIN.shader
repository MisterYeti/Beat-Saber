// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Océane/SKIN_HandSSS"
{
	Properties
	{
		_SpecularColor("Specular Color", Color) = (0.3921569,0.3921569,0.3921569,1)
		_Shininess("Shininess", Range( 0.01 , 1)) = 0.1
		_SSSMAP("SSS MAP", 2D) = "white" {}
		_VARIANTESSS("VARIANTE SSS", 2D) = "white" {}
		_SSSPower("SSS Power", Range( 0 , 1.5)) = 1.5
		_SSSScale("SSS Scale", Range( 0 , 1.5)) = 0.01
		_SSSColor("SSS Color", Color) = (0,0,0,0)
		_BaseColor("Base Color", Color) = (1,1,1,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Background+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		AlphaToMask On
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 4.5
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float4 _SpecularColor;
		uniform float _Shininess;
		uniform float4 _BaseColor;
		uniform sampler2D _VARIANTESSS;
		uniform float4 _VARIANTESSS_ST;
		uniform sampler2D _SSSMAP;
		uniform float4 _SSSMAP_ST;
		uniform float _SSSPower;
		uniform float _SSSScale;
		uniform float4 _SSSColor;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_VARIANTESSS = i.uv_texcoord * _VARIANTESSS_ST.xy + _VARIANTESSS_ST.zw;
			float4 tex2DNode147 = tex2D( _VARIANTESSS, uv_VARIANTESSS );
			float4 temp_output_43_0_g3 = _SpecularColor;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult4_g4 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float3 normalizeResult64_g3 = normalize( (WorldNormalVector( i , float3(0,0,1) )) );
			float dotResult19_g3 = dot( normalizeResult4_g4 , normalizeResult64_g3 );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 temp_output_40_0_g3 = ( ase_lightColor.rgb * ase_lightAtten );
			float dotResult14_g3 = dot( normalizeResult64_g3 , ase_worldlightDir );
			UnityGI gi34_g3 = gi;
			float3 diffNorm34_g3 = normalizeResult64_g3;
			gi34_g3 = UnityGI_Base( data, 1, diffNorm34_g3 );
			float3 indirectDiffuse34_g3 = gi34_g3.indirect.diffuse + diffNorm34_g3 * 0.0001;
			float4 temp_output_42_0_g3 = _BaseColor;
			float3 temp_output_138_0 = ( ( (temp_output_43_0_g3).rgb * (temp_output_43_0_g3).a * pow( max( dotResult19_g3 , 0.0 ) , ( _Shininess * 128.0 ) ) * temp_output_40_0_g3 ) + ( ( ( temp_output_40_0_g3 * max( dotResult14_g3 , 0.0 ) ) + indirectDiffuse34_g3 ) * (temp_output_42_0_g3).rgb ) );
			float2 uv_SSSMAP = i.uv_texcoord * _SSSMAP_ST.xy + _SSSMAP_ST.zw;
			float4 ase_vertex4Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 ase_objectlightDir = normalize( ObjSpaceLightDir( ase_vertex4Pos ) );
			float3 objToWorldDir111 = mul( unity_ObjectToWorld, float4( ase_worldPos, 0 ) ).xyz;
			float3 normalizeResult112 = normalize( objToWorldDir111 );
			float3 temp_output_115_0 = ( ase_objectlightDir + ( normalizeResult112 * 1.0 ) );
			float3 lerpResult152 = lerp( temp_output_115_0 , float3( 0,0,0 ) , -temp_output_115_0);
			float dotResult119 = dot( ase_worldViewDir , lerpResult152 );
			float dotResult122 = dot( pow( dotResult119 , _SSSPower ) , _SSSScale );
			c.rgb = ( tex2DNode147 * ( float4( temp_output_138_0 , 0.0 ) + ( ( tex2D( _SSSMAP, uv_SSSMAP ) * saturate( dotResult122 ) * distance( ase_worldPos , float3( 0,0,0 ) ) ) * _SSSColor ) ) ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
			float4 temp_output_43_0_g3 = _SpecularColor;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult4_g4 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float3 normalizeResult64_g3 = normalize( (WorldNormalVector( i , float3(0,0,1) )) );
			float dotResult19_g3 = dot( normalizeResult4_g4 , normalizeResult64_g3 );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 temp_output_40_0_g3 = ( ase_lightColor.rgb * 1 );
			float dotResult14_g3 = dot( normalizeResult64_g3 , ase_worldlightDir );
			float4 temp_output_42_0_g3 = _BaseColor;
			float3 temp_output_138_0 = ( ( (temp_output_43_0_g3).rgb * (temp_output_43_0_g3).a * pow( max( dotResult19_g3 , 0.0 ) , ( _Shininess * 128.0 ) ) * temp_output_40_0_g3 ) + ( ( ( temp_output_40_0_g3 * max( dotResult14_g3 , 0.0 ) ) + float3(0,0,0) ) * (temp_output_42_0_g3).rgb ) );
			o.Albedo = temp_output_138_0;
			float2 uv_VARIANTESSS = i.uv_texcoord * _VARIANTESSS_ST.xy + _VARIANTESSS_ST.zw;
			float4 tex2DNode147 = tex2D( _VARIANTESSS, uv_VARIANTESSS );
			o.Emission = ( tex2DNode147 * 0.0 ).rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			AlphaToMask Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.5
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16200
1927;1;1158;1020;-169.9659;-462.8129;1;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;149;-3674.879,1225.382;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;111;-3338.995,861.7842;Float;False;Object;World;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;113;-3014.367,1065.198;Float;False;Constant;_Float1;Float 1;9;0;Create;True;0;0;False;0;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;112;-3021.334,861.7842;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-2635.404,952.3456;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ObjSpaceLightDirHlpNode;153;-2741.66,734.9132;Float;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;115;-2362.328,930.0533;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;117;-2263.602,1232.321;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;152;-2079.745,1037.031;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;118;-2180.416,703.9283;Float;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;119;-1883.036,870.1437;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-1873.992,1105.665;Float;False;Property;_SSSPower;SSS Power;7;0;Create;True;0;0;False;0;1.5;1.384;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;120;-1593.622,876.0151;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-1559.808,1107.074;Float;False;Property;_SSSScale;SSS Scale;8;0;Create;True;0;0;False;0;0.01;0.093;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;122;-1278.029,873.1972;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;130;-1014.565,1378.991;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;124;-1025.837,874.6065;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;129;-1128.686,603.5806;Float;True;Property;_SSSMAP;SSS MAP;5;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;143;-1096.579,251.3564;Float;False;Property;_BaseColor;Base Color;10;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;134;-709.37,1099.069;Float;False;Property;_SSSColor;SSS Color;9;0;Create;True;0;0;False;0;0,0,0,0;1,0.5529411,0.231372,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;138;-801.5791,342.3564;Float;False;Blinn-Phong Light;0;;3;cf814dba44d007a4e958d2ddd5813da6;0;3;42;COLOR;0,0,0,0;False;52;FLOAT3;0,0,0;False;43;COLOR;0,0,0,0;False;2;FLOAT3;0;FLOAT;57
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;-756.7373,860.5174;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;-453.6457,984.906;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RelayNode;137;-571.9211,734.6757;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;147;-349.358,601.8061;Float;True;Property;_VARIANTESSS;VARIANTE SSS;6;0;Create;True;0;0;False;0;None;3803a927af2fc0642bb4edb7c86aa72f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;136;-211.5791,892.3563;Float;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-300.1284,788.3946;Float;False;Constant;_EmissivForce;Emissiv Force;11;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;192.4293,711.3976;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.InverseOpNode;148;-1806.778,713.1822;Float;False;1;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;144;59.19478,841.8816;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;108;539.59,786.2703;Float;False;True;5;Float;ASEMaterialInspector;0;0;CustomLighting;Océane/SKIN_HandSSS;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;1;True;True;0;True;Opaque;;Background;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;4;-1;-1;-1;0;True;0;0;False;-1;-1;0;False;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;111;0;149;0
WireConnection;112;0;111;0
WireConnection;114;0;112;0
WireConnection;114;1;113;0
WireConnection;115;0;153;0
WireConnection;115;1;114;0
WireConnection;117;0;115;0
WireConnection;152;0;115;0
WireConnection;152;2;117;0
WireConnection;119;0;118;0
WireConnection;119;1;152;0
WireConnection;120;0;119;0
WireConnection;120;1;121;0
WireConnection;122;0;120;0
WireConnection;122;1;123;0
WireConnection;130;0;149;0
WireConnection;124;0;122;0
WireConnection;138;42;143;0
WireConnection;126;0;129;0
WireConnection;126;1;124;0
WireConnection;126;2;130;0
WireConnection;135;0;126;0
WireConnection;135;1;134;0
WireConnection;137;0;138;0
WireConnection;136;0;137;0
WireConnection;136;1;135;0
WireConnection;146;0;147;0
WireConnection;146;1;145;0
WireConnection;144;0;147;0
WireConnection;144;1;136;0
WireConnection;108;0;138;0
WireConnection;108;2;146;0
WireConnection;108;13;144;0
ASEEND*/
//CHKSM=AE4757C9A148463C8C70748E051E0CFBDC8BFD2D