Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4B62D6B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 08:34:29 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id u64so8553690lff.2
        for <linux-mm@kvack.org>; Tue, 17 May 2016 05:34:29 -0700 (PDT)
Received: from mail-lf0-x22a.google.com (mail-lf0-x22a.google.com. [2a00:1450:4010:c07::22a])
        by mx.google.com with ESMTPS id z3si2360812lfc.128.2016.05.17.05.34.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 05:34:26 -0700 (PDT)
Received: by mail-lf0-x22a.google.com with SMTP id y84so6172570lfc.0
        for <linux-mm@kvack.org>; Tue, 17 May 2016 05:34:26 -0700 (PDT)
Date: Tue, 17 May 2016 15:34:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: make fault_around_bytes configurable
Message-ID: <20160517123423.GF9540@node.shutemov.name>
References: <1460992636-711-1-git-send-email-vinmenon@codeaurora.org>
 <20160421170150.b492ffe35d073270b53f0e4d@linux-foundation.org>
 <5719E494.20302@codeaurora.org>
 <20160422094430.GA7336@node.shutemov.name>
 <fdc23a2a-b42a-f0af-d403-41ea4e755084@codeaurora.org>
 <20160509073251.GA5434@blaptop>
 <20160510024842.GC4426@bbox>
 <20160516141854.GA2361@blaptop>
 <20160516142900.GB9540@node.shutemov.name>
 <20160516145632.GA2342@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160516145632.GA2342@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, mgorman@suse.de, vbabka@suse.cz, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, hughd@google.com

On Mon, May 16, 2016 at 11:56:32PM +0900, Minchan Kim wrote:
> On Mon, May 16, 2016 at 05:29:00PM +0300, Kirill A. Shutemov wrote:
> > > Kirill,
> > > You wanted to test non-HW access bit system and I did.
> > > What's your opinion?
> > 
> > Sorry, for late response.
> > 
> > My patch is incomlete: we need to find a way to not mark pte as old if we
> > handle page fault for the address the pte represents.
> 
> I'm sure you can handle it but my point is there wouldn't be a big gain
> although you can handle it in non-HW access bit system. Okay, let's be
> more clear because I don't have every non-HW access bit architecture.
> At least, current mobile workload in ARM which I have wouldn't be huge
> benefit.
> I will say one more.
> I tested the workload on quad-core system and core speed is not so slow
> compared to recent other mobile phone SoC. Even when I tested the benchmark
> without pte_mkold, the benefit is within noise because storage is really
> slow so major fault is dominant factor. So, I decide test storage from eMMC
> to eSATA. And then finally, I manage to see the a little beneift with
> fault_around without pte_mkold.
> 
> However, let's consider side-effect aspect from fault_around.
> 
> 1. Increase slab shrinking compard to old
> 2. high level vmpressure compared to old
> 
> With considering that regressions on my system, it's really not worth to
> try at the moment.
> That's why I wanted to disable fault_around as default in non-HW access
> bit system.

Feel free to post such patch. I guess it's reasonable.

> > Once this will be done, the number of page faults shouldn't be higher with
> > fault-around enabled even on machines without hardware accessed bit. This
> > will address performance regression with the patch on such machines.
> 
> Although you solves that, I guess the benefit would be marginal in
> some architectures but we should solve above side-effects.
> 
> > 
> > I'll try to find time to update the patch soon.
> 
> I hope you can solve above those regressions as well.

The patch is posted. Please test.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
