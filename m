Date: Wed, 23 May 2007 19:06:11 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 2/8] mm: merge populate and nopage into fault (fixes
 nonlinear)
In-Reply-To: <20070524014803.GB22998@wotan.suse.de>
Message-ID: <alpine.LFD.0.98.0705231904480.3890@woody.linux-foundation.org>
References: <200705180737.l4I7b5aR010752@shell0.pdx.osdl.net>
 <alpine.LFD.0.98.0705180758450.3890@woody.linux-foundation.org>
 <1179963439.32247.987.camel@localhost.localdomain>
 <20070524014803.GB22998@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, akpm@linux-foundation.org, linux-mm@kvack.org, randy.dunlap@oracle.com
List-ID: <linux-mm.kvack.org>


On Thu, 24 May 2007, Nick Piggin wrote:
> 
> I won't do this. I'll keep calling it fault, because a) it means we keep
> the backwards compatible ->nopage path until all drivers are converted,
> and b) the page_mkwrite conversion really will make "nopage" the wrong
> name.

I won't _take_ the patch unless you convert all drivers. 

I refuse to have more of these "deprecated" crap. We don't do that. The 
code is just ugly. The warnings are horrible, and if they don't exist, the 
thing never gets fixed. 

Just make a clean break. If you want to rename it, rename it. But don't do 
some bogus "we'll do *both*" crap.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
