Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 117CF6B0085
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 12:12:49 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so2159268eek.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 09:12:47 -0800 (PST)
Date: Fri, 16 Nov 2012 18:12:43 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 06/43] mm: numa: Make pte_numa() and pmd_numa() a generic
 implementation
Message-ID: <20121116171243.GA4697@gmail.com>
References: <1353064973-26082-1-git-send-email-mgorman@suse.de>
 <1353064973-26082-7-git-send-email-mgorman@suse.de>
 <50A648FF.2040707@redhat.com>
 <20121116144109.GA8218@suse.de>
 <CA+55aFzH_-6FuwTF1GVDzLK+7c0MGLsLdPFjzzwU78GVUEMbBw@mail.gmail.com>
 <20121116160852.GA4302@gmail.com>
 <20121116165606.GE8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121116165606.GE8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> > Why not use something what we have in numa/core already:
> > 
> >   f05ea0948708 mm/mpol: Create special PROT_NONE infrastructure
> > 
> 
> Because it's hard-coded to PROT_NONE underneath which I've 
> complained about before. [...]

To which I replied that this is the current generic 
implementation, the moment some different architecture comes 
around we can accomodate it - on a strictly as-needed basis.

It is *better* and cleaner to not expose random arch hooks but 
let the core kernel modification be documented in the very patch 
that the architecture support patch makes use of it.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
