Date: Wed, 9 Jul 2003 09:08:37 +0200 (MEST)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [announce, patch] 4G/4G split on x86, 64 GB RAM (and more)
 support
In-Reply-To: <Pine.LNX.4.44.0307082332450.17252-100000@localhost.localdomain>
Message-ID: <Pine.GSO.4.21.0307090907140.18825-100000@vervain.sonytel.be>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 9 Jul 2003, Ingo Molnar wrote:
> i'm pleased to announce the first public release of the "4GB/4GB VM split"
> patch, for the 2.5.74 Linux kernel:
> 
>    http://redhat.com/~mingo/4g-patches/4g-2.5.74-F8
> 
> The 4G/4G split feature is primarily intended for large-RAM x86 systems,
> which want to (or have to) get more kernel/user VM, at the expense of
> per-syscall TLB-flush overhead.

Great! Another enterprise feature stolen from SCO? :-)

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
