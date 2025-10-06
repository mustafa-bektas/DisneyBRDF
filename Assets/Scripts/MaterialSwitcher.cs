using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;
using TMPro;

public class MaterialSwitcher : MonoBehaviour
{
    [Header("References")]
    [Tooltip("The sphere that will display the materials")]
    public Renderer targetRenderer;
    
    [Header("Materials")]
    [Tooltip("List of Disney BRDF materials to cycle through")]
    public List<Material> disneyMaterials = new List<Material>();
    
    [Header("UI References")]
    public TMP_Text materialNameText;
    public TMP_Text materialDescriptionText;
    
    [Header("Settings")]
    [Tooltip("Time in seconds before auto-switching to next material")]
    public float autoSwitchDelay = 5f;
    
    [Tooltip("Enable automatic material switching")]
    public bool autoSwitch = true;
    
    // Private variables
    private int currentMaterialIndex = 0;
    private float timer = 0f;
    
    private Dictionary<string, string> materialDescriptions = new Dictionary<string, string>()
    {
        { "Disney_Gold", "Metallic: 1.0 | Roughness: 0.2\nHigh metallic value with low roughness creates mirror-like reflections typical of polished gold." },
        { "Disney_BrushedAluminum", "Metallic: 1.0 | Anisotropic: 0.8\nAnisotropic parameter creates directional highlights simulating brushed metal surface." },
        { "Disney_RedPlastic", "Metallic: 0.0 | Roughness: 0.4\nDielectric material with moderate roughness. Notice the colored diffuse reflection." },
        { "Disney_Velvet", "Sheen: 1.0 | Roughness: 0.9\nHigh sheen creates soft rim lighting at grazing angles, perfect for fabric materials." },
        { "Disney_CarPaint", "Clearcoat: 1.0 | Metallic: 0.8\nClearcoat layer adds secondary specular lobe, simulating automotive paint." },
        { "Disney_Wood", "Roughness: 0.7 | Clearcoat: 0.3\nCombination of diffuse and subtle clearcoat mimics varnished wood." }
    };
    
    void Start()
    {
        if (disneyMaterials.Count == 0)
        {
            Debug.LogError("No materials assigned to MaterialSwitcher!");
            return;
        }
        
        ApplyMaterial(0);
    }
    
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.RightArrow) || Input.GetKeyDown(KeyCode.D))
        {
            NextMaterial();
        }
        else if (Input.GetKeyDown(KeyCode.LeftArrow) || Input.GetKeyDown(KeyCode.A))
        {
            PreviousMaterial();
        }
        
        if (autoSwitch)
        {
            timer += Time.deltaTime;
            if (timer >= autoSwitchDelay)
            {
                NextMaterial();
                timer = 0f;
            }
        }
    }
    
    public void NextMaterial()
    {
        currentMaterialIndex = (currentMaterialIndex + 1) % disneyMaterials.Count;
        ApplyMaterial(currentMaterialIndex);
        timer = 0f;
    }
    
    public void PreviousMaterial()
    {
        currentMaterialIndex--;
        if (currentMaterialIndex < 0)
            currentMaterialIndex = disneyMaterials.Count - 1;
        
        ApplyMaterial(currentMaterialIndex);
        timer = 0f;
    }
    
    void ApplyMaterial(int index)
    {
        if (index < 0 || index >= disneyMaterials.Count)
            return;
        
        Material mat = disneyMaterials[index];
        targetRenderer.material = mat;
        
        if (materialNameText != null)
        {
            materialNameText.text = mat.name.Replace("Disney_", "");
        }
        
        if (materialDescriptionText != null && materialDescriptions.ContainsKey(mat.name))
        {
            materialDescriptionText.text = materialDescriptions[mat.name];
        }
        
        Debug.Log($"Switched to material: {mat.name}");
    }
    
    public void SwitchToMaterial(int index)
    {
        if (index >= 0 && index < disneyMaterials.Count)
        {
            currentMaterialIndex = index;
            ApplyMaterial(index);
            timer = 0f;
        }
    }
}