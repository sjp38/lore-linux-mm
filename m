Date: Tue, 24 Feb 2004 15:43:47 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: vm benchmarking
Message-Id: <20040224154347.2b1536ee.akpm@osdl.org>
In-Reply-To: <403C76D8.3000302@cyberone.com.au>
References: <20040224034036.22953169.akpm@osdl.org>
	<403C76D8.3000302@cyberone.com.au>
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
> My machine doesn't touch swap at make -j4 with mem=64m. It is
> dual CPU with a SMP kernel but I was using maxcpus=1.

It is light-to-moderate paging.

> It compiles 2.4.21 with gcc-3.3.3 I think (I can tell you when I
> get home).

gcc version 3.2.2 20030222 (Red Hat Linux 3.2.2-5)

This is a 2.4.19 defconfig build.

> I can't explain your results. Maybe you have other stuff running.

Only `vmstat 1'.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
