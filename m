Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 9354E6B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 09:42:23 -0400 (EDT)
Received: by mail-qa0-f50.google.com with SMTP id f14so1097548qak.2
        for <linux-mm@kvack.org>; Thu, 01 Aug 2013 06:42:22 -0700 (PDT)
Date: Thu, 1 Aug 2013 09:42:18 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 13/18] x86, numa, mem_hotplug: Skip all the regions
 the kernel resides in.
Message-ID: <20130801134218.GA29323@htj.dyndns.org>
References: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com>
 <1375340800-19332-14-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375340800-19332-14-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

> On Thu, Aug 01, 2013 at 03:06:35PM +0800, Tang Chen wrote:
> 
> At early time, memblock will reserve some memory for the kernel,
> such as the kernel code and data segments, initrd file, and so on=EF=BC=8C
> which means the kernel resides in these memory regions.
> 
> Even if these memory regions are hotpluggable, we should not
> mark them as hotpluggable. Otherwise the kernel won't have enough
> memory to boot.
> 
> This patch finds out which memory regions the kernel resides in,
> and skip them when finding all hotpluggable memory regions.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> ---
>  mm/memory=5Fhotplug.c |   45 +++++++++++++++++++++++++++++++++++++++++++++
>   1 files changed, 45 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memory=5Fhotplug.c b/mm/memory=5Fhotplug.c
> index 326e2f2..b800c9c 100644
> --- a/mm/memory=5Fhotplug.c
> +++ b/mm/memory=5Fhotplug.c
> @@ -31,6 +31,7 @@
>  #include <linux/firmware-map.h>
>  #include <linux/stop=5Fmachine.h>
>  #include <linux/acpi.h>
> +#include <linux/memblock.h>
> =20
>  #include <asm/tlbflush.h>
> =20

This patch is contaminated.  Can you please resend?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
