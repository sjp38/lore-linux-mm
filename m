Date: Sun, 27 Jul 2008 02:45:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: MMU notifiers review and some proposals
Message-Id: <20080727024520.7dd12bf0.akpm@linux-foundation.org>
In-Reply-To: <20080724143949.GB12897@wotan.suse.de>
References: <20080724143949.GB12897@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org, andrea@qumranet.com, steiner@sgi.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 24 Jul 2008 16:39:49 +0200 Nick Piggin <npiggin@suse.de> wrote:

> I think everybody is hoping to have a workable mmu notifier scheme
> merged in 2.6.27 (myself included). However I do have some concerns
> about the implementation proposed (in -mm).
> 
> I apologise for this late review, before anybody gets too upset,
> most of my concerns have been raised before, but I'd like to state
> my case again and involving everyone.

Nick, having read through this discussion and the code (yet again) I
think I'll go ahead and send it all in to Linus.  On the basis that

- the code is fairly short and simple

- has no known bugs

- seems to be needed by some folks ;)

- you already have a protopatch which partially addresses your
  concerns and afaik there's nothing blocking future improvements to
  this implementation?


And a late-breaking review comment: given that about 0.000000000000001%
of people will actually use mm_take_all_locks(), could we make its
compilation conditional on something?  Such as CONFIG_MMU_NOTIFIER?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
