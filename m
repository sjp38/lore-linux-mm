Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1FF878E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 13:36:07 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id f24so19413604ioh.21
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 10:36:07 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t17sor2807537jad.10.2018.12.19.10.36.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Dec 2018 10:36:05 -0800 (PST)
MIME-Version: 1.0
References: <CABXGCsPu3g8WZXV1RpggLFuL3bgofmXMs1SiPyYnPyEOW7t3Dg@mail.gmail.com>
 <24702c72-cc06-1b54-0ab9-6d2409362c27@amd.com> <CABXGCsMPjKnCb7hpuenL5q3_HJgoGW=VB9FRrBpJsZMtA7LxpA@mail.gmail.com>
 <3ffe451b-1f17-23a5-985b-28d26fbaf7da@amd.com> <09781f6e-5ea3-ccfd-1aa2-79941b089863@amd.com>
In-Reply-To: <09781f6e-5ea3-ccfd-1aa2-79941b089863@amd.com>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Wed, 19 Dec 2018 23:35:54 +0500
Message-ID: <CABXGCsPE36vkeycDQFhhsSQ0KhVxX4W=6Q5vt=hVzhZo3dZGWA@mail.gmail.com>
Subject: Re: After Vega 56/64 GPU hang I unable reboot system
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>
Cc: "Wentland, Harry" <Harry.Wentland@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>

On Tue, 18 Dec 2018 at 00:08, Grodzovsky, Andrey
<Andrey.Grodzovsky@amd.com> wrote:
>
> Please install UMR and dump gfx ring content and waves after the hang is
> happening.
>
> UMR at - https://cgit.freedesktop.org/amd/umr/
> Waves dump
> sudo umr -O verbose,halt_waves -wa
> GFX ring dump
> sudo umr -O verbose,follow -R gfx[.]
>
> Andrey
>

Thanks for respond.

What options should I specify in kernel command line?

On my setup `umr` terminated with message `Could not open ring debugfs
file` and crashes. But I am sure that debugfs enabled.

$ sudo umr -O verbose,halt_waves -wa
Cannot seek to MMIO address: Bad file descriptor
[ERROR]: Could not open ring debugfs fileSegmentation fault


# ls /sys/kernel/debug/dri/0/
 amdgpu_dm_dtn_log        amdgpu_ring_comp_1.1.0     amdgpu_vram_mm
 amdgpu_evict_gtt         amdgpu_ring_comp_1.1.1     amdgpu_wave
 amdgpu_evict_vram        amdgpu_ring_comp_1.2.0     clients
 amdgpu_fence_info        amdgpu_ring_comp_1.2.1     crtc-0
 amdgpu_firmware_info     amdgpu_ring_comp_1.3.0     crtc-1
 amdgpu_gca_config        amdgpu_ring_comp_1.3.1     crtc-2
 amdgpu_gds_mm            amdgpu_ring_gfx            crtc-3
 amdgpu_gem_info          amdgpu_ring_kiq_2.1.0      crtc-4
 amdgpu_gpr               amdgpu_ring_sdma0          crtc-5
 amdgpu_gpu_recover       amdgpu_ring_sdma1          DP-1
 amdgpu_gtt_mm           'amdgpu_ring_uvd<0>'        DP-2
 amdgpu_gws_mm           'amdgpu_ring_uvd_enc0<0>'   DP-3
 amdgpu_iomem            'amdgpu_ring_uvd_enc1<0>'   framebuffer
 amdgpu_oa_mm             amdgpu_ring_vce0           gem_names
 amdgpu_pm_info           amdgpu_ring_vce1           HDMI-A-1
 amdgpu_regs              amdgpu_ring_vce2           HDMI-A-2
 amdgpu_regs_didt         amdgpu_sa_info             HDMI-A-3
 amdgpu_regs_pcie         amdgpu_sensors             internal_clients
 amdgpu_regs_smc          amdgpu_test_ib             name
 amdgpu_ring_comp_1.0.0   amdgpu_vbios               state
 amdgpu_ring_comp_1.0.1   amdgpu_vram                ttm_page_pool




--
Best Regards,
Mike Gavrilov.
