Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id F1AC96B0036
	for <linux-mm@kvack.org>; Wed, 28 Aug 2013 11:19:14 -0400 (EDT)
Received: by mail-qa0-f44.google.com with SMTP id w8so2284059qac.3
        for <linux-mm@kvack.org>; Wed, 28 Aug 2013 08:19:14 -0700 (PDT)
Date: Wed, 28 Aug 2013 11:19:09 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 00/11] x86, memblock: Allocate memory near kernel image
 before SRAT parsed.
Message-ID: <20130828151909.GE9295@htj.dyndns.org>
References: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Tue, Aug 27, 2013 at 05:37:37PM +0800, Tang Chen wrote:
> Tang Chen (11):
>   memblock: Rename current_limit to current_limit_high in memblock.
>   memblock: Rename memblock_set_current_limit() to
>     memblock_set_current_limit_high().
>   memblock: Introduce lowest limit in memblock.
>   memblock: Introduce memblock_set_current_limit_low() to set lower
>     limit of memblock.
>   memblock: Introduce allocation order to memblock.
>   memblock: Improve memblock to support allocation from lower address.
>   x86, memblock: Set lowest limit for memblock_alloc_base_nid().
>   x86, acpi, memblock: Use __memblock_alloc_base() in
>     acpi_initrd_override()
>   mem-hotplug: Introduce movablenode boot option to {en|dis}able using
>     SRAT.
>   x86, mem-hotplug: Support initialize page tables from low to high.
>   x86, mem_hotplug: Allocate memory near kernel image before SRAT is
>     parsed.

Doesn't apply to -master, -next or tip.  Again, can you please include
which tree and git commit the patches are against in the patch
description?  How is one supposed to know on top of which tree you're
working?  It is in your benefit to make things easier for the prosepct
reviewers.  Trying to guess and apply the patches to different devel
branches and failing isn't productive and frustates your prospect
reviewers who would of course have negative pre-perception going into
the review and this isn't the first time this issue was raised either.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
