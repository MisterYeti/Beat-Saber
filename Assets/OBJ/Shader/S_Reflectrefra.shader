// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Océane/ReflectReflact"
{
	Properties
	{
		_Opacity("Opacity", Range( 0 , 1)) = 0
		_IndexofRefraction("Index of Refraction", Range( -3 , 4)) = 1
		[Header(Refraction)]
		_ChromaticAberration("Chromatic Aberration", Range( 0 , 0.3)) = 0.1
		_Specular("Specular", Range( 0 , 1)) = 0
		_SoapAmount("Soap Amount", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.8
		_Foam("Foam", 2D) = "white" {}
		_TextureSample3("Texture Sample 3", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile _ALPHAPREMULTIPLY_ON
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float4 screenPos;
		};

		uniform float _Specular;
		uniform sampler2D _TextureSample3;
		uniform sampler2D _Foam;
		uniform float _SoapAmount;
		uniform float _Smoothness;
		uniform float _Opacity;
		uniform sampler2D _GrabTexture;
		uniform float _ChromaticAberration;
		uniform float _IndexofRefraction;

		inline float4 Refraction( Input i, SurfaceOutputStandard o, float indexOfRefraction, float chomaticAberration ) {
			float3 worldNormal = o.Normal;
			float4 screenPos = i.screenPos;
			#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
			#else
				float scale = 1.0;
			#endif
			float halfPosW = screenPos.w * 0.5;
			screenPos.y = ( screenPos.y - halfPosW ) * _ProjectionParams.x * scale + halfPosW;
			#if SHADER_API_D3D9 || SHADER_API_D3D11
				screenPos.w += 0.00000000001;
			#endif
			float2 projScreenPos = ( screenPos / screenPos.w ).xy;
			float3 worldViewDir = normalize( UnityWorldSpaceViewDir( i.worldPos ) );
			float3 refractionOffset = ( ( ( ( indexOfRefraction - 1.0 ) * mul( UNITY_MATRIX_V, float4( worldNormal, 0.0 ) ) ) * ( 1.0 / ( screenPos.z + 1.0 ) ) ) * ( 1.0 - dot( worldNormal, worldViewDir ) ) );
			float2 cameraRefraction = float2( refractionOffset.x, -( refractionOffset.y * _ProjectionParams.x ) );
			float4 redAlpha = tex2D( _GrabTexture, ( projScreenPos + cameraRefraction ) );
			float green = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 - chomaticAberration ) ) ) ).g;
			float blue = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 + chomaticAberration ) ) ) ).b;
			return float4( redAlpha.r, green, blue, redAlpha.a );
		}

		void RefractionF( Input i, SurfaceOutputStandard o, inout half4 color )
		{
			#ifdef UNITY_PASS_FORWARDBASE
			color.rgb = color.rgb + Refraction( i, o, _IndexofRefraction, _ChromaticAberration ) * ( 1 - color.a );
			color.a = 1;
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = float3(0,0,1);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult111 = dot( ase_worldPos , ase_worldViewDir );
			float4 temp_cast_0 = (_Specular).xxxx;
			float2 panner105 = ( 0.1 * _Time.y * float2( 0.1,0.1 ) + i.uv_texcoord);
			float2 temp_cast_1 = (( ( tex2D( _Foam, panner105 ).r + ( abs( (i.uv_texcoord.x*2.0 + -1.0) ) * 0.5 ) ) + _Time.x )).xx;
			float4 lerpResult117 = lerp( temp_cast_0 , saturate( tex2D( _TextureSample3, temp_cast_1 ) ) , _SoapAmount);
			o.Emission = ( ( 1.0 - saturate( ( pow( dotResult111 , 2.0 ) - 0.1 ) ) ) * lerpResult117 ).rgb;
			o.Smoothness = _Smoothness;
			o.Alpha = _Opacity;
			o.Normal = o.Normal + 0.00001 * i.screenPos * i.worldPos;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha finalcolor:RefractionF fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 screenPos : TEXCOORD3;
				float4 tSpace0 : TEXCOORD4;
				float4 tSpace1 : TEXCOORD5;
				float4 tSpace2 : TEXCOORD6;
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
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
1927;1;1158;1020;-221.355;828.3833;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;83;-1791.527,-931.994;Float;False;2577.155;665.7997;;24;121;120;119;118;117;116;115;114;113;112;111;109;108;107;106;105;103;102;101;100;99;98;97;122;Chromatic Specular Reflection;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;108;-1743.527,-867.994;Float;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;102;-1503.527,-531.994;Float;True;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;105;-1103.527,-867.994;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0.1;False;1;FLOAT;0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.AbsOpNode;101;-1215.527,-531.994;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;109;-399.5274,-723.994;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;122;-433.7747,-887.045;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;97;-911.5274,-883.994;Float;True;Property;_Foam;Foam;8;0;Create;True;0;0;False;0;None;cd460ee4ac5c1e746b7a734cc7cc64dd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-991.5274,-531.994;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;107;-639.5274,-499.994;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;103;-591.5274,-755.994;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;1.32;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;111;-239.5274,-803.994;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;114;-111.5274,-803.994;Float;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;106;-367.5274,-515.994;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;121;-159.5274,-675.994;Float;True;Property;_TextureSample3;Texture Sample 3;9;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;115;48.4726,-803.994;Float;False;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;118;176.4726,-659.994;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;120;-159.5274,-451.994;Float;False;Property;_SoapAmount;Soap Amount;6;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;112;192.4726,-803.994;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;119;-159.5274,-355.994;Float;False;Property;_Specular;Specular;5;0;Create;True;0;0;False;0;0;0.03141877;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;117;368.4726,-659.994;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;113;336.4726,-803.994;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinTimeNode;98;-1487.527,-739.994;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;560.4726,-739.994;Float;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;95;528.4726,-131.994;Float;False;Property;_IndexofRefraction;Index of Refraction;2;0;Create;True;0;0;False;0;1;1.1;-3;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;99;-1327.527,-739.994;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;94;528.4726,-227.994;Float;False;Property;_Smoothness;Smoothness;7;0;Create;True;0;0;False;0;0.8;0.0981324;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;96;528.4726,-35.99402;Float;False;Property;_Opacity;Opacity;1;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;124;1017.882,-290.756;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Océane/ReflectReflact;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;AlphaTest;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;3;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;102;0;108;1
WireConnection;105;0;108;0
WireConnection;101;0;102;0
WireConnection;97;1;105;0
WireConnection;100;0;101;0
WireConnection;103;0;97;1
WireConnection;103;1;100;0
WireConnection;111;0;122;0
WireConnection;111;1;109;0
WireConnection;114;0;111;0
WireConnection;106;0;103;0
WireConnection;106;1;107;1
WireConnection;121;1;106;0
WireConnection;115;0;114;0
WireConnection;118;0;121;0
WireConnection;112;0;115;0
WireConnection;117;0;119;0
WireConnection;117;1;118;0
WireConnection;117;2;120;0
WireConnection;113;0;112;0
WireConnection;116;0;113;0
WireConnection;116;1;117;0
WireConnection;99;0;98;4
WireConnection;124;2;116;0
WireConnection;124;4;94;0
WireConnection;124;8;95;0
WireConnection;124;9;96;0
ASEEND*/
//CHKSM=4A71A2F95ACF7EB0F0340B359163369A857326A3