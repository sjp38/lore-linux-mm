Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 621B06B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 02:38:31 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id cy9so94153446pac.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 23:38:31 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id p13si95195pfi.234.2016.01.25.23.38.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 23:38:30 -0800 (PST)
Date: Tue, 26 Jan 2016 16:38:46 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [LSF/MM ATTEND] 2016: Requests to attend MM-summit
Message-ID: <20160126073846.GC28254@js1304-P5Q-DELUXE>
References: <87k2n2usyf.fsf@linux.vnet.ibm.com>
 <20160122163801.GA16668@cmpxchg.org>
 <CAAmzW4OmWr1QGJn8D2c14jCPnwQ89T=YgBbg=bExgc_R6a4-bw@mail.gmail.com>
 <56A6B1A2.40903@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56A6B1A2.40903@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, lsf-pc@lists.linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>

On Mon, Jan 25, 2016 at 03:37:06PM -0800, Laura Abbott wrote:
> On 01/24/2016 11:08 PM, Joonsoo Kim wrote:
> >Hello,
> >
> >2016-01-23 1:38 GMT+09:00 Johannes Weiner <hannes@cmpxchg.org>:
> >>Hi,
> >>
> >>On Fri, Jan 22, 2016 at 10:11:12AM +0530, Aneesh Kumar K.V wrote:
> >>>* CMA allocator issues:
> >>>   (1) order zero allocation failures:
> >>>       We are observing order zero non-movable allocation failures in kernel
> >>>with CMA configured. We don't start a reclaim because our free memory check
> >>>does not consider free_cma. Hence the reclaim code assume we have enough free
> >>>pages. Joonsoo Kim tried to fix this with his ZOME_CMA patches. I would
> >>>like to discuss the challenges in getting this merged upstream.
> >>>https://lkml.org/lkml/2015/2/12/95 (ZONE_CMA)
> >
> >As far as I know, there is no disagreement on this patchset in last year LSF/MM.
> >Problem may be due to my laziness... Sorry about that. I will handle it soon.
> >Is there anything more that you concern?
> >
> 
> Is that series going to conflict with the work done for ZONE_DEVICE or run
> into similar problems?
> 033fbae988fcb67e5077203512181890848b8e90 (mm: ZONE_DEVICE for "device memory")
> has commit text about running out of ZONE_SHIFT bits and needing to get
> rid of ZONE_DMA instead so it seems like ZONE_CMA would run into the same
> problem.

Hmm... I'm not sure. I need a investigation. What I did before is
enlarging section size. Then, number of section is reduced and we need
less section bit in struct page's flag. This worked for my sparsemem
configuration but I'm not sure other conguration. Perhaps, in other
congifuration, we can limit node bits and max number of node.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
