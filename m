Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 61A786B0089
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 01:02:31 -0500 (EST)
Date: Mon, 22 Nov 2010 21:57:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] mlock: release mmap_sem every 256 faulted pages
Message-Id: <20101122215746.e847742d.akpm@linux-foundation.org>
In-Reply-To: <20101123050052.GA24039@google.com>
References: <20101123050052.GA24039@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Nov 2010 21:00:52 -0800 Michel Lespinasse <walken@google.com> wrote:

> Hi,
> 
> I'd like to sollicit comments on this proposal:
> 
> Currently mlock() holds mmap_sem in exclusive mode while the pages get
> faulted in. In the case of a large mlock, this can potentially take a
> very long time.

A more compelling description of why this problem needs addressing
would help things along.

> +		/*
> +		 * Limit batch size to 256 pages in order to reduce
> +		 * mmap_sem hold time.
> +		 */
> +		nfault = nstart + 256 * PAGE_SIZE;

It would be nicer if there was an rwsem API to ask if anyone is
currently blocked in down_read() or down_write().  That wouldn't be too
hard to do.  It wouldn't detect people polling down_read_trylock() or
down_write_trylock() though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
