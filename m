Date: Tue, 24 Jul 2007 16:00:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] add __GFP_ZERO to GFP_LEVEL_MASK
In-Reply-To: <20070724151046.d8fbb7da.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0707241541310.7288@schroedinger.engr.sgi.com>
References: <1185185020.8197.11.camel@twins> <20070723112143.GB19437@skynet.ie>
 <1185190711.8197.15.camel@twins> <Pine.LNX.4.64.0707231615310.427@schroedinger.engr.sgi.com>
 <1185256869.8197.27.camel@twins> <Pine.LNX.4.64.0707240007100.3128@schroedinger.engr.sgi.com>
 <1185261894.8197.33.camel@twins> <Pine.LNX.4.64.0707240030110.3295@schroedinger.engr.sgi.com>
 <20070724120751.401bcbcb@schroedinger.engr.sgi.com>
 <20070724122542.d4ac734a.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707241234460.13653@schroedinger.engr.sgi.com>
 <20070724151046.d8fbb7da.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@skynet.ie>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Daniel Phillips <phillips@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Jul 2007, Andrew Morton wrote:

> I think I'll duck this for now.  Otherwise I have a suspicion that I'll
> be the first person to run it and I'm too old for such excitement.

I always had the suspicion that you have some magical script 
which will immediately tell you that a patch is not working ;-)

Works fine on x86_64 (on top of the ctor cleanup patchset) and passes the 
kernel build test but then there may be creatively designed drivers and 
such that pass these flags to the slab allocators which will now BUG.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
