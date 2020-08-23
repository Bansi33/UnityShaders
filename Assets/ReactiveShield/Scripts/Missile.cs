using UnityEngine;

namespace Bansi.ReactiveShield
{
    public class Missile : MonoBehaviour
    {
        private float _movementSpeed = 0f;
        private System.Action<GameObject> _onCollisionCallback = null;

        private void Update()
        {
            transform.position += transform.forward * _movementSpeed * Time.deltaTime;
        }

        private void OnCollisionEnter(Collision collision)
        {
            _onCollisionCallback?.Invoke(this.gameObject);
        }

        public void InitializeMissile(float missileSpeed, System.Action<GameObject> onCollisionCallback)
        {
            _movementSpeed = missileSpeed;
            _onCollisionCallback = onCollisionCallback;
        }        
    }
}