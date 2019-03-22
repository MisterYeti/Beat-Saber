// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Océane/Multipass-transparence"
{
	Properties
	{
		_DistortionAmount("Distortion Amount", Range( 0 , 0.1)) = 0.292
		_DepthFadeDistance("Depth Fade Distance", Float) = 0
		_TextureSample1("Texture Sample 1", 2D) = "bump" {}
		_TimeScale("Time Scale", Float) = 0
		_ForcefieldTint("Forcefield Tint", Color) = (0,0,0,0)
		_IntersectionColor("Intersection Color", Color) = (0.4338235,0.4377282,1,0)
		_FresnelPower("Fresnel Power", Float) = 0
		_FresnelScale("Fresnel Scale", Float) = 0
	}
	
	SubShader
	{
		LOD 100
		
		Pass
		{
			Name "First"
			Tags { "RenderType"="Opaque" }
			CGINCLUDE
			#pragma target 3.0
			ENDCG
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Back
			ColorMask RGBA
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			

			struct appdata
			{
				float4 vertex : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord : TEXCOORD0;
			};

			uniform float4 _IntersectionColor;
			uniform sampler2D _CameraDepthTexture;
			uniform float _DepthFadeDistance;
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord = screenPos;
				
				
				v.vertex.xyz +=  float3(0,0,0) ;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				fixed4 finalColor;
				float4 IntersectionColor102 = _IntersectionColor;
				float4 screenPos = i.ase_texcoord;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth112 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( screenPos ))));
				float distanceDepth112 = abs( ( screenDepth112 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthFadeDistance ) );
				float SaturatedDepthFade116 = saturate( distanceDepth112 );
				float4 appendResult120 = (float4((IntersectionColor102).rgb , ( 1.0 - SaturatedDepthFade116 )));
				
				
				finalColor = appendResult120;
				return finalColor;
			}
			ENDCG
		}

		GrabPass{ }

		Pass
		{
			Name "Second"
			Tags { "RenderType"="Opaque" }
			CGINCLUDE
			#pragma target 3.0
			ENDCG
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Back
			ColorMask RGBA
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "UnityStandardUtils.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord : TEXCOORD0;
				float3 ase_normal : NORMAL;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
			};

			uniform sampler2D _GrabTexture;
			uniform float _DistortionAmount;
			uniform sampler2D _TextureSample1;
			uniform float _TimeScale;
			uniform float4 _ForcefieldTint;
			uniform float4 _IntersectionColor;
			uniform float _FresnelScale;
			uniform float _FresnelPower;
			uniform sampler2D _CameraDepthTexture;
			uniform float _DepthFadeDistance;
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
			
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.ase_texcoord2.xyz = ase_worldPos;
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				
				v.vertex.xyz +=  float3(0,0,0) ;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				fixed4 finalColor;
				float2 uv91 = i.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float mulTime93 = _Time.y * _TimeScale;
				float cos95 = cos( mulTime93 );
				float sin95 = sin( mulTime93 );
				float2 rotator95 = mul( uv91 - float2( 0.5,0.5 ) , float2x2( cos95 , -sin95 , sin95 , cos95 )) + float2( 0.5,0.5 );
				float4 screenPos = i.ase_texcoord1;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float4 screenColor103 = tex2D( _GrabTexture, ( float4( UnpackScaleNormal( tex2D( _TextureSample1, rotator95 ), _DistortionAmount ) , 0.0 ) + ase_grabScreenPosNorm ).xy );
				float4 IntersectionColor102 = _IntersectionColor;
				float3 ase_worldPos = i.ase_texcoord2.xyz;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(ase_worldPos);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord3.xyz;
				float fresnelNdotV104 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode104 = ( 0.0 + _FresnelScale * pow( 1.0 - fresnelNdotV104, _FresnelPower ) );
				float4 lerpResult114 = lerp( ( float4( (screenColor103).rgb , 0.0 ) * _ForcefieldTint ) , ( IntersectionColor102 * fresnelNode104 ) , fresnelNode104);
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth112 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( screenPos ))));
				float distanceDepth112 = abs( ( screenDepth112 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthFadeDistance ) );
				float SaturatedDepthFade116 = saturate( distanceDepth112 );
				float4 appendResult89 = (float4((lerpResult114).rgb , SaturatedDepthFade116));
				
				
				finalColor = appendResult89;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16200
