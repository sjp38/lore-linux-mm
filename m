Date: Mon, 2 Oct 2000 07:59:22 -0500 (CDT)
From: Jeff Garzik <jgarzik@mandrakesoft.mandrakesoft.com>
Subject: Re: how can i add a kernel function ?
In-Reply-To: <Pine.LNX.4.21.0010021349240.952-100000@saturn.homenet>
Message-ID: <Pine.LNX.3.96.1001002075546.13886A-100000@mandrakesoft.mandrakesoft.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tigran Aivazian <tigran@veritas.com>
Cc: BenHanokh Gabriel <gabriel@SANgate.com>, linux-mm@kvack.org, linux-kbuild@torque.net
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000, Tigran Aivazian wrote:
> On Mon, 2 Oct 2000, BenHanokh Gabriel wrote:
> 
> > hi
> > 
> > i'm trying to add a function of my own to my copy of fs/buffer.c
> > 
> > how can i export the symbol ?
> 
> add an entry to kernel/ksyms.c like this:

Not specifically related to BenHanokh Gabriel's problem, but I wanted
to take this opportunity to point out that we want to move away from
putting all exported symbols in one file.  Linus prefers that the
symbols are exported from the files in which they are declared.

Eventually we want to do away with the distinction of O_OBJS and
OX_OBJS, and just treat all files as OX_OBJS.  Linus suggested I look
into this but there were higher priority items.  Maybe some of the
kbuild guys will tackle it...

	Jeff




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
