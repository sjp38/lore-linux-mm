Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by postfix.conectiva.com.br (Postfix) with SMTP id 7E91516B18
	for <linux-mm@kvack.org>; Sun, 18 Mar 2001 07:48:41 -0300 (EST)
Date: Sun, 18 Mar 2001 07:46:10 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: changing mm->mmap_sem  (was: Re: system call for process
 information?)
In-Reply-To: <Pine.LNX.4.33.0103181050020.878-100000@mikeg.weiden.de>
Message-ID: <Pine.LNX.4.21.0103180742510.13050-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@wen-online.de>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, 18 Mar 2001, Mike Galbraith wrote:

> I gave this patch a try, and the initial results are extremely encouraging.
> Not only do I have vmstat (SCHED_RR) info in realtime with zero delays :))
> I also have a _nice_ throughput improvement.  There are some worrisome
> warnings below along with the compile changes I made here, but for an
> initial patch, things look pretty darn wonderful.

	[snip compile fixes .. integrated]

> VFS: Mounted root (ext2 filesystem) readonly.
> Freeing unused kernel memory: 196k freed
> Adding Swap: 265064k swap-space (priority 2)
> VM: Bad swap entry 00011e00
> VM: Bad swap entry 00058d00
> Unused swap offset entry in swap_dup 00058d00
> Unused swap offset entry in swap_dup 00011e00
> VM: Bad swap entry 00011e00
> VM: Bad swap entry 00058d00

Heh, I guess do_swap_page isn't too happy when multiple threads
of the same program take a page fault at the same address at the
same time.

I take it you were testing something like mysql, jvm or apache2 ?

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
