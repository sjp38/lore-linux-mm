Date: Fri, 9 May 2003 21:44:28 -0400 (EDT)
From: Rik van Riel <riel@imladris.surriel.com>
Subject: Re: Extended Pagins on IA32
In-Reply-To: <Pine.LNX.4.53.0305091157180.23419@picard.science-computing.de>
Message-ID: <Pine.LNX.4.50L.0305092143150.31019-100000@imladris.surriel.com>
References: <Pine.GHP.4.02.10302121019090.19866-100000@alderaan.science-computing.de>
 <Pine.LNX.4.53.0305071628130.3486@picard.science-computing.de>
 <Pine.LNX.4.53.0305091157180.23419@picard.science-computing.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oliver Tennert <tennert@science-computing.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 9 May 2003, Oliver Tennert wrote:

> Does Linux make use of 4M page sizes (or 2M if PAE is enabled)? If yes,
> under which circumstances are large pages used?

In 2.4 mainline the large pages are only used for the kernel
itself, for mapping ZONE_DMA and ZONE_NORMAL memory into the
kernel virtual address space.

In 2.5 (and some 2.4 distro kernels) large pages can also be
used for special purpose things in userland, mostly Oracle
shared memory segments.

regards,

Rik
-- 
Engineers don't grow up, they grow sideways.
http://www.surriel.com/		http://kernelnewbies.org/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
