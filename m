Date: Wed, 22 Nov 2000 18:40:07 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Reserved root VM + OOM killer
In-Reply-To: <Pine.LNX.4.30.0011221736000.14122-100000@fs129-190.f-secure.com>
Message-ID: <Pine.LNX.4.21.0011221839160.12459-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szabolcs Szakacsits <szaka@f-secure.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Nov 2000, Szabolcs Szakacsits wrote:

>    - OOM killing takes place only in do_page_fault() [no two places in
>         the kernel for process killing]

... disable OOM killing for non-x86 architectures.
This doesn't seem like a smart move ;)

> diff -urw linux-2.2.18pre21/arch/i386/mm/Makefile linux/arch/i386/mm/Makefile
> --- linux-2.2.18pre21/arch/i386/mm/Makefile	Fri Nov  1 04:56:43 1996
> +++ linux/arch/i386/mm/Makefile	Tue Nov 21 03:03:15 2000
> @@ -8,6 +8,6 @@
>  # Note 2! The CFLAGS definition is now in the main makefile...
> 
>  O_TARGET := mm.o
> -O_OBJS	 := init.o fault.o ioremap.o extable.o
> +O_OBJS	 := init.o fault.o ioremap.o extable.o ../../../mm/oom_kill.o
> 
>  include $(TOPDIR)/Rules.make

Rik
--
Hollywood goes for world dumbination,
	Trailer at 11.

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
