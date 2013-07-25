Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 1F45A6B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 11:06:03 -0400 (EDT)
Received: by mail-gg0-f174.google.com with SMTP id y3so426220ggc.19
        for <linux-mm@kvack.org>; Thu, 25 Jul 2013 08:06:02 -0700 (PDT)
Date: Thu, 25 Jul 2013 11:05:54 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 18/21] x86, numa: Synchronize nid info in
 memblock.reserve with numa_meminfo.
Message-ID: <20130725150554.GC26107@mtj.dyndns.org>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
 <1374220774-29974-19-git-send-email-tangchen@cn.fujitsu.com>
 <20130723212548.GZ21100@mtj.dyndns.org>
 <51F0A4F9.2060802@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51F0A4F9.2060802@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello, Tang.

On Thu, Jul 25, 2013 at 12:09:29PM +0800, Tang Chen wrote:
> And as in [patch 14/21], when reserving hotpluggable memory, we use
> pxm. So my

Which is kinda nasty.

> idea was to do a nid sync in numa_init(). After this, memblock will
> set nid when
> it allocates memory.

Sure, that's the only place we can set the numa node IDs but my point
is that you don't need to add another interface.  Jet let
memblock_set_node() handle both memblock.memory and .reserved ranges.
That way, you can make memblock simpler to use and less error-prone.

> If we want to let memblock_set_node() and alloc functions set nid on
> the reserved
> regions, we should setup nid <-> pxm mapping when we parst SRAT for
> the first time.

I don't follow why it has to be different.  Why do you need to do
anything differently?  What am I missing here?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
