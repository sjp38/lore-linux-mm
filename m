Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0DE6B0292
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 11:06:30 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id l3so2173363wrc.12
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 08:06:30 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id d27si1380266wrb.272.2017.07.17.08.06.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 08:06:29 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id p204so23644351wmg.1
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 08:06:28 -0700 (PDT)
Date: Mon, 17 Jul 2017 17:06:25 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v4 00/10] PCID and improved laziness
Message-ID: <20170717150625.2depy7bqkx7qt7zv@gmail.com>
References: <cover.1498751203.git.luto@kernel.org>
 <20170705085657.eghd4xbv7g7shf5v@gmail.com>
 <20170717095715.yzmuhhp6txqsxtpf@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170717095715.yzmuhhp6txqsxtpf@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>


* Mel Gorman <mgorman@suse.de> wrote:

> On Wed, Jul 05, 2017 at 10:56:57AM +0200, Ingo Molnar wrote:
> > 
> > * Andy Lutomirski <luto@kernel.org> wrote:
> > 
> > > *** Ingo, even if this misses 4.13, please apply the first patch before
> > > *** the merge window.
> > 
> > > Andy Lutomirski (10):
> > >   x86/mm: Don't reenter flush_tlb_func_common()
> > >   x86/mm: Delete a big outdated comment about TLB flushing
> > >   x86/mm: Give each mm TLB flush generation a unique ID
> > >   x86/mm: Track the TLB's tlb_gen and update the flushing algorithm
> > >   x86/mm: Rework lazy TLB mode and TLB freshness tracking
> > >   x86/mm: Stop calling leave_mm() in idle code
> > >   x86/mm: Disable PCID on 32-bit kernels
> > >   x86/mm: Add nopcid to turn off PCID
> > >   x86/mm: Enable CR4.PCIDE on supported systems
> > >   x86/mm: Try to preserve old TLB entries using PCID
> > 
> > So this series is really nice, and the first two patches are already upstream, and 
> > I've just applied all but the final patch to tip:x86/mm (out of caution - I'm a wimp).
> > 
> > That should already offer some improvements and enables the CR4 bit - but doesn't 
> > actually use the PCID hardware yet.
> > 
> > I'll push it all out when it passes testing.
> > 
> > If it's all super stable I plan to tempt Linus with a late merge window pull 
> > request for all these preparatory patches. (Unless he objects that is. Hint, hint.)
> > 
> > Any objections?
> > 
> 
> What was the final verdict here? I have a patch ready that should be layered
> on top which will need a backport. PCID support does not appear to have
> made it in this merge window so I'm wondering if I should send the patch
> as-is for placement on top of Andy's work or go with the backport and
> apply a follow-on patch after Andy's work gets merged.

It's en route for v4.14 - it narrowly missed v4.13.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
