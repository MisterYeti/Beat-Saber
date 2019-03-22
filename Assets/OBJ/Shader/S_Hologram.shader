// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Océane/Holographique_Test"
{
	Properties
	{
		_Color("Color", Color) = (0,0,0,0)
		_Albedo("Albedo", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_Transparence("Transparence", Range( 0 , 1)) = 0.5
		_ShieldPatternColor("Shield Pattern Color", Color) = (0.2470588,0.7764706,0.9098039,1)
		_ShieldPatternPower("Shield Pattern Power", Range( 0 , 100)) = 5
		_ShieldRimPower("Shield Rim Power", Range( 0 , 10)) = 7
		_ShieldAnimSpeed("Shield Anim Speed", Range( -10 , 10)) = 3
		_ShieldPatternWaves("Shield Pattern Waves", 2D) = "white" {}
		_IntersectIntensity("Intersect Intensity", Range( 0 , 1)) = 0.2
		_IntersectColor("Intersect Color", Color) = (0.03137255,0.2588235,0.3176471,1)
		_HitPosition("Hit Position", Vector) = (0,0,0,0)
		_HitTime("Hit Time", Float) = 0
		_HitColor("Hit Color", Color) = (1,1,1,1)
		_HitSize("Hit Size", Float) = 0.2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
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
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float4 screenPos;
		};

		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform float4 _Color;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float4 _IntersectColor;
		uniform float _ShieldRimPower;
		uniform sampler2D _ShieldPatternWaves;
		uniform float _ShieldAnimSpeed;
		uniform float _HitTime;
		uniform float3 _HitPosition;
		uniform float _HitSize;
		uniform float4 _ShieldPatternColor;
		uniform float4 _HitColor;
		uniform sampler2D _CameraDepthTexture;
		uniform float _IntersectIntensity;
		uniform float _ShieldPatternPower;
		uniform float _Transparence;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 Normal237 = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			o.Normal = Normal237;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 Albedo239 = ( _Color * tex2D( _Albedo, uv_Albedo ) );
			o.Albedo = Albedo239.rgb;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float ShieldRimPower181 = _ShieldRimPower;
			float fresnelNdotV191 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode191 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV191, (10.0 + (ShieldRimPower181 - 0.0) * (0.0 - 10.0) / (10.0 - 0.0)) ) );
			float ShieldRim198 = fresnelNode191;
			float2 ShieldPattern201 = float2( 0,0 );
			float4 ShieldSpeed154 = ( _Time * _ShieldAnimSpeed );
			float2 appendResult183 = (float2(float2( 1,0 ).x , ( 1.0 - ( ShieldSpeed154 / 9.11 ) ).x));
			float2 uv_TexCoord185 = i.uv_texcoord * float2( 1,1 ) + appendResult183;
			float4 waves199 = tex2D( _ShieldPatternWaves, uv_TexCoord185 );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float temp_output_153_0 = distance( ase_vertex3Pos , _HitPosition );
			float HitSize162 = _HitSize;
			float4 ShieldPatternColor174 = _ShieldPatternColor;
			float4 HitColor169 = _HitColor;
			float4 lerpResult188 = lerp( ShieldPatternColor174 , ( HitColor169 * ( HitSize162 / temp_output_153_0 ) ) , (0.0 + (_HitTime - 0.0) * (1.0 - 0.0) / (100.0 - 0.0)));
			float4 hit211 = (( _HitTime > 0.0 ) ? (( temp_output_153_0 < HitSize162 ) ? lerpResult188 :  ShieldPatternColor174 ) :  ShieldPatternColor174 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth212 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( ase_screenPos ))));
			float distanceDepth212 = abs( ( screenDepth212 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _IntersectIntensity ) );
			float clampResult220 = clamp( distanceDepth212 , 0.0 , 1.0 );
			float4 lerpResult227 = lerp( _IntersectColor , ( ( float4( ( ShieldRim198 + ShieldPattern201 ), 0.0 , 0.0 ) * waves199 ) * ( hit211 * ShieldPatternColor174 ) ) , clampResult220);
			float ShieldPower230 = _ShieldPatternPower;
			float4 Emission236 = ( lerpResult227 * ShieldPower230 );
			o.Emission = Emission236.rgb;
			o.Alpha = ( _Transparence + ShieldRim198 );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

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
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
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
1927;1;1158;1020;403.191;4037.752;1.3;True;False
Node;AmplifyShaderEditor.CommentaryNode;143;-2587.163,-4071.095;Float;False;830.728;358.1541;Comment;4;154;147;145;144;Animation Speed;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;146;-2546.388,-2601.741;Float;False;1858.993;1001.87;Comment;22;211;196;195;190;188;186;184;177;176;175;173;170;169;168;162;159;158;157;155;153;150;149;Impact Effect;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-2537.163,-3827.941;Float;False;Property;_ShieldAnimSpeed;Shield Anim Speed;16;0;Create;True;0;0;False;0;3;-7.12;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;144;-2463.571,-4021.096;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;150;-2496.388,-2190.141;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;155;-2416.483,-2551.741;Float;False;Property;_HitSize;Hit Size;25;0;Create;True;0;0;False;0;0.2;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;149;-2487.781,-2005.841;Float;False;Property;_HitPosition;Hit Position;22;0;Create;True;0;0;False;0;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;-2221.035,-3897.682;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;148;-2564.595,-3298.25;Float;False;1608.543;477.595;Comment;11;199;192;185;183;180;172;171;160;152;151;266;Shield Wave Effect;1,1,1,1;0;0
Node;AmplifyShaderEditor.DistanceOpNode;153;-2256.183,-2106.541;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;156;-1643.187,-4090.397;Float;False;1504.24;684.7161;Comment;12;230;218;201;194;189;179;178;174;167;166;164;163;Shield Main Pattern;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;161;-873.4045,-3239.597;Float;False;1030.896;385.0003;Comment;6;198;191;187;182;181;165;Shield RIM;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;162;-2203.283,-2547.841;Float;False;HitSize;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;154;-2004.435,-3886.546;Float;False;ShieldSpeed;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;157;-2458.171,-2444.84;Float;False;Property;_HitColor;Hit Color;24;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;152;-2477.73,-2933.654;Float;False;Constant;_Float0;Float 0;7;0;Create;True;0;0;False;0;9.11;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;159;-2036.195,-1937.273;Float;False;162;HitSize;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;151;-2514.595,-3022.251;Float;False;154;ShieldSpeed;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;158;-2079.286,-1866.772;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;169;-2177,-2442.288;Float;False;HitColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;165;-819.6534,-3187.853;Float;False;Property;_ShieldRimPower;Shield Rim Power;15;0;Create;True;0;0;False;0;7;7.27;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;163;-1580.048,-4039.497;Float;False;Property;_ShieldPatternColor;Shield Pattern Color;9;0;Create;True;0;0;False;0;0.2470588,0.7764706,0.9098039,1;0,0.7957666,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;173;-1841.493,-1732.871;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;168;-1824.398,-1822.172;Float;False;169;HitColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;174;-1274.947,-4040.397;Float;False;ShieldPatternColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;160;-2306.763,-3008.396;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;181;-465.7454,-3189.597;Float;False;ShieldRimPower;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;170;-2021.099,-2076.026;Float;False;Property;_HitTime;Hit Time;23;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;176;-1638.096,-2273.873;Float;False;174;ShieldPatternColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;172;-2173.403,-3018.787;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;171;-2166.475,-3176.393;Float;False;Constant;_Vector2;Vector 2;7;0;Create;True;0;0;False;0;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;-1598.299,-1815.473;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;182;-823.4044,-3056.497;Float;False;181;ShieldRimPower;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;175;-1787.997,-1997.473;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;100;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;188;-1458.197,-2008.572;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;180;-1974.076,-3248.249;Float;False;Constant;_Vector3;Vector 3;7;0;Create;True;0;0;False;0;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;183;-1970.766,-3124.436;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;187;-527.9454,-3056.597;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;10;False;3;FLOAT;10;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;184;-1727.271,-2207.935;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;186;-1656.966,-2147.779;Float;False;162;HitSize;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;195;-1766.648,-2310.467;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCCompareLower;190;-1268.083,-2129.508;Float;False;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;185;-1775.057,-3133.095;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;191;-316.3464,-3054.897;Float;False;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;193;-2507.082,-1490.743;Float;False;1652.997;650.1895;Mix of Pattern, Wave, Rim , Impact and adding intersection highlight;17;236;233;227;225;223;220;217;216;213;212;210;209;205;204;203;202;200;Shield Mix for Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;192;-1533.157,-3148.467;Float;True;Property;_ShieldPatternWaves;Shield Pattern Waves;17;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;201;-394.9464,-3691.097;Float;False;ShieldPattern;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;198;-85.50861,-3058.966;Float;False;ShieldRim;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCCompareGreater;196;-1126.695,-2377.307;Float;False;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;200;-2447.147,-1301.997;Float;False;198;ShieldRim;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;211;-930.3947,-2373.5;Float;False;hit;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;203;-2457.082,-1211.14;Float;False;201;ShieldPattern;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;199;-1199.052,-3158.112;Float;False;waves;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;-2206.719,-1125.176;Float;False;211;hit;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;209;-2286.468,-1042.252;Float;False;174;ShieldPatternColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;202;-2438.206,-1132.853;Float;False;199;waves;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;205;-2219.757,-1262.002;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;210;-2293.87,-961.8743;Float;False;Property;_IntersectIntensity;Intersect Intensity;20;0;Create;True;0;0;False;0;0.2;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;212;-1999.73,-946.9818;Float;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;213;-2043.622,-1238.367;Float;False;2;2;0;FLOAT2;0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;216;-1962.593,-1057.871;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;218;-886.3465,-3994.097;Float;False;Property;_ShieldPatternPower;Shield Pattern Power;14;0;Create;True;0;0;False;0;5;2.6;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;217;-1824.184,-1440.743;Float;False;Property;_IntersectColor;Intersect Color;21;0;Create;True;0;0;False;0;0.03137255,0.2588235,0.3176471,1;0.03137255,0.08000084,0.3176467,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;230;-566.3453,-3984.197;Float;False;ShieldPower;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;222;-494.1874,-1946.041;Float;False;837.0001;689.9695;Comment;7;239;237;234;232;229;226;268;Textures;1,1,1,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;220;-1711.578,-996.5537;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;223;-1801.275,-1243.548;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;229;-437.7874,-1705.272;Float;True;Property;_Albedo;Albedo;4;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;227;-1521.984,-1233.643;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;225;-1505.985,-1092.24;Float;False;230;ShieldPower;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;226;-416.6833,-1896.041;Float;False;Property;_Color;Color;1;0;Create;True;0;0;False;0;0,0,0,0;0,0.5373576,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;234;-444.1873,-1486.071;Float;True;Property;_Normal;Normal;5;0;Create;True;0;0;False;0;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;233;-1280.386,-1202.64;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;232;-63.38738,-1737.271;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;239;99.81249,-1743.671;Float;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;269;177.8589,-3360.805;Float;True;198;ShieldRim;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;197;-580.8613,-2589.046;Float;False;1223.975;464.9008;Comment;11;238;235;231;228;224;221;219;215;214;208;207;Shield Distortion;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;244;40.33911,-3522.601;Float;False;Property;_Transparence;Transparence;6;0;Create;True;0;0;False;0;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;83;-1278.127,-195.9543;Float;False;614.0698;167.2261;Comment;2;87;85;Speed;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;84;-2870.064,-5164.984;Float;False;2377.06;920.5361;Comment;12;132;248;247;249;251;250;253;252;254;256;257;260;Scan Lines;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;90;-2725.926,121.8965;Float;False;2344.672;617.4507;Comment;18;142;139;130;127;125;123;119;118;113;110;109;108;105;102;100;96;95;93;Rim;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;128;-1984.933,-244.2293;Float;False;590.8936;257.7873;Comment;2;136;129;Hologram Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;236;-1097.085,-1227.642;Float;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;237;-56.98736,-1478.071;Float;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;228;119.3135,-2246.673;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;110;-1758.1,468.3584;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;252;-2103.946,-4799.672;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;231;27.41655,-2396.244;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-1228.127,-143.7281;Float;False;Property;_Speed;Speed;3;0;Create;True;0;0;False;0;26;28.36415;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;221;-138.3454,-2509.179;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;253;-2107.256,-4923.485;Float;False;Constant;_Vector4;Vector 4;7;0;Create;True;0;0;False;0;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;166;-1593.187,-3840.84;Float;False;Property;_ShieldPatternSize;Shield Pattern Size;13;1;[IntRange];Create;True;0;0;False;0;5;13.33565;1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;242;355.2353,-3791.727;Float;False;236;Emission;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;247;-2647.774,-4697.487;Float;False;154;ShieldSpeed;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;-898.0569,-145.9542;Float;False;Speed;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;123;-1221.73,444.2698;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;260;-1430.793,-4503.611;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;224;7.447569,-2493.841;Float;False;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;241;416.4122,-3838.671;Float;False;239;Albedo;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;132;-727.0043,-4829.274;Float;True;ScanLines;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;105;-2122.829,270.2372;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalVertexDataNode;214;-401.7134,-2539.046;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;109;-1931.515,217.2783;Float;True;Property;_RimNormalMap;Rim Normal Map;8;0;Create;True;0;0;False;0;5b653e484c8e303439ef414b62f969f0;f7f322ea849ea7d41adb6fa8a7d8a3e6;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;119;-1861.563,600.8672;Float;False;Property;_RimPower;Rim Power;10;0;Create;True;0;0;False;0;5;4.13;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;134;-223.9029,-93.60495;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;238;393.1133,-2440.573;Float;False;VertexOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;130;-615.2544,483.8245;Float;True;Rim;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;-5.841187,-155.0235;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;108;-2011.132,447.2706;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;219;-296.0835,-2239.146;Float;False;Property;_ShieldDistortion;Shield Distortion;19;0;Create;True;0;0;False;0;0.01;0.01;0;0.03;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;251;-2306.584,-4694.023;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;208;-530.8614,-2380.429;Float;False;154;ShieldSpeed;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;164;-1506.046,-3722.697;Float;False;Constant;_Vector0;Vector 0;6;0;Create;True;0;0;False;0;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TimeNode;96;-2672.363,280.7356;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;95;-2424.208,202.3241;Float;False;2;0;FLOAT;0;False;1;FLOAT;1000;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;215;-306.9465,-2351.77;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;135;-261.209,-200.3307;Float;False;136;HologramColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldPosInputsNode;245;-1924.195,-3621.083;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;133;-486.9618,-172.4915;Float;False;132;ScanLines;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;254;-1908.237,-4808.331;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;266;-2326.237,-3275.575;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;100;-2467.275,498.0536;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;131;-480.3235,-80.25208;Float;False;130;Rim;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;256;-1175.164,-4846.679;Float;True;Property;_TextureSample1;Texture Sample 1;18;0;Create;True;0;0;False;0;None;05aa43dbbeddb24419e5b5b6e734d595;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;178;-1253.187,-3816.84;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldReflectionVector;257;-1956.036,-4632.288;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;270;402.859,-3487.805;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;142;-1071.955,624.3473;Float;False;136;HologramColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;118;-1390.735,401.9705;Float;False;1;0;FLOAT;1.23;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;127;-1028.932,467.6703;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;194;-784.1473,-3692.897;Float;True;Property;_ShieldPattern;Shield Pattern;11;0;Create;True;0;0;False;0;None;5798ded558355430c8a9b13ee12a847c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;268;-127.0474,-1859.624;Float;False;Transparence;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;136;-1667,-155.0851;Float;False;HologramColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-2293.37,255.8098;Float;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DotProductOpNode;113;-1579.006,345.4164;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;167;-1471.114,-3520.681;Float;False;154;ShieldSpeed;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-2675.926,171.8965;Float;False;87;Speed;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;235;196.8166,-2448.604;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.01;False;4;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;250;-2299.656,-4851.629;Float;False;Constant;_Vector1;Vector 1;7;0;Create;True;0;0;False;0;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;125;-1445.725,529.5779;Float;False;2;0;FLOAT;10;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;249;-2439.943,-4683.632;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;248;-2620.909,-4610.89;Float;False;Constant;_Float3;Float 3;7;0;Create;True;0;0;False;0;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;240;387.2124,-3815.871;Float;False;237;Normal;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;140;-20.58231,188.2873;Float;False;Property;_Opacity;Opacity;7;0;Create;True;0;0;False;0;0.5;0.4;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;243;444.4131,-3201.872;Float;False;238;VertexOffset;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;129;-1934.933,-194.2293;Float;False;Property;_Hologramcolor;Hologram color;2;0;Create;True;0;0;False;0;0.3973832,0.7720588,0.7410512,0;0.8901961,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;207;-491.7334,-2282.213;Float;False;Constant;_Float1;Float 1;7;0;Create;True;0;0;False;0;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;138;-245.6333,16.41553;Float;False;Property;_Intensity;Intensity;12;0;Create;True;0;0;False;0;1;10;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;153.7066,-47.43518;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;189;-1043.544,-3675.798;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-806.5319,566.8699;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;179;-1227.446,-3608.098;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;626.8187,-3839.321;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Océane/Holographique_Test;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;1;True;True;0;True;Transparent;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;147;0;144;0
WireConnection;147;1;145;0
WireConnection;153;0;150;0
WireConnection;153;1;149;0
WireConnection;162;0;155;0
WireConnection;154;0;147;0
WireConnection;158;0;153;0
WireConnection;169;0;157;0
WireConnection;173;0;159;0
WireConnection;173;1;158;0
WireConnection;174;0;163;0
WireConnection;160;0;151;0
WireConnection;160;1;152;0
WireConnection;181;0;165;0
WireConnection;172;0;160;0
WireConnection;177;0;168;0
WireConnection;177;1;173;0
WireConnection;175;0;170;0
WireConnection;188;0;176;0
WireConnection;188;1;177;0
WireConnection;188;2;175;0
WireConnection;183;0;171;0
WireConnection;183;1;172;0
WireConnection;187;0;182;0
WireConnection;184;0;153;0
WireConnection;195;0;170;0
WireConnection;190;0;184;0
WireConnection;190;1;186;0
WireConnection;190;2;188;0
WireConnection;190;3;176;0
WireConnection;185;0;180;0
WireConnection;185;1;183;0
WireConnection;191;3;187;0
WireConnection;192;1;185;0
WireConnection;198;0;191;0
WireConnection;196;0;195;0
WireConnection;196;2;190;0
WireConnection;196;3;176;0
WireConnection;211;0;196;0
WireConnection;199;0;192;0
WireConnection;205;0;200;0
WireConnection;205;1;203;0
WireConnection;212;0;210;0
WireConnection;213;0;205;0
WireConnection;213;1;202;0
WireConnection;216;0;204;0
WireConnection;216;1;209;0
WireConnection;230;0;218;0
WireConnection;220;0;212;0
WireConnection;223;0;213;0
WireConnection;223;1;216;0
WireConnection;227;0;217;0
WireConnection;227;1;223;0
WireConnection;227;2;220;0
WireConnection;233;0;227;0
WireConnection;233;1;225;0
WireConnection;232;0;226;0
WireConnection;232;1;229;0
WireConnection;239;0;232;0
WireConnection;236;0;233;0
WireConnection;237;0;234;0
WireConnection;228;0;219;0
WireConnection;110;0;108;0
WireConnection;252;0;250;1
WireConnection;252;1;251;0
WireConnection;231;0;219;0
WireConnection;221;0;214;0
WireConnection;221;1;215;0
WireConnection;87;0;85;0
WireConnection;123;0;118;0
WireConnection;260;0;253;0
WireConnection;224;0;221;0
WireConnection;132;0;256;0
WireConnection;105;0;102;0
WireConnection;105;1;100;0
WireConnection;109;1;105;0
WireConnection;134;0;133;0
WireConnection;134;1;131;0
WireConnection;238;0;235;0
WireConnection;137;0;135;0
WireConnection;137;1;134;0
WireConnection;251;0;249;0
WireConnection;95;0;93;0
WireConnection;215;0;208;0
WireConnection;215;1;207;0
WireConnection;254;0;253;1
WireConnection;254;1;253;2
WireConnection;256;1;260;0
WireConnection;178;0;166;0
WireConnection;178;1;166;0
WireConnection;257;0;253;0
WireConnection;270;0;244;0
WireConnection;270;1;269;0
WireConnection;118;0;113;0
WireConnection;127;0;123;0
WireConnection;127;1;125;0
WireConnection;194;1;189;0
WireConnection;268;0;226;4
WireConnection;136;0;129;0
WireConnection;102;0;95;0
WireConnection;102;1;96;0
WireConnection;113;0;109;0
WireConnection;113;1;110;0
WireConnection;235;0;224;0
WireConnection;235;3;231;0
WireConnection;235;4;228;0
WireConnection;125;1;119;0
WireConnection;249;0;247;0
WireConnection;249;1;248;0
WireConnection;141;0;137;0
WireConnection;141;1;138;0
WireConnection;189;0;178;0
WireConnection;189;1;179;0
WireConnection;139;0;127;0
WireConnection;139;1;142;0
WireConnection;179;0;164;1
WireConnection;179;1;167;0
WireConnection;0;0;241;0
WireConnection;0;1;240;0
WireConnection;0;2;242;0
WireConnection;0;9;270;0
ASEEND*/
//CHKSM=2C2B2E86C90D0ED4A4E58BCE89CEAF9A38AB458A