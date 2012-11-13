Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 38B476B0062
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 08:49:16 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id c4so4955097eek.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 05:49:14 -0800 (PST)
Date: Tue, 13 Nov 2012 14:49:10 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 08/19] mm: numa: Create basic numa page hinting
 infrastructure
Message-ID: <20121113134910.GB17782@gmail.com>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
 <1352193295-26815-9-git-send-email-mgorman@suse.de>
 <20121113102120.GD21522@gmail.com>
 <20121113115032.GY8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121113115032.GY8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> > But given that most architectures will be just fine reusing 
> > the already existing generic PROT_NONE machinery, the far 
> > better approach is to do what we've been doing in generic 
> > kernel code for the last 10 years: offer a default generic 
> > version, and then to offer per arch hooks on a strict 
> > as-needed basis, if they want or need to do something weird 
> > ...
> 
> If they are *not* fine with it, it's a large retrofit because 
> the PROT_NONE machinery has been hard-coded throughout. [...]

That was a valid criticism for earlier versions of the NUMA 
patches - but should much less be the case in the latest 
iterations of the patches:

 - it has generic pte_numa() / pmd_numa() instead of using
   prot_none() directly

 - the key utility functions are named using the _numa pattern,
   not *_prot_none*() anymore.

Let us know if you can still see such instances - it's probably 
simple oversight.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
