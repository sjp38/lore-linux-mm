Date: Wed, 22 Nov 2000 22:05:02 +0100 (MET)
From: Szabolcs Szakacsits <szaka@f-secure.com>
Subject: Re: [PATCH] Reserved root VM + OOM killer
In-Reply-To: <Pine.LNX.4.21.0011221839160.12459-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.30.0011222158260.14122-100000@fs129-190.f-secure.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Nov 2000, Rik van Riel wrote:

> On Wed, 22 Nov 2000, Szabolcs Szakacsits wrote:
>
> >    - OOM killing takes place only in do_page_fault() [no two places in
> >         the kernel for process killing]
>
> ... disable OOM killing for non-x86 architectures.
> This doesn't seem like a smart move ;)
>
> > diff -urw linux-2.2.18pre21/arch/i386/mm/Makefile linux/arch/i386/mm/Makefile
> > --- linux-2.2.18pre21/arch/i386/mm/Makefile	Fri Nov  1 04:56:43 1996
                          ^^^^^^^^^
As I wrote, the OOM killer changes are x86 only at present. Other
arch's still use the default OOM killing defined in arch/*/mm/fault.c.

	Szaka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
