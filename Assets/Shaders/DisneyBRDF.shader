Shader "Custom/DisneyBRDF"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Subsurface ("Subsurface", Range(0,1)) = 0.0
        _Specular ("Specular", Range(0,1)) = 0.5
        _Roughness ("Roughness", Range(0,1)) = 0.5
        _SpecularTint ("Specular Tint", Range(0,1)) = 0.0
        _Anisotropic ("Anisotropic", Range(0,1)) = 0.0
        _Sheen ("Sheen", Range(0,1)) = 0.0
        _SheenTint ("Sheen Tint", Range(0,1)) = 0.5
        _Clearcoat ("Clearcoat", Range(0,1)) = 0.0
        _ClearcoatGloss ("Clearcoat Gloss", Range(0,1)) = 1.0
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        CGPROGRAM
        #pragma surface surf DisneyBRDF fullforwardshadows
        #pragma target 3.0
        
        float4 _BaseColor;
        float _Metallic;
        float _Subsurface;
        float _Specular;
        float _Roughness;
        float _SpecularTint;
        float _Anisotropic;
        float _Sheen;
        float _SheenTint;
        float _Clearcoat;
        float _ClearcoatGloss;
        
        struct Input
        {
            float2 uv_MainTex;
        };
        
        float sqr(float x) { return x * x; }
        
        float SchlickFresnel(float u)
        {
            float m = clamp(1.0 - u, 0.0, 1.0);
            float m2 = m * m;
            return m2 * m2 * m; // pow(m,5)
        }
        
        float GTR1(float NdotH, float a)
        {
            if (a >= 1.0) return 1.0 / UNITY_PI;
            float a2 = a * a;
            float t = 1.0 + (a2 - 1.0) * NdotH * NdotH;
            return (a2 - 1.0) / (UNITY_PI * log(a2) * t);
        }
        
        float GTR2(float NdotH, float a)
        {
            float a2 = a * a;
            float t = 1.0 + (a2 - 1.0) * NdotH * NdotH;
            return a2 / (UNITY_PI * t * t);
        }
        
        float GTR2_aniso(float NdotH, float HdotX, float HdotY, float ax, float ay)
        {
            return 1.0 / (UNITY_PI * ax * ay * sqr(sqr(HdotX / ax) + sqr(HdotY / ay) + NdotH * NdotH));
        }
        
        float smithG_GGX(float NdotV, float alphaG)
        {
            float a = alphaG * alphaG;
            float b = NdotV * NdotV;
            return 1.0 / (NdotV + sqrt(a + b - a * b));
        }
        
        float smithG_GGX_aniso(float NdotV, float VdotX, float VdotY, float ax, float ay)
        {
            return 1.0 / (NdotV + sqrt(sqr(VdotX * ax) + sqr(VdotY * ay) + sqr(NdotV)));
        }
        
        float3 mon2lin(float3 x)
        {
            return float3(pow(x.r, 2.2), pow(x.g, 2.2), pow(x.b, 2.2));
        }
        
        float3 DisneyBRDF(float3 L, float3 V, float3 N, float3 X, float3 Y)
        {
            float NdotL = dot(N, L);
            float NdotV = dot(N, V);
            if (NdotL < 0.0 || NdotV < 0.0) return float3(0, 0, 0);
            
            float3 H = normalize(L + V);
            float NdotH = dot(N, H);
            float LdotH = dot(L, H);
            
            float3 Cdlin = mon2lin(_BaseColor.rgb);
            float Cdlum = 0.3 * Cdlin.r + 0.6 * Cdlin.g + 0.1 * Cdlin.b;
            
            float3 Ctint = Cdlum > 0.0 ? Cdlin / Cdlum : float3(1, 1, 1);
            float3 Cspec0 = lerp(_Specular * 0.08 * lerp(float3(1, 1, 1), Ctint, _SpecularTint), Cdlin, _Metallic);
            float3 Csheen = lerp(float3(1, 1, 1), Ctint, _SheenTint);
            
            float FL = SchlickFresnel(NdotL);
            float FV = SchlickFresnel(NdotV);
            float Fd90 = 0.5 + 2.0 * LdotH * LdotH * _Roughness;
            float Fd = lerp(1.0, Fd90, FL) * lerp(1.0, Fd90, FV);
            
            float Fss90 = LdotH * LdotH * _Roughness;
            float Fss = lerp(1.0, Fss90, FL) * lerp(1.0, Fss90, FV);
            float ss = 1.25 * (Fss * (1.0 / (NdotL + NdotV) - 0.5) + 0.5);
            
            float aspect = sqrt(1.0 - _Anisotropic * 0.9);
            float ax = max(0.001, sqr(_Roughness) / aspect);
            float ay = max(0.001, sqr(_Roughness) * aspect);
            float Ds = GTR2_aniso(NdotH, dot(H, X), dot(H, Y), ax, ay);
            float FH = SchlickFresnel(LdotH);
            float3 Fs = lerp(Cspec0, float3(1, 1, 1), FH);
            float Gs = smithG_GGX_aniso(NdotL, dot(L, X), dot(L, Y), ax, ay);
            Gs *= smithG_GGX_aniso(NdotV, dot(V, X), dot(V, Y), ax, ay);
            
            float3 Fsheen = FH * _Sheen * Csheen;
            
            float Dr = GTR1(NdotH, lerp(0.1, 0.001, _ClearcoatGloss));
            float Fr = lerp(0.04, 1.0, FH);
            float Gr = smithG_GGX(NdotL, 0.25) * smithG_GGX(NdotV, 0.25);
            
            return ((1.0 / UNITY_PI) * lerp(Fd, ss, _Subsurface) * Cdlin + Fsheen) * (1.0 - _Metallic)
                + Gs * Fs * Ds + 0.25 * _Clearcoat * Gr * Fr * Dr;
        }
        
        half4 LightingDisneyBRDF(SurfaceOutput s, half3 viewDir, UnityGI gi)
        {
            float3 N = normalize(s.Normal);
            float3 V = normalize(viewDir);
            float3 L = normalize(gi.light.dir);
            
            // need tangent frame for anisotropic
            float3 up = abs(N.z) < 0.999 ? float3(0, 0, 1) : float3(1, 0, 0);
            float3 X = normalize(cross(up, N));
            float3 Y = cross(N, X);
            
            float3 brdf = DisneyBRDF(L, V, N, X, Y);
            
            float NdotL = saturate(dot(N, L));
            float3 directLighting = brdf * gi.light.color * NdotL;
            
            float3 R = reflect(-V, N);
            float roughness = _Roughness;
            float mip = roughness * 7.0;
            
            half3 reflectionColor = DecodeHDR(
                UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, R, mip),
                unity_SpecCube0_HDR
            );
            
            // recalc fresnel for env map - was getting wrong reflection amount without this
            float3 Cdlin = mon2lin(s.Albedo);
            float Cdlum = 0.3 * Cdlin.r + 0.6 * Cdlin.g + 0.1 * Cdlin.b;
            float3 Ctint = Cdlum > 0.0 ? Cdlin / Cdlum : float3(1, 1, 1);

            float3 F0_dielectric = _Specular * 0.08 * lerp(float3(1, 1, 1), Ctint, _SpecularTint);
            float3 F0 = lerp(F0_dielectric, Cdlin, _Metallic);

            float NdotV = saturate(dot(N, V));
            float3 F = F0 + (1.0 - F0) * pow(1.0 - NdotV, 5.0);

            // metallic blend or it looks wrong
            float3 indirectSpecular = reflectionColor * F * lerp(0.04, 1.0, _Metallic);

            float3 indirectDiffuse = gi.indirect.diffuse * s.Albedo * (1.0 - _Metallic);
            
            float3 color = directLighting + indirectSpecular + indirectDiffuse;
            
            half4 c;
            c.rgb = color;
            c.a = 1.0;
            return c;
        }
        
        void LightingDisneyBRDF_GI(SurfaceOutput s, UnityGIInput data, inout UnityGI gi)
        {
            gi = UnityGlobalIllumination(data, 1.0, s.Normal);

            Unity_GlossyEnvironmentData g;
            g.roughness = _Roughness;
            g.reflUVW = reflect(-data.worldViewDir, s.Normal);
            
            gi.indirect.specular = UnityGI_IndirectSpecular(data, 1.0, g);
        }
        
        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = _BaseColor.rgb;
            o.Normal = float3(0, 0, 1);
        }
        
        ENDCG
    }
    FallBack "Diffuse"
    CustomEditor "DisneyBRDFEditor"
}