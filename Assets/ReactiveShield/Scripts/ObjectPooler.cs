using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Bansi.ReactiveShield
{
    public class ObjectPooler
    {
        protected Stack<GameObject> _freeInstances = new Stack<GameObject>();
        protected GameObject _original = null;
        protected Transform _parent = null;

        public int NumberOfElements { get { return _freeInstances.Count; } }

        public virtual void InitObjectPool(GameObject objectPrefab, int initialSize, Transform parent)
        {
            _original = objectPrefab;
            _freeInstances = new Stack<GameObject>(initialSize);
            _parent = parent;

            for (int i = 0; i < initialSize; ++i)
            {
                GameObject createdObject = Object.Instantiate(objectPrefab, _parent);
                Free(createdObject);
            }
        }

        public virtual GameObject Get(Vector3 position)
        {
            GameObject desiredObject = null;

            while(desiredObject == null)
            {
                desiredObject = _freeInstances.Count > 0 ? _freeInstances.Pop() : Object.Instantiate(_original, _parent);
            }

            desiredObject.SetActive(true);
            desiredObject.transform.position = position;

            return desiredObject;
        }

        public virtual GameObject GetAndReparent(Transform parent, Vector3 position)
        {
            GameObject desiredObject = null;

            while (desiredObject == null)
            {
                desiredObject = _freeInstances.Count > 0 ? _freeInstances.Pop() : Object.Instantiate(_original, _parent);
            }

            desiredObject.SetActive(true);
            desiredObject.transform.SetParent(parent);
            desiredObject.transform.position = position;

            return desiredObject;
        }

        public virtual void Free(GameObject objectForFreeing)
        {
            if(objectForFreeing == null)
            {
                return;
            }

            objectForFreeing.SetActive(false);

            if (!objectForFreeing.transform.parent.Equals(_parent))
            {
                objectForFreeing.transform.SetParent(_parent);
            }

            _freeInstances.Push(objectForFreeing);
        }

        public virtual void InstantiateAdditionalInstances(int amount)
        {
            for (int i = 0; i < amount; ++i)
            {
                GameObject createdObject = Object.Instantiate(_original, _parent);
                Free(createdObject);
            }
        }
    }
}