Date: Sat, 23 Feb 2008 00:05:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 07/28] mm: emergency pool
Message-Id: <20080223000554.04c4f755.akpm@linux-foundation.org>
In-Reply-To: <20080220150306.165236000@chello.nl>
References: <20080220144610.548202000@chello.nl>
	<20080220150306.165236000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008 15:46:17 +0100 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> @@ -213,7 +213,7 @@ enum zone_type {
>  
>  struct zone {
>  	/* Fields commonly accessed by the page allocator */
> -	unsigned long		pages_min, pages_low, pages_high;
> +	unsigned long		pages_emerg, pages_min, pages_low, pages_high;

It would be nice to make these one-per-line, then document them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
