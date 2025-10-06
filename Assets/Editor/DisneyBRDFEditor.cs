using UnityEngine;
using UnityEditor;

public class DisneyBRDFEditor : ShaderGUI
{
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        Material targetMat = materialEditor.target as Material;
        
        GUILayout.Label("Base Parameters", EditorStyles.boldLabel);
        MaterialProperty baseColor = FindProperty("_BaseColor", properties);
        materialEditor.ShaderProperty(baseColor, "Base Color");
        
        MaterialProperty metallic = FindProperty("_Metallic", properties);
        materialEditor.ShaderProperty(metallic, "Metallic");
        
        MaterialProperty roughness = FindProperty("_Roughness", properties);
        materialEditor.ShaderProperty(roughness, "Roughness");
        
        EditorGUILayout.Space();
        GUILayout.Label("Advanced Parameters", EditorStyles.boldLabel);
        
        MaterialProperty specular = FindProperty("_Specular", properties);
        materialEditor.ShaderProperty(specular, "Specular");
        
        MaterialProperty specularTint = FindProperty("_SpecularTint", properties);
        materialEditor.ShaderProperty(specularTint, "Specular Tint");
        
        MaterialProperty anisotropic = FindProperty("_Anisotropic", properties);
        materialEditor.ShaderProperty(anisotropic, "Anisotropic");
        
        MaterialProperty sheen = FindProperty("_Sheen", properties);
        materialEditor.ShaderProperty(sheen, "Sheen");
        
        MaterialProperty sheenTint = FindProperty("_SheenTint", properties);
        materialEditor.ShaderProperty(sheenTint, "Sheen Tint");
        
        MaterialProperty clearcoat = FindProperty("_Clearcoat", properties);
        materialEditor.ShaderProperty(clearcoat, "Clearcoat");
        
        MaterialProperty clearcoatGloss = FindProperty("_ClearcoatGloss", properties);
        materialEditor.ShaderProperty(clearcoatGloss, "Clearcoat Gloss");
        
        MaterialProperty subsurface = FindProperty("_Subsurface", properties);
        materialEditor.ShaderProperty(subsurface, "Subsurface");
    }
}