Date: Mon, 28 Jul 2008 19:57:13 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: PERF: performance tests with the split LRU VM in -mm
Message-ID: <20080728195713.42cbceed@cuia.bos.redhat.com>
In-Reply-To: <20080728164124.8240eabe.akpm@linux-foundation.org>
References: <20080724222510.3bbbbedc@bree.surriel.com>
	<20080728105742.50d6514e@cuia.bos.redhat.com>
	<20080728164124.8240eabe.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jul 2008 16:41:24 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> > Andrew, what is your preference between:
> > 	http://lkml.org/lkml/2008/7/15/465
> > and
> > 	http://marc.info/?l=linux-mm&m=121683855132630&w=2
> > 
> 
> Boy.  They both seem rather hacky special-cases.  But that doesn't mean
> that they're undesirable hacky special-cases.  I guess the second one
> looks a bit more "algorithmic" and a bit less hacky-special-case.  But
> it all depends on testing..

I prefer the second one, since it removes the + 1 magic (at least,
for the higher priorities), instead of adding new magic like the
other patch does.

> On a different topic, these:
> 
> vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-around-the-lru.patch
> vm-dont-run-touch_buffer-during-buffercache-lookups.patch
> 
> have been floating about in -mm for ages, awaiting demonstration that
> they're a net benefit.  But all of this new page-reclaim rework was
> built on top of those two patches and incorporates and retains them.
> 
> I could toss them out, but that would require some rework and would
> partially invalidate previous testing and who knows, they _might_ be
> good patches.  Or they might not be.
> 
> What are your thoughts?

I believe you should definately keep those.  Being able to better
preserve actively accessed file pages could be a good benefit and
we have yet to discover a downside to those patches.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
