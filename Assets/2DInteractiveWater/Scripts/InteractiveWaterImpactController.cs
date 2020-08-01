using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Bansi.InteractiveWater 
{
    [RequireComponent(typeof(Renderer))]
    public class InteractiveWaterImpactController : MonoBehaviour
    {
        private const int MAX_NUMBER_OF_ANIMATIONS = 4;
        private const int NUMBER_OF_ANIMATION_FRAMES = 256;
        private const float TIME_BETWEEN_ANIMATION_FRAMES = 0.00833f;
        private const float WAVE_RADIUS = 5f;
        private const float WAVE_MAX_AMPLITUDE = 8f;

        private List<WaveAnimationInfo> _activeAnimations = new List<WaveAnimationInfo>();
        private Material _material = null;
        private Renderer _renderer = null;

        private void Start()
        {
            _renderer = GetComponent<Renderer>();
            _material = _renderer.material;

            _material.SetFloat(InteractiveWaterMaterialConstants.WAVE_WIDTH, WAVE_RADIUS);
            _material.SetFloat(InteractiveWaterMaterialConstants.WAVE_AMPLITUDE, WAVE_MAX_AMPLITUDE);
        }

        private void Update()
        {
            if (_activeAnimations.Count > 0)
            {
                UpdateAnimations();
                UpdateShader();
            }

            RemoveFinishedAnimations();
        }

        // Update animation frames so waves would animate correctly based on time spent from
        // impact of the object on the water surface
        private void UpdateAnimations()
        {
            for (int i = 0; i < _activeAnimations.Count; i++)
            {

                WaveAnimationInfo waveAnimation = _activeAnimations[i];
                if (Time.time - waveAnimation.LastFrameTime > TIME_BETWEEN_ANIMATION_FRAMES)
                {
                    waveAnimation.CurrentFrame++;
                    waveAnimation.LastFrameTime = Time.time;
                }

                _activeAnimations[i] = waveAnimation;
            }
        }

        // Based on updated animation values, update the shader so it would show the correct wave values
        private void UpdateShader()
        {
            float[] animationFrames = new float[MAX_NUMBER_OF_ANIMATIONS];
            float[] impactPoints = new float[MAX_NUMBER_OF_ANIMATIONS];

            Color isAnimationActive = new Color {
                r = _activeAnimations.Count >= 1 ? 1.0f : 0.0f,
                g = _activeAnimations.Count >= 2 ? 1.0f : 0.0f,
                b = _activeAnimations.Count >= 3 ? 1.0f : 0.0f,
                a = _activeAnimations.Count >= 4 ? 1.0f : 0.0f
            };

            Color animationTypes = new Color {
                r = _activeAnimations.Count >= 1 && _activeAnimations[0].WaveAnimationDirection == WaveAnimationDirection.Up ? 1.0f : 0.0f,
                g = _activeAnimations.Count >= 2 && _activeAnimations[1].WaveAnimationDirection == WaveAnimationDirection.Up ? 1.0f : 0.0f,
                b = _activeAnimations.Count >= 3 && _activeAnimations[2].WaveAnimationDirection == WaveAnimationDirection.Up ? 1.0f : 0.0f,
                a = _activeAnimations.Count >= 4 && _activeAnimations[3].WaveAnimationDirection == WaveAnimationDirection.Up ? 1.0f : 0.0f
            };

            Color waveAmplitudes = new Color
            {
                r = _activeAnimations.Count >= 1 ? _activeAnimations[0].AmplitudePercentage : 0.0f,
                g = _activeAnimations.Count >= 2 ? _activeAnimations[1].AmplitudePercentage : 0.0f,
                b = _activeAnimations.Count >= 3 ? _activeAnimations[2].AmplitudePercentage : 0.0f,
                a = _activeAnimations.Count >= 4 ? _activeAnimations[3].AmplitudePercentage : 0.0f,
            };

            for (int i = 0; i < MAX_NUMBER_OF_ANIMATIONS; i++)
            {
                if (i < _activeAnimations.Count)
                {
                    animationFrames[i] = _activeAnimations[i].CurrentFrame;
                    impactPoints[i] = _activeAnimations[i].ImpactPositionX;
                }
                else
                {
                    // Just default values
                    animationFrames[i] = 0;
                    impactPoints[i] = 0;
                }
            }

            _material.SetFloatArray(InteractiveWaterMaterialConstants.ANIMATION_FRAME, animationFrames);
            _material.SetFloatArray(InteractiveWaterMaterialConstants.IMPACT_POINTS, impactPoints);
            _material.SetColor(InteractiveWaterMaterialConstants.IS_IMPACT_POINT_ACTIVE, isAnimationActive);
            _material.SetColor(InteractiveWaterMaterialConstants.ANIMATION_TYPES, animationTypes);
            _material.SetColor(InteractiveWaterMaterialConstants.AMPLITUDE_PERCENTAGES, waveAmplitudes);
        }

        private void RemoveFinishedAnimations()
        {
            for (int i = 0; i < _activeAnimations.Count; i++)
            {
                if (_activeAnimations[i].CurrentFrame == NUMBER_OF_ANIMATION_FRAMES - 1)
                {
                    _activeAnimations.RemoveAt(i);
                    i--;
                }
            }
        }

        public void AddImpact(Vector3 impactPoint, WaveAnimationDirection waveAnimationDirection, float amplitudePercentage)
        {
            if (_activeAnimations.Count == MAX_NUMBER_OF_ANIMATIONS)
            {
                // Already max number of waves on chunk, remove oldest wave
                _activeAnimations.RemoveAt(0);
            }

            _activeAnimations.Add(new WaveAnimationInfo
            {
                ImpactPositionX = impactPoint.x,
                AmplitudePercentage = amplitudePercentage,
                CurrentFrame = 0,
                LastFrameTime = 0f,
                WaveAnimationDirection = waveAnimationDirection
            });
        }
    }
}
