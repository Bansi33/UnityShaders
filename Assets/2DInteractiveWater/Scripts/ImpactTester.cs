using UnityEngine;

namespace Bansi.InteractiveWater
{
    public class ImpactTester : MonoBehaviour
    {
        [Header("References")]
        [SerializeField] private InteractiveWaterImpactController _interactiveWaterImpactController = null;
        [SerializeField] private float _waterMinX = -10f;
        [SerializeField] private float _waterMaxX = 10f;
        [SerializeField] private float _waveSize = 5f;
        [SerializeField] private Transform _impactPoint = null;

        private void Update()
        {
            if (Input.GetKeyDown(KeyCode.Space))
            {
                SpawnTestWave();
            }
        }

        private void SpawnTestWave()
        {
            float velocity = Random.Range(-1f, 1f);
            float amplitudePercentage = Random.Range(0f, 1f);

            if ((_waterMinX < (_impactPoint.position.x + _waveSize)) &&
               (_waterMaxX > (_impactPoint.position.x - _waveSize)))
            {
                _interactiveWaterImpactController.AddImpact(_impactPoint.position,
                    velocity > 0 ? WaveAnimationDirection.Up : WaveAnimationDirection.Down,
                    amplitudePercentage);
            }
        }
    }
}