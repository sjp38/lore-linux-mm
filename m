Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id AD2356B005A
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 16:23:52 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so1081849dad.14
        for <linux-mm@kvack.org>; Thu, 11 Oct 2012 13:23:51 -0700 (PDT)
Date: Thu, 11 Oct 2012 13:23:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2]suppress "Device memoryX does not have a release()
 function" warning
In-Reply-To: <50765797.3080709@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1210111323370.28062@chino.kir.corp.google.com>
References: <507656D1.5020703@jp.fujitsu.com> <50765797.3080709@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, liuj97@gmail.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

On Thu, 11 Oct 2012, Yasuaki Ishimatsu wrote:

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

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
