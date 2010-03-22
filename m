Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 32CD26B01AD
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 17:02:03 -0400 (EDT)
Date: Tue, 23 Mar 2010 08:01:55 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] mm, fs: warn on missing address space operations
Message-ID: <20100322210155.GS17637@laptop>
References: <20100322053937.GA17637@laptop>
 <20100322005610.5dfa70b1.akpm@linux-foundation.org>
 <20100322104057.GG17637@laptop>
 <20100322093041.2de599f8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100322093041.2de599f8.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 22, 2010 at 09:30:41AM -0400, Andrew Morton wrote:
> On Mon, 22 Mar 2010 21:40:57 +1100 Nick Piggin <npiggin@suse.de> wrote:
> 
> > > 
> > > 	/* this fs should use block_invalidatepage() */
> > > 	WARN_ON_ONCE(!invalidatepage);
> > 
> > Problem is that it doesn't give you the aop name (and call trace
> > probably won't help).
> 
> Yes it does - you have the filename and line number.  You go there and
> read "invalidatepage".  And the backtrace identifies the filesystem.

The backtrace is usually coming from just generic code paths though.
Granted that it's usually not too hard to figure what filesystem it is
(although it may have several aops).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
