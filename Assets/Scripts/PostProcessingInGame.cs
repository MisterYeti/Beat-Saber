using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.PostProcessing;

public class PostProcessingInGame : MonoBehaviour
{
    public static PostProcessingInGame Instance = null;   

    void Awake()
    {
        if (Instance == null)
            Instance = this;
        else if (Instance != this)
            Destroy(gameObject);
    }



    public PostProcessingBehaviour PostProcessingBehaviour;
    [HideInInspector] public PostProcessingProfile PostProcessingProfile;
    [HideInInspector] public ColorGradingModel.Settings gradient;
    [HideInInspector] public GrainModel.Settings grain;
    private Spawner spawner;

    private Coroutine FailLast, SuccessLast;
    private float period = 2.0f / 180.0f;

    void Start()
    {
        SettingUpPPVariables();
        ResetPostProcess();
        spawner = FindObjectOfType<Spawner>();

        StartCoroutine(EffectsTimingCoroutine());
    }


    private void SettingUpPPVariables()
    {
        PostProcessingProfile = PostProcessingBehaviour.profile;
        gradient = PostProcessingProfile.colorGrading.settings;
        grain = PostProcessingProfile.grain.settings;
    }

    private void ResetPostProcess()
    {
        gradient.basic.temperature = 0.0f;
        gradient.basic.hueShift = 0.0f;
        grain.intensity = 0.0f;

        PostProcessingProfile.grain.settings = grain;
        PostProcessingProfile.colorGrading.settings = gradient;
    }

    public void Fail()
    {
        if (FailLast != null)
            StopCoroutine(FailLast);

        FailLast = StartCoroutine(FailCoroutine());

    }

    public void Success()
    {
        if (SuccessLast != null)
            StopCoroutine(SuccessCoroutine());

        SuccessLast = StartCoroutine(SuccessCoroutine());

    }

    public IEnumerator FailCoroutine()
    {
        for (int i = 0; i < 10; i++)
        {
            grain.intensity += 0.1f;
            PostProcessingProfile.grain.settings = grain;
            yield return new WaitForSeconds(0.01f);
        }

        for (int i = 0; i < 10; i++)
        {
            grain.intensity -= 0.1f;
            PostProcessingProfile.grain.settings = grain;
            yield return new WaitForSeconds(0.03f);
        }

        grain.intensity = 0.0f;
        PostProcessingProfile.grain.settings = grain;
    }

    public IEnumerator SuccessCoroutine()
    {
        for (int i = 0; i < 10; i++)
        {
            gradient.basic.temperature -= 10.0f;
            PostProcessingProfile.colorGrading.settings = gradient;
            yield return new WaitForSeconds(0.01f);
        }

        for (int i = 0; i < 10; i++)
        {
            gradient.basic.temperature += 10.0f;
            PostProcessingProfile.colorGrading.settings = gradient;
            yield return new WaitForSeconds(0.03f);
        }
    }


    public IEnumerator EffectsTimingCoroutine()
    {
        spawner.dropEffect = false;
        fun = false;
        yield return new WaitForSeconds(48f);

        spawner.dropEffect = true;
        fun = true;
        yield return new WaitForSeconds(20f);

        spawner.dropEffect = false;
        gradient.basic.hueShift = 0f;
        PostProcessingProfile.colorGrading.settings = gradient;
        fun = false;
        yield return new WaitForSeconds(39f);

        spawner.dropEffect = true;
        fun = true;
        yield return new WaitForSeconds(40f);

        spawner.dropEffect = false;
        gradient.basic.hueShift = 0f;
        PostProcessingProfile.colorGrading.settings = gradient;
        fun = false;
        yield return new WaitForSeconds(38f);

        spawner.dropEffect = true;
        fun = true;
        yield return new WaitForSeconds(19f);

        spawner.dropEffect = false;
        gradient.basic.hueShift = 0f;
        PostProcessingProfile.colorGrading.settings = gradient;
        fun = false;



    }

    float timer;
    bool fun = false;

    private void Update()
    {
        if (fun)
        {
            if (timer > period)
            {
                
                gradient.basic.hueShift -= 1.0f;
                PostProcessingProfile.colorGrading.settings = gradient;

                timer -= period;
            }

            timer += Time.deltaTime;
        }
    }


}
