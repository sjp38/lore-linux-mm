Date: Wed, 18 May 2005 09:43:42 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] Avoiding mmap fragmentation - clean rev
Message-ID: <20050518074342.GC5432@elte.hu>
References: <E4BA51C8E4E9634993418831223F0A49291F06E1@scsmsx401.amr.corp.intel.com> <200505172228.j4HMSkg28528@unix-os.sc.intel.com> <20050518072838.GB15326@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050518072838.GB15326@devserv.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjanv@redhat.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Wolfgang Wander' <wwc@rentec.com>, 'Andrew Morton' <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Arjan van de Ven <arjanv@redhat.com> wrote:

> > Please note, this patch completely obsoletes previous patch that
> > Wolfgang posted and should completely retain the performance benefit
> > of free_area_cache and at the same time preserving fragmentation to
> > minimum.
> 
> this has one downside (other than that I like it due to it's 
> simplicity): we've seen situations where there was a 4Kb gap at the 
> start of the mmaps, and then all future mmaps are bigger (say, stack 
> sized). That 4Kb gap would entirely void the advantage of the cache if 
> the cache stuck to that 4kb gap. (Personally I favor correctness above 
> all but it does hurt performance really bad)

hm, does the cache get permanently stuck at a small hole with Ken's 
patch? An unmap may reset the cache to the hole once, but subsequent 
unmaps (or mmaps) ought to move it to a larger hole again.

	Ingo
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
