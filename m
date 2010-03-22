Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BA7736B01AF
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 12:32:21 -0400 (EDT)
Date: Mon, 22 Mar 2010 09:30:41 -0400
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [rfc][patch] mm, fs: warn on missing address space operations
Message-Id: <20100322093041.2de599f8.akpm@linux-foundation.org>
In-Reply-To: <20100322104057.GG17637@laptop>
References: <20100322053937.GA17637@laptop>
	<20100322005610.5dfa70b1.akpm@linux-foundation.org>
	<20100322104057.GG17637@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Mar 2010 21:40:57 +1100 Nick Piggin <npiggin@suse.de> wrote:

> > 
> > 	/* this fs should use block_invalidatepage() */
> > 	WARN_ON_ONCE(!invalidatepage);
> 
> Problem is that it doesn't give you the aop name (and call trace
> probably won't help).

Yes it does - you have the filename and line number.  You go there and
read "invalidatepage".  And the backtrace identifies the filesystem.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
