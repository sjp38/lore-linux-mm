Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 30E446B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 18:31:11 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so2813053oag.14
        for <linux-mm@kvack.org>; Thu, 11 Oct 2012 15:31:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <50765797.3080709@jp.fujitsu.com>
References: <507656D1.5020703@jp.fujitsu.com> <50765797.3080709@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 11 Oct 2012 18:30:50 -0400
Message-ID: <CAHGf_=ph2RGaZz137Y=_GpH6sFMuHHt3vCq3vfB-Ozfd1Cteiw@mail.gmail.com>
Subject: Re: [PATCH 1/2]suppress "Device memoryX does not have a release()
 function" warning
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, minchan.kim@gmail.com, akpm@linux-foundation.org, wency@cn.fujitsu.com

On Thu, Oct 11, 2012 at 1:22 AM, Yasuaki Ishimatsu
<isimatu.yasuaki@jp.fujitsu.com> wrote:
> When calling remove_memory_block(), the function shows following message at
> device_release().
>
> "Device 'memory528' does not have a release() function, it is broken and must
> be fixed."
>
> The reason is memory_block's device struct does not have a release() function.
>
> So the patch registers memory_block_release() to the device's release() function
> for suppressing the warning message. Additionally, the patch moves kfree(mem)
> into the release function since the release function is prepared as a means
> to free a memory_block struct.
>
> CC: David Rientjes <rientjes@google.com>
> CC: Jiang Liu <liuj97@gmail.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Wen Congyang <wency@cn.fujitsu.com>
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
