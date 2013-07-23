Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id BC77A6B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 15:19:12 -0400 (EDT)
Received: by mail-yh0-f41.google.com with SMTP id z6so1700887yhz.14
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 12:19:11 -0700 (PDT)
Date: Tue, 23 Jul 2013 15:19:04 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 03/21] x86, acpi, numa, mem-hotplug: Introduce
 MEMBLK_HOTPLUGGABLE to reserve hotpluggable memory.
Message-ID: <20130723191904.GK21100@mtj.dyndns.org>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
 <1374220774-29974-4-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374220774-29974-4-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Fri, Jul 19, 2013 at 03:59:16PM +0800, Tang Chen wrote:
>  /* Definition of memblock flags. */
>  #define MEMBLK_FLAGS_DEFAULT	0x0	/* default flag */
> +#define MEMBLK_HOTPLUGGABLE	0x1	/* hotpluggable region */

Given that all existing APIs are using "memblock", wouldn't it be
better to use "MEMBLOCK_" prefix?  If it's too long, we can just do
MEMBLOCK_HOTPLUG.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
