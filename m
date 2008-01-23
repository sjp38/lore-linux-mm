Date: Wed, 23 Jan 2008 00:02:45 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] #ifdef very expensive debug check in page fault path
In-Reply-To: <20080122233950.GA29901@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0801222347430.7451@blonde.site>
References: <1200506488.32116.11.camel@cotte.boeblingen.de.ibm.com>
 <20080116234540.GB29823@wotan.suse.de> <20080116161021.c9a52c0f.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0801182023350.5249@blonde.site> <479469A4.6090607@de.ibm.com>
 <Pine.LNX.4.64.0801222226350.28823@blonde.site> <20080122233950.GA29901@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: carsteno@de.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, mschwid2@linux.vnet.ibm.com, Holger Wolf <holger.wolf@de.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 23 Jan 2008, Nick Piggin wrote:
> 
> I did want to get rid of the test, but not in a "sneak it in before he
> notices" way. So I am disappointed it was merged before you replied.

Not everybody can wait that indefinite interval for a response from me!

(And, by the by, I'm not ignoring the many mails you've addressed
to me or Cc'ed me in the last week or more; but some things are
easier to think about and come to conclusion on than others.
Take it as a compliment that your patches deserve consideration ;)

> > My guess is we let it rest for now, and reconsider if a case comes up
> > later which would have got caught by the check (but the problem is that
> > such a case is much harder to identify than it was).
> 
> The only cases I had imagined were repeatable things like a bug in pte
> manipulation somewhere, which will hopefully be caught with
> CONFIG_DEBUG_VM turned on. 

For things like that, repeatable occurrences from coding bugs,
which should get caught before release: yes I agree, the
CONFIG_DEBUG_VM would be entirely appropriate.

> Are there many other cases where the test is useful? For hardware
> failures, I'd say not -- those just tend to waste developers time.

Bad RAM bitflips etc., or some subsystem corrupting random memory:
those kind of things which so often end up as rmap.c Eeeks or Bad
page states.  Yes, a fair amount of developers time is wasted on
these: which is precisely why they're better caught sooner (by
a pfn_valid test in vm_normal_page) than later (by going on to
corrupt other memory in fictitious "struct page" manipulations).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
