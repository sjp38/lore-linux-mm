Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 442326B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 07:42:51 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id h5so7666847pgv.21
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 04:42:51 -0800 (PST)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0052.outbound.protection.outlook.com. [104.47.36.52])
        by mx.google.com with ESMTPS id p5si1362013pgn.197.2018.01.30.04.42.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 04:42:49 -0800 (PST)
Subject: Re: [PATCH 4/4] drm/amdgpu: Use drm_oom_badness for amdgpu.
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
 <1516294072-17841-5-git-send-email-andrey.grodzovsky@amd.com>
 <20180130092413.GD25930@phenom.ffwll.local>
From: Andrey Grodzovsky <Andrey.Grodzovsky@amd.com>
Message-ID: <1670268a-863f-2a95-fd1d-f59e5ebdfcb3@amd.com>
Date: Tue, 30 Jan 2018 07:42:46 -0500
MIME-Version: 1.0
In-Reply-To: <20180130092413.GD25930@phenom.ffwll.local>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org, Christian.Koenig@amd.com

That definitely what I planned, just didn't want to clutter the RFC with 
multiple repeated changes.

Thanks,

Andrey



On 01/30/2018 04:24 AM, Daniel Vetter wrote:
> On Thu, Jan 18, 2018 at 11:47:52AM -0500, Andrey Grodzovsky wrote:
>> Signed-off-by: Andrey Grodzovsky <andrey.grodzovsky@amd.com>
>> ---
>>   drivers/gpu/drm/amd/amdgpu/amdgpu_drv.c | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_drv.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_drv.c
>> index 46a0c93..6a733cdc8 100644
>> --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_drv.c
>> +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_drv.c
>> @@ -828,6 +828,7 @@ static const struct file_operations amdgpu_driver_kms_fops = {
>>   #ifdef CONFIG_COMPAT
>>   	.compat_ioctl = amdgpu_kms_compat_ioctl,
>>   #endif
>> +	.oom_file_badness = drm_oom_badness,
> Would be neat if we could roll this out for all gem drivers (once it's no
> longer an RFC ofc).
> -Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
