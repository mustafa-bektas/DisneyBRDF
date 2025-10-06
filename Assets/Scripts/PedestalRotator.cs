using UnityEngine;

public class PedestalRotator : MonoBehaviour
{
    [Header("Rotation Settings")]
    [Tooltip("Rotation speed in degrees per second")]
    public float rotationSpeed = 15f;
    
    [Tooltip("Rotate the entire pedestal system")]
    public bool autoRotate = true;
    
    void Update()
    {
        if (autoRotate)
        {
            transform.Rotate(Vector3.up, rotationSpeed * Time.deltaTime, Space.World);
        }
    }
}