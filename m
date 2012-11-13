Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 5573E6B0070
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 08:39:19 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id c4so4948449eek.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 05:39:17 -0800 (PST)
Date: Tue, 13 Nov 2012 14:39:13 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 15/19] mm: numa: Add fault driven placement and migration
Message-ID: <20121113133913.GA17782@gmail.com>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
 <1352193295-26815-16-git-send-email-mgorman@suse.de>
 <20121113104530.GF21522@gmail.com>
 <20121113120909.GB8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121113120909.GB8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> > The NUMA_VARIABLE_LOCALITY name slightly misses the real 
> > point though that NUMA_EMBEDDED tried to stress: it's 
> > important to realize that these are systems that (ab-)use 
> > our NUMA memory zoning code to implement support for 
> > variable speed RAM modules - so they can use the existing 
> > node binding ABIs.
> > 
> > The cost of that is the losing of the regular NUMA node 
> > structure. So by all means it's a convenient hack - but the 
> > name must signal that. I'm not attached to the NUMA_EMBEDDED 
> > naming overly strongly, but NUMA_VARIABLE_LOCALITY sounds 
> > more harmless than it should.
> > 
> > Perhaps ARCH_WANT_NUMA_VARIABLE_LOCALITY_OVERRIDE? A tad 
> > long but we don't want it to be overused in any case.
> > 
> 
> I had two reasons for not using the NUMA_EMBEDDED name.

As I indicated I'm fine with not using that.

> I'll go with the long name you suggest even though it's arch 
> specific because I never want point 2 above to happen anyway. 
> Maybe the name will poke the next person who plans to abuse 
> NUMA in the eye hard enough to discourage them.

FYI, I've applied a slightly shorter variant in the numa/core 
tree, will send it out later today.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
