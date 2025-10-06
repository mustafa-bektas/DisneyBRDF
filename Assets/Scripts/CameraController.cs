using UnityEngine;

public class CameraController : MonoBehaviour
{
    public Transform target;
    public float orbitSpeed = 5f;
    public float distance = 8f;
    public float height = 3f;
    public float lookAtHeight = 1.5f;
    
    void Update()
    {
        float angle = Time.time * orbitSpeed;
        
        Vector3 position = new Vector3(
            Mathf.Sin(angle * Mathf.Deg2Rad) * distance,
            height,
            Mathf.Cos(angle * Mathf.Deg2Rad) * distance
        );
        
        transform.position = position;
        transform.LookAt(target.position + Vector3.up * lookAtHeight);
    }
}