Date: Sun, 18 Mar 2001 13:33:42 +0100 (CET)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: changing mm->mmap_sem  (was: Re: system call for process
 information?)
In-Reply-To: <Pine.LNX.4.21.0103180742510.13050-100000@imladris.rielhome.conectiva>
Message-ID: <Pine.LNX.4.33.0103181331420.1332-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, 18 Mar 2001, Rik van Riel wrote:

> > VFS: Mounted root (ext2 filesystem) readonly.
> > Freeing unused kernel memory: 196k freed
> > Adding Swap: 265064k swap-space (priority 2)
> > VM: Bad swap entry 00011e00
> > VM: Bad swap entry 00058d00
> > Unused swap offset entry in swap_dup 00058d00
> > Unused swap offset entry in swap_dup 00011e00
> > VM: Bad swap entry 00011e00
> > VM: Bad swap entry 00058d00
>
> Heh, I guess do_swap_page isn't too happy when multiple threads
> of the same program take a page fault at the same address at the
> same time.
>
> I take it you were testing something like mysql, jvm or apache2 ?

No, this was make -j30 bzImage.  (nscd was running though...)

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
