using UnityEngine;

namespace Bansi.ReactiveShield
{
    public class Shield : MonoBehaviour
    {
        private const int FIRST_CONTACT_INDEX = 0;
        private const int MAX_NUMBER_OF_IMPACT_POINTS = 16;
        private const float INITIAL_TIME_FROM_IMPACT = 0.0f;
        private const float MAX_NORMALISED_IMPACT_DURATION = 1.0f;

        private const string NUMBER_OF_ACTIVE_IMPACT_POINTS = "_NumberOfActiveImpactPoints";
        private const string IMPACT_POINTS_ARRAY = "_ImpactPoints";

        [Header("References")]
        [SerializeField] private Material _shieldMaterial = null;

        [Header("Options")]
        [SerializeField] private float _impactPointMaxDuration = 1.25f;

        private Vector4[] _impactPoints = new Vector4[MAX_NUMBER_OF_IMPACT_POINTS];
        private int _numberOfActiveImpactPoints = 0;

        private void OnCollisionEnter(Collision collision)
        {
            if(_numberOfActiveImpactPoints >= MAX_NUMBER_OF_IMPACT_POINTS)
            {
                return;
            }

            ContactPoint contactPoint = collision.contacts[FIRST_CONTACT_INDEX];
            Vector3 collisionPointInObjectSpace = transform.InverseTransformPoint(contactPoint.point);
            _impactPoints[_numberOfActiveImpactPoints] = new Vector4(collisionPointInObjectSpace.x,
                collisionPointInObjectSpace.y, collisionPointInObjectSpace.z, INITIAL_TIME_FROM_IMPACT);
            _numberOfActiveImpactPoints++;
        }

        private void OnDestroy()
        {
            ClearImpactPointsFromMaterial();
        }

        private void Update()
        {
            UpdateImpactPoints();
            SyncImpactPointsWithMaterial();
        }

        private void UpdateImpactPoints()
        {
            float incrementTime = Time.deltaTime / _impactPointMaxDuration;
            for(int i = 0; i < _numberOfActiveImpactPoints; i++)
            {
                // Update the normalised elapsed time from impact.
                Vector4 impactPoint = _impactPoints[i];
                impactPoint.w += incrementTime;

                // In case impact point has expired, move all impact points, which are behind it,
                // one step to the front of the array.
                if (impactPoint.w >= MAX_NORMALISED_IMPACT_DURATION)
                {

                    for(int j = i; j < MAX_NUMBER_OF_IMPACT_POINTS - 1; j++)
                    {
                        _impactPoints[j] = _impactPoints[j + 1];
                    }
                    _impactPoints[MAX_NUMBER_OF_IMPACT_POINTS - 1] = Vector4.zero;
                    _numberOfActiveImpactPoints--;
                    i--;
                    continue;
                }

                _impactPoints[i] = impactPoint;
            }
        }

        private void SyncImpactPointsWithMaterial()
        {
            _shieldMaterial.SetInt(NUMBER_OF_ACTIVE_IMPACT_POINTS, _numberOfActiveImpactPoints);
            _shieldMaterial.SetVectorArray(IMPACT_POINTS_ARRAY, _impactPoints);
        }

        private void ClearImpactPointsFromMaterial()
        {
            for(int i = 0; i < MAX_NUMBER_OF_IMPACT_POINTS; i++)
            {
                _impactPoints[i] = Vector4.zero;
            }

            _numberOfActiveImpactPoints = 0;
            SyncImpactPointsWithMaterial();
        }
    }
}