Date: Thu, 5 Aug 2004 23:17:15 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] 1/4: rework alloc_pages
Message-Id: <20040805231715.2a4f6bf8.akpm@osdl.org>
In-Reply-To: <41131FA6.4070402@yahoo.com.au>
References: <41130FB1.5020001@yahoo.com.au>
	<20040805221958.49049229.akpm@osdl.org>
	<41131732.7060606@yahoo.com.au>
	<20040805223725.246b0950.akpm@osdl.org>
	<41131FA6.4070402@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>
>  Ie, we have the (pages_low - pages_min) buffer after waking kswapd
>  before entering synch reclaim. Previously there was no buffer. I thought
>  this was the point of background reclaim. I don't know if I can explain
>  it any better than that sorry.

Yes, that is the point.  I was wondering yesterday why pages_min was no
longer used for anything any more.  We must have screwed things up when
doing the lower zone protection stuff for NUMA.  Bugger.

Wanna send that patch again, with a fit-for-human-consumption
description?

Thanks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
