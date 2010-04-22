Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C68306B01F1
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 12:42:56 -0400 (EDT)
Date: Thu, 22 Apr 2010 12:42:47 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2] mm: add context argument to shrinker callback
Message-ID: <20100422164247.GA15882@infradead.org>
References: <1271118255-21070-1-git-send-email-david@fromorbit.com> <1271118255-21070-2-git-send-email-david@fromorbit.com> <20100418001514.GA26575@infradead.org> <20100419140039.GQ5683@laptop> <20100420004149.GA14744@dastard> <20100420083840.GR5683@laptop> <20100420103216.GK15130@dastard> <20100421084004.GS5683@laptop> <20100422163211.GA2478@infradead.org> <20100422163801.GZ5683@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100422163801.GZ5683@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 23, 2010 at 02:38:01AM +1000, Nick Piggin wrote:
> I don't understand, it should be implemented like just all the other
> shrinkers AFAIKS. Like the dcache one that has to shrink multiple
> superblocks. There is absolutely no requirement for this API change
> to implement it in XFS.

The dcache shrinker is an example for a complete mess.

> But the shrinker list *is* a global list. The downside of it in the way
> it was done in the XFS patch is that 1) it is much larger than a simple
> list head, and 2) not usable by anything other then the shrinker.

It is an existing global list just made more useful.  Whenever a driver
has muliple instances of pool that need shrinking this comes in useful,
it's not related to filesystems at all. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
