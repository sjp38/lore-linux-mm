Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 52D516B02E1
	for <linux-mm@kvack.org>; Wed, 17 May 2017 10:57:30 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id z125so10226874itc.12
        for <linux-mm@kvack.org>; Wed, 17 May 2017 07:57:30 -0700 (PDT)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id l187si16968589ith.1.2017.05.17.07.57.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 07:57:29 -0700 (PDT)
Date: Wed, 17 May 2017 09:57:28 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/6] refine and rename slub sysfs
In-Reply-To: <20170517141146.11063-1-richard.weiyang@gmail.com>
Message-ID: <alpine.DEB.2.20.1705170954090.8714@east.gentwo.org>
References: <20170517141146.11063-1-richard.weiyang@gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 17 May 2017, Wei Yang wrote:

> This patch serial could be divided into two parts.
>
> First three patches refine and adds slab sysfs.
> Second three patches rename slab sysfs.

These changes will break the slabinfo tool in linux/tools/vm/slabinfo.c.
Please update it as well.

> 1. Refine slab sysfs
>
> There are four level slabs:

levels? Maybe types of slabs?

>     CPU
>     CPU_PARTIAL
>     PARTIAL
>     FULL
>
> And in sysfs, it use show_slab_objects() and cpu_partial_slabs_show() to
> reflect the statistics.
>
> In patch 2, it splits some function in show_slab_objects() which makes sure
> only cpu_partial_slabs_show() covers statistics for CPU_PARTIAL slabs.
>
> After doing so, it would be more clear that show_slab_objects() has totally 9
> statistic combinations for three level of slabs. Each slab has three cases
> statistic.
>
>     slabs
>     objects
>     total_objects

That sounds good.

> which is a little bit hard for users to understand. The second three patches
> rename sysfs file in this pattern.
>
>     xxx_slabs[[_total]_objects]
>
> Finally it looks Like
>
>     slabs
>     slabs_objects
>     slabs_total_objects
>     cpu_slabs
>     cpu_slabs_objects
>     cpu_slabs_total_objects
>     partial_slabs
>     partial_slabs_objects
>     partial_slabs_total_objects
>     cpu_partial_slabs

Arent we missing:

cpu_partial_slabs_objects
cpu_partial_slabs_total_objects

And the partial slabs exclude the cpu slabs as well as the cpu_partial
slabs?

Could you add some documentation as well to explain the exact semantics?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
