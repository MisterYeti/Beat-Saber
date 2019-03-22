using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.PostProcessing;
using VRTK;

public enum COLOR
{
    RED,
    BLUE
};

public class Saber : MonoBehaviour
{

    public COLOR Color;
    private Spawner Spawner;
    private PostProcessingInGame PPInGame;
    private Scoring scoring;


    private void Start()
    {

        Spawner = FindObjectOfType<Spawner>();
        scoring = FindObjectOfType<Scoring>();
        PPInGame = PostProcessingInGame.Instance;

        if (Color == COLOR.RED)
            controllerReference = VRTK_DeviceFinder.GetControllerReferenceLeftHand();
        else
            controllerReference = VRTK_DeviceFinder.GetControllerReferenceRightHand();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "cube" || other.gameObject.tag == "point")
        {
            if (IsValid(other.gameObject))
            {
                if (!Spawner.dropEffect)
                    PPInGame.Success();

                scoring.CubeDestroyed();
                Destroy(other.transform.parent.gameObject);

            }
            else
            {
                PPInGame.Fail();
                scoring.CubeMissed();

                if (other.transform.parent && other.transform.parent.GetComponent<Cube>())
                    Destroy(other.transform.parent.gameObject);
                else
                    Destroy(other.gameObject);
            }
        }
    }



    private bool CheckColor(GameObject cube)
    {
        if (cube.transform.parent && cube.transform.parent.GetComponent<Cube>())
        {
            if (cube.gameObject.transform.parent.GetComponent<Cube>().Color == Color)
            {
                return true;
            }
            else
                return false;
        }
        else if (cube.gameObject.GetComponent<Cube>().Color == Color)
        {
            return true;
        }

        return false;
    }

    private bool IsValid(GameObject cube)
    {
        if (CheckColor(cube.gameObject))
        {
            if (cube.gameObject.tag == "cube")
            {
                return false;
            }
            else if (cube.gameObject.tag == "point")
            {
                return true;
            }
        }
        return false;
    }

}
