// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Océane/Multipass-holographique"
{
	Properties
	{
		_Distorsion("Distorsion", Range( 0 , 0.1)) = 0.292
		_TextureSample0("Texture Sample 0", 2D) = "bump" {}
		_RimColor("RimColor", Color) = (0,0,0,0)
		_Speed_animation("Speed_animation", Float) = 0
		_DepthFadeDistance("Depth Fade Distance", Float) = 0
		_Transparence_general("Transparence_general", Color) = (0,0,0,0)
		_RimPower("RimPower", Range( 0 , 10)) = 0
		_Outline_net("Outline_net", Float) = 0
		_Outline_intens("Outline_intens", Float) = 0
		_Normals("Normals", 2D) = "bump" {}
		_IntersectionColor("Intersection Color", Color) = (0.4338235,0.4377282,1,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
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
			float2 uv_texcoord;
			float3 viewDir;
			INTERNAL_DATA
			float4 screenPos;
			float3 worldPos;
			float3 worldNormal;
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

		uniform sampler2D _Normals;
		uniform float4 _Normals_ST;
		uniform float _RimPower;
		uniform float4 _RimColor;
		uniform float4 _IntersectionColor;
		uniform sampler2D _CameraDepthTexture;
		uniform float _DepthFadeDistance;
		uniform sampler2D _GrabTexture;
		uniform float _Distorsion;
		uniform sampler2D _TextureSample0;
		uniform float _Speed_animation;
		uniform float4 _Transparence_general;
		uniform float _Outline_intens;
		uniform float _Outline_net;


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 uv_Normals = i.uv_texcoord * _Normals_ST.xy + _Normals_ST.zw;
			float3 normalizeResult140 = normalize( i.viewDir );
			float dotResult142 = dot( UnpackNormal( tex2D( _Normals, uv_Normals ) ) , normalizeResult140 );
			float temp_output_143_0 = saturate( dotResult142 );
			float temp_output_146_0 = pow( ( 1.0 - temp_output_143_0 ) , _RimPower );
			float4 temp_output_148_0 = ( temp_output_146_0 * _RimColor );
			float4 temp_output_187_0 = ( temp_output_148_0 + ( 1.0 - temp_output_146_0 ) );
			float mulTime158 = _Time.y * _Speed_animation;
			float cos161 = cos( mulTime158 );
			float sin161 = sin( mulTime158 );
			float2 rotator161 = mul( i.uv_texcoord - float2( 0.5,0.5 ) , float2x2( cos161 , -sin161 , sin161 , cos161 )) + float2( 0.5,0.5 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor169 = tex2D( _GrabTexture, ( float4( UnpackScaleNormal( tex2D( _TextureSample0, rotator161 ), _Distorsion ) , 0.0 ) + ase_grabScreenPosNorm ).xy );
			float4 IntersectionColor102 = _IntersectionColor;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV170 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode170 = ( 0.0 + _Outline_intens * pow( 1.0 - fresnelNdotV170, _Outline_net ) );
			float4 lerpResult179 = lerp( ( float4( (screenColor169).rgb , 0.0 ) * _Transparence_general ) , ( IntersectionColor102 * fresnelNode170 ) , fresnelNode170);
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth112 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( ase_screenPos ))));
			float distanceDepth112 = abs( ( screenDepth112 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthFadeDistance ) );
			float SaturatedDepthFade116 = saturate( distanceDepth112 );
			float4 appendResult182 = (float4((lerpResult179).rgb , SaturatedDepthFade116));
			c.rgb = appendResult182.xyz;
			c.a = temp_output_187_0.r;
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
			float2 uv_Normals = i.uv_texcoord * _Normals_ST.xy + _Normals_ST.zw;
			float3 normalizeResult140 = normalize( i.viewDir );
			float dotResult142 = dot( UnpackNormal( tex2D( _Normals, uv_Normals ) ) , normalizeResult140 );
			float temp_output_143_0 = saturate( dotResult142 );
			float temp_output_146_0 = pow( ( 1.0 - temp_output_143_0 ) , _RimPower );
			float4 temp_output_148_0 = ( temp_output_146_0 * _RimColor );
			float4 temp_output_187_0 = ( temp_output_148_0 + ( 1.0 - temp_output_146_0 ) );
			float4 IntersectionColor102 = _IntersectionColor;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth112 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( ase_screenPos ))));
			float distanceDepth112 = abs( ( screenDepth112 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthFadeDistance ) );
			float SaturatedDepthFade116 = saturate( distanceDepth112 );
			float4 appendResult120 = (float4((IntersectionColor102).rgb , ( 1.0 - SaturatedDepthFade116 )));
			float4 temp_output_154_0 = ( appendResult120 + temp_output_146_0 );
			float4 lerpResult201 = lerp( temp_output_148_0 , temp_output_187_0 , temp_output_154_0);
			o.Emission = lerpResult201.rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows exclude_path:deferred 

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
				float4 screenPos : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
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
1927;1;1158;1020;-58.2325;-1503.908;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;156;-2089.868,2227.625;Float;False;1820.48;460.2398;;13;175;174;172;169;166;164;163;162;161;160;159;158;157;Calculate and apply Distortion;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;157;-2083.868,2529.625;Float;False;Property;_Speed_animation;Speed_animation;5;0;Create;True;0;0;False;0;0;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;149;-974.1001,1447.308;Float;False;1412.797;678.7869;Comment;10;139;140;141;142;143;144;145;146;147;195;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;160;-1927.868,2277.625;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;158;-1879.868,2533.625;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;159;-1879.868,2405.625;Float;False;Constant;_Vector1;Vector 1;-1;0;Create;True;0;0;False;0;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RotatorNode;161;-1655.869,2357.625;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;162;-1655.869,2485.625;Float;False;Property;_Distorsion;Distorsion;0;0;Create;True;0;0;False;0;0.292;0.0726;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;139;-924.1,1779.596;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;86;-819.9849,978.7614;Float;False;1268.871;416.1864;;9;121;120;119;116;115;112;106;102;100;First Pass only renders intersection;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-797.9849,1292.513;Float;False;Property;_DepthFadeDistance;Depth Fade Distance;6;0;Create;True;0;0;False;0;0;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;141;-922.0425,1497.308;Float;True;Property;_Normals;Normals;14;0;Create;True;0;0;False;0;None;066f29fd0fc3d0341b96857dcf2cede3;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;1,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;140;-701.403,1776.496;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;165;-956.5323,2782.593;Float;False;752.7268;415.7021;;5;173;171;170;168;167;Adding Rim effect;1,1,1,1;0;0
Node;AmplifyShaderEditor.GrabScreenPosition;163;-1303.869,2501.625;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;164;-1367.869,2293.625;Float;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;False;0;None;dd2fd2df93418444c8e280f1d34deeb5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;100;-465.9854,1031.513;Float;False;Property;_IntersectionColor;Intersection Color;15;0;Create;True;0;0;False;0;0.4338235,0.4377282,1,0;0.3066037,0.520539,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;168;-906.5325,3074.879;Float;False;Property;_Outline_net;Outline_net;11;0;Create;True;0;0;False;0;0;1.55;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;166;-1047.868,2389.625;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;167;-890.5326,2978.88;Float;False;Property;_Outline_intens;Outline_intens;13;0;Create;True;0;0;False;0;0;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;112;-557.985,1276.513;Float;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;102;-225.984,1031.513;Float;False;IntersectionColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;142;-507.6455,1687.808;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;171;-723.0726,2840.613;Float;False;102;IntersectionColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;143;-332.4463,1663.308;Float;False;1;0;FLOAT;1.23;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;169;-901.9517,2315.02;Float;False;Global;_GrabScreen1;Grab Screen 1;2;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;115;-309.9852,1271.513;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;170;-695.0137,2945.294;Float;True;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-459.1027,1866.295;Float;False;Property;_RimPower;RimPower;8;0;Create;True;0;0;False;0;0;3.63;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;116;-161.984,1239.513;Float;False;SaturatedDepthFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;174;-702.8925,2412.405;Float;False;Property;_Transparence_general;Transparence_general;7;0;Create;True;0;0;False;0;0,0,0,0;0.6698113,0.6698113,0.6698113,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;172;-686.9055,2325.462;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;173;-372.8069,2832.593;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;144;-165.5008,1715.895;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;177;-86.09448,2589.722;Float;False;668.4583;299.6378;;4;182;181;180;179;Combining everything through generated alphas;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;147;40.09726,1950.095;Float;False;Property;_RimColor;RimColor;4;0;Create;True;0;0;False;0;0,0,0,0;0.6981132,0.6981132,0.6981132,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;176;-178.8325,2796.822;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;178;-195.6817,2923.964;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;146;27.29671,1739.296;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;121;8.575806,1028.761;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;175;-446.8927,2396.405;Float;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;119;94.25664,1215.54;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;340.7553,1746.544;Float;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;199;351.989,2022.601;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;120;276.6317,1095.629;Float;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;179;-36.0945,2682.506;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;187;571.3801,2021.353;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;85;-2157.479,-107.5054;Float;False;1820.48;460.2398;;13;110;109;108;103;101;97;96;95;94;93;92;91;90;Calculate and apply Distortion;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;88;-153.705,254.5917;Float;False;668.4583;299.6378;;4;118;117;114;89;Combining everything through generated alphas;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;154;566.1643,1231.68;Float;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;181;172.1152,2639.722;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;180;141.4972,2774.36;Float;False;116;SaturatedDepthFade;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;87;-1024.143,447.4623;Float;False;752.7268;415.7021;;5;107;105;104;99;98;Adding Rim effect;1,1,1,1;0;0
Node;AmplifyShaderEditor.ComponentMaskNode;109;-754.5162,-9.668125;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;114;-103.705,347.3759;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;104;-762.6243,610.1642;Float;True;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;101;-1115.479,54.49469;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;182;412.3631,2698.13;Float;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;97;-1435.48,-41.50543;Float;True;Property;_TextureSample1;Texture Sample 1;9;0;Create;True;0;0;False;0;None;dd2fd2df93418444c8e280f1d34deeb5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;90;-2107.479,198.4948;Float;False;Property;_TimeScale;Time Scale;10;0;Create;True;0;0;False;0;0;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;93;-1947.479,198.4948;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;103;-969.5624,-20.11021;Float;False;Global;_GrabScreen0;Grab Screen 0;2;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;113;-263.2922,588.8334;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;98;-974.1431,739.7497;Float;False;Property;_FresnelPower;Fresnel Power;16;0;Create;True;0;0;False;0;0;2.32;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-1723.48,150.4947;Float;False;Property;_DistortionAmount;Distortion Amount;2;0;Create;True;0;0;False;0;0.292;0.052;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;195;-118.1557,1564.604;Float;False;Inverse;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;189;849.0654,1250.648;Float;False;Intersection;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;92;-1947.479,70.49472;Float;False;Constant;_Vector0;Vector 0;-1;0;Create;True;0;0;False;0;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;-440.4173,497.4623;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;91;-1995.479,-57.50541;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;89;344.7527,362.9997;Float;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;118;104.5048,304.5917;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;111;-246.443,461.6919;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-514.5032,61.27472;Float;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;201;846.2395,1811.437;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;99;-958.1432,643.7497;Float;False;Property;_FresnelScale;Fresnel Scale;17;0;Create;True;0;0;False;0;0;-0.46;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;108;-770.5032,77.27475;Float;False;Property;_ForcefieldTint;Forcefield Tint;12;0;Create;True;0;0;False;0;0,0,0,0;0.9122463,0.9392868,0.9433962,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;105;-790.6832,505.4824;Float;False;102;IntersectionColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GrabScreenPosition;96;-1371.48,166.4947;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RotatorNode;95;-1723.48,22.49467;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;73.88663,439.2295;Float;False;116;SaturatedDepthFade;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;150;1161.821,1999.732;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;Océane/Multipass-holographique;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;AlphaTest;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;158;0;157;0
WireConnection;161;0;160;0
WireConnection;161;1;159;0
WireConnection;161;2;158;0
WireConnection;140;0;139;0
WireConnection;164;1;161;0
WireConnection;164;5;162;0
WireConnection;166;0;164;0
WireConnection;166;1;163;0
WireConnection;112;0;106;0
WireConnection;102;0;100;0
WireConnection;142;0;141;0
WireConnection;142;1;140;0
WireConnection;143;0;142;0
WireConnection;169;0;166;0
WireConnection;115;0;112;0
WireConnection;170;2;167;0
WireConnection;170;3;168;0
WireConnection;116;0;115;0
WireConnection;172;0;169;0
WireConnection;173;0;171;0
WireConnection;173;1;170;0
WireConnection;144;0;143;0
WireConnection;176;0;173;0
WireConnection;178;0;170;0
WireConnection;146;0;144;0
WireConnection;146;1;145;0
WireConnection;121;0;102;0
WireConnection;175;0;172;0
WireConnection;175;1;174;0
WireConnection;119;0;116;0
WireConnection;148;0;146;0
WireConnection;148;1;147;0
WireConnection;199;0;146;0
WireConnection;120;0;121;0
WireConnection;120;3;119;0
WireConnection;179;0;175;0
WireConnection;179;1;176;0
WireConnection;179;2;178;0
WireConnection;187;0;148;0
WireConnection;187;1;199;0
WireConnection;154;0;120;0
WireConnection;154;1;146;0
WireConnection;181;0;179;0
WireConnection;109;0;103;0
WireConnection;114;0;110;0
WireConnection;114;1;111;0
WireConnection;114;2;113;0
WireConnection;104;2;99;0
WireConnection;104;3;98;0
WireConnection;101;0;97;0
WireConnection;101;1;96;0
WireConnection;182;0;181;0
WireConnection;182;3;180;0
WireConnection;97;1;95;0
WireConnection;97;5;94;0
WireConnection;93;0;90;0
WireConnection;103;0;101;0
WireConnection;113;0;104;0
WireConnection;195;0;143;0
WireConnection;189;0;154;0
WireConnection;107;0;105;0
WireConnection;107;1;104;0
WireConnection;89;0;118;0
WireConnection;89;3;117;0
WireConnection;118;0;114;0
WireConnection;111;0;107;0
WireConnection;110;0;109;0
WireConnection;110;1;108;0
WireConnection;201;0;148;0
WireConnection;201;1;187;0
WireConnection;201;2;154;0
WireConnection;95;0;91;0
WireConnection;95;1;92;0
WireConnection;95;2;93;0
WireConnection;150;2;201;0
WireConnection;150;9;187;0
WireConnection;150;13;182;0
ASEEND*/
//CHKSM=612159F3E1B7B6A6186BE4A8E0828BA8CBC6FC8F