Date: Thu, 24 May 2007 04:24:23 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/8] mm: merge populate and nopage into fault (fixes nonlinear)
Message-ID: <20070524022423.GC13694@wotan.suse.de>
References: <200705180737.l4I7b5aR010752@shell0.pdx.osdl.net> <alpine.LFD.0.98.0705180758450.3890@woody.linux-foundation.org> <1179963439.32247.987.camel@localhost.localdomain> <20070524014803.GB22998@wotan.suse.de> <alpine.LFD.0.98.0705231904480.3890@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.98.0705231904480.3890@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, akpm@linux-foundation.org, linux-mm@kvack.org, randy.dunlap@oracle.com
List-ID: <linux-mm.kvack.org>

On Wed, May 23, 2007 at 07:06:11PM -0700, Linus Torvalds wrote:
> 
> 
> On Thu, 24 May 2007, Nick Piggin wrote:
> > 
> > I won't do this. I'll keep calling it fault, because a) it means we keep
> > the backwards compatible ->nopage path until all drivers are converted,
> > and b) the page_mkwrite conversion really will make "nopage" the wrong
> > name.
> 
> I won't _take_ the patch unless you convert all drivers. 

I will, it is really pretty easy.

 
> I refuse to have more of these "deprecated" crap. We don't do that. The 
> code is just ugly. The warnings are horrible, and if they don't exist, the 
> thing never gets fixed. 
> 
> Just make a clean break. If you want to rename it, rename it. But don't do 
> some bogus "we'll do *both*" crap.

The problem is just carrying around all the patches, and also just getting
it into -mm. For example, take a look at the new ->prepare_write aops
patches I was working on... we converted *every* filesystem in the tree
(except reiserfs) not long ago, it didn't get merged, and now half of
them are broken again.

But don't worry, I do plan on converting all in-tree users of the old
interface as soon as possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
