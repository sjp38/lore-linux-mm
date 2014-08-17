Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1141E6B0036
	for <linux-mm@kvack.org>; Sun, 17 Aug 2014 07:08:25 -0400 (EDT)
Received: by mail-qc0-f175.google.com with SMTP id w7so3853710qcr.34
        for <linux-mm@kvack.org>; Sun, 17 Aug 2014 04:08:24 -0700 (PDT)
Received: from mail-qa0-x229.google.com (mail-qa0-x229.google.com [2607:f8b0:400d:c00::229])
        by mx.google.com with ESMTPS id j110si19774370qgf.122.2014.08.17.04.08.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 17 Aug 2014 04:08:24 -0700 (PDT)
Received: by mail-qa0-f41.google.com with SMTP id j7so3526320qaq.28
        for <linux-mm@kvack.org>; Sun, 17 Aug 2014 04:08:24 -0700 (PDT)
Date: Sun, 17 Aug 2014 07:08:21 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mem-hotplug: let memblock skip the hotpluggable memory
 regions in __next_mem_range()
Message-ID: <20140817110821.GM9305@htj.dyndns.org>
References: <53E8C5AA.5040506@huawei.com>
 <20140816130456.GH9305@htj.dyndns.org>
 <53EF6C79.3000603@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53EF6C79.3000603@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, "H. Peter Anvin" <hpa@zytor.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hello,

On Sat, Aug 16, 2014 at 10:36:41PM +0800, Xishi Qiu wrote:
> numa_clear_node_hotplug()? There is only numa_clear_kernel_node_hotplug().

Yeah, that one.

> If we don't clear hotpluggable flag in free_low_memory_core_early(), the 
> memory which marked hotpluggable flag will not free to buddy allocator.
> Because __next_mem_range() will skip them.
> 
> free_low_memory_core_early
> 	for_each_free_mem_range
> 		for_each_mem_range
> 			__next_mem_range		

Ah, okay, so the patch fixes __next_mem_range() and thus makes
free_low_memory_core_early() to skip hotpluggable regions unlike
before.  Please explain things like that in the changelog.  Also,
what's its relationship with numa_clear_kernel_node_hotplug()?  Do we
still need them?  If so, what are the different roles that these two
separate places serve?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
