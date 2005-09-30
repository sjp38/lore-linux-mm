Subject: Re: [PATCH 3/7] CART - an advanced page replacement policy
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1128107781.14695.32.camel@twins>
References: <20050929180845.910895444@twins>
	 <20050929181622.780879649@twins>  <20050930184404.GA16812@xeon.cnet>
	 <1128107781.14695.32.camel@twins>
Content-Type: text/plain
Date: Fri, 30 Sep 2005 21:27:00 +0200
Message-Id: <1128108420.14695.37.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo <marcelo.tosatti@cyclades.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2005-09-30 at 21:16 +0200, Peter Zijlstra wrote:
> On Fri, 2005-09-30 at 15:44 -0300, Marcelo wrote:
> > Hi Peter,
> > 
> > On Thu, Sep 29, 2005 at 08:08:48PM +0200, Peter Zijlstra wrote:
> > > The flesh of the CART implementation. Again comments in the file should be
> > > clear.
> > 
> > Having per-zone "B1" target accounted at fault-time instead of a global target
> > strikes me.
> > 
> > The ARC algorithm adjusts the B1 target based on the fact that being-faulted-pages
> > were removed from the same memory region where such pages will reside.
> > 
> > The per-zone "B1" target as you implement it means that the B1 target accounting
> > happens for the zone in which the page for the faulting data has been allocated,
> > _not_ on the zone from which the data has been evicted. Seems quite unfair.
> > 
> > So for example, if a page gets removed from the HighMem zone while in the 
> > B1 list, and the same data gets faulted in later on a page from the normal
> > zone, Normal will have its "B1" target erroneously increased.
> > 
> > A global inactive target scaled to the zone size would get rid of that problem.
> 
> Good, good, I'll think this though, this probably means the other
> targets: 'p' and 'r' would similarly benefit.

I'm not thinking straigt, I should get back on my feet before I start
touching that code.

Thanks for the feedsback.

Peter

-- 
Peter Zijlstra <a.p.zijlstra@chello.nl>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
