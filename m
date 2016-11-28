Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4E0A76B0038
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 15:59:54 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id bk3so22818756wjc.4
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 12:59:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f19si56107409wjq.287.2016.11.28.12.59.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Nov 2016 12:59:52 -0800 (PST)
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v3
References: <20161127131954.10026-1-mgorman@techsingularity.net>
 <alpine.DEB.2.20.1611280934460.28989@east.gentwo.org>
 <20161128162126.ulbqrslpahg4wdk3@techsingularity.net>
 <alpine.DEB.2.20.1611281037400.29533@east.gentwo.org>
 <20161128184758.bcz5ar5svv7whnqi@techsingularity.net>
 <alpine.DEB.2.20.1611281251150.30514@east.gentwo.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <142ecddd-ded5-a17e-2a30-411d19fda2c4@suse.cz>
Date: Mon, 28 Nov 2016 21:59:39 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1611281251150.30514@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On 11/28/2016 07:54 PM, Christoph Lameter wrote:
> On Mon, 28 Nov 2016, Mel Gorman wrote:
> 
>> If you have a series aimed at parts of the fragmentation problem or how
>> subsystems can avoid tracking 4K pages in some important cases then by
>> all means post them.
> 
> I designed SLUB with defrag methods in mind. We could warm up some old
> patchsets that where never merged:
> 
> https://lkml.org/lkml/2010/1/29/332

Note that some other solutions to the dentry cache problem (perhaps of a
more low-hanging fruit kind) were also discussed at KS/LPC MM panel
session: https://lwn.net/Articles/705758/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
