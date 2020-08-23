using UnityEngine;

namespace Bansi.ReactiveShield
{
    public class MissileShooter : MonoBehaviour
    {
        [Header("References")]
        [SerializeField] private GameObject _missilePrefab = null;

        [Header("Options")]
        [SerializeField] private int _numberOfMissilesForPooling = 5;
        [SerializeField] private float _minMissileSpeed = 20f;
        [SerializeField] private float _maxMissileSpeed = 40f;
        [SerializeField] private float _minDelayBetweenShots = 1f;
        [SerializeField] private float _maxDelayBetweenShots = 2f;
        [SerializeField] private float _minStartRotationOffset = -10f;
        [SerializeField] private float _maxStartRotationOffset = 10f;

        private ObjectPooler _missilesObjectPooler = null;
        private float _missileDelayTimer = 0f;
        private float _delayForNextShot = 0f;

        private void Start()
        {
            _missilesObjectPooler = new ObjectPooler();
            _missilesObjectPooler.InitObjectPool(_missilePrefab, _numberOfMissilesForPooling, transform);

            UpdateDelay();
        }

        private void Update()
        {
            if(_missileDelayTimer < _delayForNextShot)
            {
                _missileDelayTimer += Time.deltaTime;
                return;
            }

            UpdateDelay();
            _missileDelayTimer = 0f;
            FireMissile();
        }

        private void FireMissile()
        {
            GameObject missileObject = _missilesObjectPooler.Get(transform.position);
            missileObject.transform.localEulerAngles = Vector3.right * Random.Range(_minStartRotationOffset, _maxStartRotationOffset);
            Missile missile = missileObject.GetComponent<Missile>();
            missile.InitializeMissile(Random.Range(_minMissileSpeed, _maxMissileSpeed), OnMissileCollidedWithShield);
        }

        private void UpdateDelay()
        {
            _delayForNextShot = Random.Range(_minDelayBetweenShots, _maxDelayBetweenShots);
        }

        private void OnMissileCollidedWithShield(GameObject missile)
        {
            _missilesObjectPooler.Free(missile);
        }
    }
}