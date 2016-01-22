Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id AD9326B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 04:17:16 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id q63so40299440pfb.1
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 01:17:16 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id xk9si8396326pab.38.2016.01.22.01.17.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 01:17:16 -0800 (PST)
Received: by mail-pa0-x22f.google.com with SMTP id uo6so39471786pac.1
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 01:17:15 -0800 (PST)
Date: Fri, 22 Jan 2016 20:17:07 +1100
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [LSF/MM ATTEND] 2016: Requests to attend MM-summit
Message-ID: <20160122201707.1271a279@cotter.ozlabs.ibm.com>
In-Reply-To: <87k2n2usyf.fsf@linux.vnet.ibm.com>
References: <87k2n2usyf.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Fri, 22 Jan 2016 10:11:12 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> Hi,
> 
> I would like to attend LSF/MM this year (2016).
> 
> My main interest is in MM related topics although I am also interested
> in the btrfs status discussion (particularly related to subpage size block
> size topic), if we are having one. Most of my recent work in the kernel is
> related to adding ppc64 support for different MM features. My current focus
> is on adding Linux support for the new radix MMU model of Power9.
> 
> Topics of interest include:
> 
> * CMA allocator issues:
>   (1) order zero allocation failures:
>       We are observing order zero non-movable allocation failures in kernel
> with CMA configured. We don't start a reclaim because our free memory check
> does not consider free_cma. Hence the reclaim code assume we have enough free
> pages. Joonsoo Kim tried to fix this with his ZOME_CMA patches. I would
> like to discuss the challenges in getting this merged upstream.
> https://lkml.org/lkml/2015/2/12/95 (ZONE_CMA)
> 
> Others needed for the discussion:
> Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
>   (2) CMA allocation failures due to pinned pages in the region:
>       We allow only movable allocation from the CMA region to enable us
> to migrate those pages later when we get a CMA allocation request. But
> if we pin those movable pages, we will fail the migration which can result
> in CMA allocation failure. One such report can be found here.
> http://article.gmane.org/gmane.linux.kernel.mm/136738
> 
> Peter Zijlstra's VM_PINNED patch series should help in fixing the issue. I would
> like to discuss what needs to be done to get this patch series merged upstream
> https://lkml.org/lkml/2014/5/26/345 (VM_PINNED)
> 
> Others needed for the discussion:
> Peter Zijlstra <peterz@infradead.org>

+1

I agree CMA design is a concern. I also noticed that today all CMA pages come
from one node. On a NUMA box you'll see cross traffic going to that region -
although from kernel only text. It should be discussed at the summit and Aneesh
would be a good representative

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
