Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 344E66B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 07:34:36 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id c4so3821607eek.15
        for <linux-mm@kvack.org>; Thu, 20 Jun 2013 04:34:34 -0700 (PDT)
Date: Thu, 20 Jun 2013 13:34:31 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] mm: Revert pinned_vm braindamage
Message-ID: <20130620113431.GA12125@gmail.com>
References: <20130606124351.GZ27176@twins.programming.kicks-ass.net>
 <20130613140632.15982af2ebc443b24bfff86a@linux-foundation.org>
 <alpine.DEB.2.02.1306171417450.4234@ionos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1306171417450.4234@ionos.tec.linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, torvalds@linux-foundation.org, roland@kernel.org, kosaki.motohiro@gmail.com, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rdma@vger.kernel.org, Mike Marciniszyn <infinipath@intel.com>


* Thomas Gleixner <tglx@linutronix.de> wrote:

> On Thu, 13 Jun 2013, Andrew Morton wrote:
> > Let's try to get this wrapped up?
> > 
> > On Thu, 6 Jun 2013 14:43:51 +0200 Peter Zijlstra <peterz@infradead.org> wrote:
> > 
> > > 
> > > Patch bc3e53f682 ("mm: distinguish between mlocked and pinned pages")
> > > broke RLIMIT_MEMLOCK.
> > 
> > I rather like what bc3e53f682 did, actually.  RLIMIT_MEMLOCK limits the
> > amount of memory you can mlock().  Nice and simple.
> > 
> > This pinning thing which infiniband/perf are doing is conceptually
> > different and if we care at all, perhaps we should be looking at adding
> > RLIMIT_PINNED.
> 
> Actually PINNED is just a stronger version of MEMLOCK. PINNED and 
> MEMLOCK are both preventing the page from being paged out. PINNED adds 
> the constraint of preventing minor faults as well.
> 
> So I think the really important tuning knob is the limitation of pages 
> which cannot be paged out. And this is what RLIMIT_MEMLOCK is about.
> 
> Now if you want to add RLIMIT_PINNED as well, then it only limits the 
> number of pages which cannot create minor faults, but that does not 
> affect the limitation of total pages which cannot be paged out.

Agreed.

( Furthermore, the RLIMIT_MEMLOCK semantics change actively broke code so
  this is not academic and it would be nice to progress with it. )

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
