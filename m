Date: Sat, 8 Apr 2000 12:42:48 -0700 (PDT)
From: John Alvord <jalvo@mbay.net>
Subject: Re: Is Linux kernel 2.2.x Pageable?
In-Reply-To: <CA2568BB.005CE512.00@d73mta05.au.ibm.com>
Message-ID: <Pine.LNX.4.20.0004081240520.12925-100000@otter.mbay.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pnilesh@in.ibm.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 8 Apr 2000 pnilesh@in.ibm.com wrote:

> >This is silly.  To begin with one of those slow, stupid & dangerous
> >kernels called VM was able to host 41400 Linux virtual machines on a
> >single mainframe.  Second: one of those slow, stupid and dangerous
> >kernels called MVS probably holds the world record for reliability and
> >in the 60s/70s was already managing entire BIG companies on boxes who
> >by today sxtandards are ridiculously underpowered.
> 
> It's great to hear about many Linux Virtual machine running on a mainframe.
> Does Linux runs on any mainframe as Linux Real Machine ?Just curious.

The Linux/390 support includes running straight on an LPAR (isolated
division on a S/390) as well as a virtual machine. It also runs on a P390,
which is a mini-390 where the I/O is done on a PC and a separate
board/memory handles the instruction processing.

john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
