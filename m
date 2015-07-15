Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id B7B2428027E
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 18:06:28 -0400 (EDT)
Received: by ykeo3 with SMTP id o3so48846059yke.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 15:06:28 -0700 (PDT)
Received: from mail-yk0-x22e.google.com (mail-yk0-x22e.google.com. [2607:f8b0:4002:c07::22e])
        by mx.google.com with ESMTPS id k184si4055887ywf.180.2015.07.15.15.06.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 15:06:28 -0700 (PDT)
Received: by ykay190 with SMTP id y190so48971032yka.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 15:06:27 -0700 (PDT)
Date: Wed, 15 Jul 2015 18:06:25 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/5] x86, acpi, cpu-hotplug: Enable MADT APIs to return
 disabled apicid.
Message-ID: <20150715220625.GN15934@mtj.duckdns.org>
References: <1436261425-29881-1-git-send-email-tangchen@cn.fujitsu.com>
 <1436261425-29881-5-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436261425-29881-5-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, laijs@cn.fujitsu.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, qiaonuohan@cn.fujitsu.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gu Zheng <guz.fnst@cn.fujitsu.com>

Hello,

On Tue, Jul 07, 2015 at 05:30:24PM +0800, Tang Chen wrote:
> From: Gu Zheng <guz.fnst@cn.fujitsu.com>
> 
> All processors' apicids can be obtained by _MAT method or from MADT in ACPI.
> The current code ignores disabled processors and returns -ENODEV.
> 
> After this patch, a new parameter will be added to MADT APIs so that caller
> is able to control if disabled processors are ignored.

This describes what the patch does but doesn't really explain what the
patch is trying to achieve.

> @@ -282,8 +282,11 @@ static int acpi_processor_get_info(struct acpi_device *device)
>  	 *  Extra Processor objects may be enumerated on MP systems with
>  	 *  less than the max # of CPUs. They should be ignored _iff
>  	 *  they are physically not present.
> +	 *
> +	 *  NOTE: Even if the processor has a cpuid, it may not present because
                                                               ^
							       be
> +	 *  cpuid <-> apicid mapping is persistent now.

Saying "now" is kinda weird as this is how the code is gonna be
forever.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
