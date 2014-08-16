Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 915E56B0036
	for <linux-mm@kvack.org>; Sat, 16 Aug 2014 09:05:00 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id i8so3274818qcq.17
        for <linux-mm@kvack.org>; Sat, 16 Aug 2014 06:05:00 -0700 (PDT)
Received: from mail-qc0-x230.google.com (mail-qc0-x230.google.com [2607:f8b0:400d:c01::230])
        by mx.google.com with ESMTPS id q2si16334040qah.18.2014.08.16.06.04.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 16 Aug 2014 06:04:59 -0700 (PDT)
Received: by mail-qc0-f176.google.com with SMTP id m20so3281135qcx.21
        for <linux-mm@kvack.org>; Sat, 16 Aug 2014 06:04:59 -0700 (PDT)
Date: Sat, 16 Aug 2014 09:04:56 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mem-hotplug: let memblock skip the hotpluggable memory
 regions in __next_mem_range()
Message-ID: <20140816130456.GH9305@htj.dyndns.org>
References: <53E8C5AA.5040506@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53E8C5AA.5040506@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, "H. Peter Anvin" <hpa@zytor.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 11, 2014 at 09:31:22PM +0800, Xishi Qiu wrote:
> Let memblock skip the hotpluggable memory regions in __next_mem_range(),
> it is used to to prevent memblock from allocating hotpluggable memory 
> for the kernel at early time. The code is the same as __next_mem_range_rev().
> 
> Clear hotpluggable flag before releasing free pages to the buddy allocator.

Please try to explain "why" in addition to "what".  Why do we need to
clear hotpluggable flag in free_low_memory_core_early() in addition to
numa_clear_node_hotplug() in x86 numa.c?  Does this make x86 code
redundant?  If not, why?

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
