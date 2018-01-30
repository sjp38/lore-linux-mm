Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 489946B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 04:24:17 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v14so12138945wmd.3
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 01:24:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z12sor6933423edm.47.2018.01.30.01.24.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jan 2018 01:24:16 -0800 (PST)
Date: Tue, 30 Jan 2018 10:24:13 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH 4/4] drm/amdgpu: Use drm_oom_badness for amdgpu.
Message-ID: <20180130092413.GD25930@phenom.ffwll.local>
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
 <1516294072-17841-5-git-send-email-andrey.grodzovsky@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1516294072-17841-5-git-send-email-andrey.grodzovsky@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Grodzovsky <andrey.grodzovsky@amd.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org, Christian.Koenig@amd.com

On Thu, Jan 18, 2018 at 11:47:52AM -0500, Andrey Grodzovsky wrote:
> Signed-off-by: Andrey Grodzovsky <andrey.grodzovsky@amd.com>
> ---
>  drivers/gpu/drm/amd/amdgpu/amdgpu_drv.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_drv.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_drv.c
> index 46a0c93..6a733cdc8 100644
> --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_drv.c
> +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_drv.c
> @@ -828,6 +828,7 @@ static const struct file_operations amdgpu_driver_kms_fops = {
>  #ifdef CONFIG_COMPAT
>  	.compat_ioctl = amdgpu_kms_compat_ioctl,
>  #endif
> +	.oom_file_badness = drm_oom_badness,

Would be neat if we could roll this out for all gem drivers (once it's no
longer an RFC ofc).
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