1927;24;1536;1014;3754.751;664.2553;4.379225;True;False
Node;AmplifyShaderEditor.CommentaryNode;85;-2157.479,-107.5054;Float;False;1820.48;460.2398;;13;110;109;108;103;101;97;96;95;94;93;92;91;90;Calculate and apply Distortion;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;90;-2107.479,198.4948;Float;False;Property;_TimeScale;Time Scale;3;0;Create;True;0;0;False;0;0;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;93;-1947.479,198.4948;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;92;-1947.479,70.49472;Float;False;Constant;_Vector0;Vector 0;-1;0;Create;True;0;0;False;0;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;91;-1995.479,-57.50541;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;86;-819.9849,978.7614;Float;False;1268.871;416.1864;;9;121;120;119;116;115;112;106;102;100;First Pass only renders intersection;1,1,1,1;0;0
Node;AmplifyShaderEditor.RotatorNode;95;-1723.48,22.49467;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-1723.48,150.4947;Float;False;Property;_DistortionAmount;Distortion Amount;0;0;Create;True;0;0;False;0;0.292;0.052;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;96;-1371.48,166.4947;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;100;-465.9854,1031.513;Float;False;Property;_IntersectionColor;Intersection Color;5;0;Create;True;0;0;False;0;0.4338235,0.4377282,1,0;0.5849056,0.5849056,0.5849056,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;97;-1435.48,-41.50543;Float;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;False;0;None;dd2fd2df93418444c8e280f1d34deeb5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;87;-1024.143,447.4623;Float;False;752.7268;415.7021;;5;107;105;104;99;98;Adding Rim effect;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;101;-1115.479,54.49469;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;99;-958.1432,643.7497;Float;False;Property;_FresnelScale;Fresnel Scale;7;0;Create;True;0;0;False;0;0;-0.46;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;98;-974.1431,739.7497;Float;False;Property;_FresnelPower;Fresnel Power;6;0;Create;True;0;0;False;0;0;2.32;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;102;-225.984,1031.513;Float;False;IntersectionColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenColorNode;103;-969.5624,-20.11021;Float;False;Global;_GrabScreen0;Grab Screen 0;2;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;106;-797.9849,1292.513;Float;False;Property;_DepthFadeDistance;Depth Fade Distance;1;0;Create;True;0;0;False;0;0;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;104;-762.6243,610.1642;Float;True;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;-790.6832,505.4824;Float;False;102;IntersectionColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DepthFade;112;-557.985,1276.513;Float;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;109;-754.5162,-9.668125;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;-440.4173,497.4623;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;108;-770.5032,77.27475;Float;False;Property;_ForcefieldTint;Forcefield Tint;4;0;Create;True;0;0;False;0;0,0,0,0;0.9122463,0.9392868,0.9433962,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;115;-309.9852,1271.513;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-514.5032,61.27472;Float;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;111;-246.443,461.6919;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;88;-153.705,254.5917;Float;False;668.4583;299.6378;;4;118;117;114;89;Combining everything through generated alphas;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;113;-263.2922,588.8334;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;114;-103.705,347.3759;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;116;-161.984,1239.513;Float;False;SaturatedDepthFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;73.88663,439.2295;Float;False;116;SaturatedDepthFade;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;118;104.5048,304.5917;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;89;344.7527,362.9997;Float;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.OneMinusNode;119;94.25664,1215.54;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;121;8.575806,1028.761;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;120;276.6317,1095.629;Float;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;126;944.867,802.236;Float;False;False;2;Float;ASEMaterialInspector;0;9;ASESampleTemplates/DoublePassUnlit;003dfa9c16768d048b74f75c088119d8;0;1;Second;2;False;False;False;False;False;False;False;False;False;False;False;0;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;;0;0;Standard;0;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;125;948.5704,916.5237;Float;False;True;2;Float;ASEMaterialInspector;0;9;Océane/Multipass-transparence;003dfa9c16768d048b74f75c088119d8;0;0;First;2;False;False;False;False;False;False;False;False;False;False;False;0;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;;0;0;Standard;0;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;138;-875.7419,2135.007;Float;False;830.728;358.1541;Comment;0;Animation Speed;1,1,1,1;0;0
WireConnection;93;0;90;0
WireConnection;95;0;91;0
WireConnection;95;1;92;0
WireConnection;95;2;93;0
WireConnection;97;1;95;0
WireConnection;97;5;94;0
WireConnection;101;0;97;0
WireConnection;101;1;96;0
WireConnection;102;0;100;0
WireConnection;103;0;101;0
WireConnection;104;2;99;0
WireConnection;104;3;98;0
WireConnection;112;0;106;0
WireConnection;109;0;103;0
WireConnection;107;0;105;0
WireConnection;107;1;104;0
WireConnection;115;0;112;0
WireConnection;110;0;109;0
WireConnection;110;1;108;0
WireConnection;111;0;107;0
WireConnection;113;0;104;0
WireConnection;114;0;110;0
WireConnection;114;1;111;0
WireConnection;114;2;113;0
WireConnection;116;0;115;0
WireConnection;118;0;114;0
WireConnection;89;0;118;0
WireConnection;89;3;117;0
WireConnection;119;0;116;0
WireConnection;121;0;102;0
WireConnection;120;0;121;0
WireConnection;120;3;119;0
WireConnection;126;0;89;0
WireConnection;125;0;120;0
ASEEND*/
//CHKSM=0CD0FCD3574F84BF195241BF1C59A6D3EB3E6CF8