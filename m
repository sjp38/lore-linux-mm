Date: Tue, 15 Aug 2000 11:13:13 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch-2.4.0-test6] swapout code optimized (fwd)
In-Reply-To: <Pine.LNX.4.21.0008151125360.1075-100000@saturn.homenet>
Message-ID: <Pine.LNX.4.21.0008151112510.10491-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tigran Aivazian <tigran@veritas.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Aug 2000, Tigran Aivazian wrote:

> I guess I should have asked you this before - is there something
> wrong with my patch below? I removed the 'mm' argument as
> redundant from all the mm/vmscan.c:*swap_out* functions. It is
> visible through vma->vm_mm.

Your patch looks ok to me.

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
