Date: Wed, 4 Feb 2004 02:18:23 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 5/5] mm improvements
Message-Id: <20040204021823.24eb1c79.akpm@osdl.org>
In-Reply-To: <4020BE94.1040001@cyberone.com.au>
References: <4020BDCB.8030707@cyberone.com.au>
	<4020BE94.1040001@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <piggin@cyberone.com.au> wrote:
>
> It allows two scans at the two lowest priorities before breaking out or
>  doing a blk_congestion_wait, for both try_to_free_pages and balance_pgdat.

This seems to be fairly equivalent to simply subtracting one from
DEF_PRIORITY.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
