Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by postfix.conectiva.com.br (Postfix) with SMTP id 3B8D216B0E
	for <linux-mm@kvack.org>; Sat, 24 Mar 2001 13:30:17 -0300 (EST)
Date: Sat, 24 Mar 2001 13:21:29 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Reduce Linux memory requirements for an Embedded PC
In-Reply-To: <20010324133926.A1584@fred.local>
Message-ID: <Pine.LNX.4.21.0103241319480.1863-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: Petr Dusil <pdusil@razdva.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 24 Mar 2001, Andi Kleen wrote:
> On Sat, Mar 24, 2001 at 10:59:36AM +0100, Petr Dusil wrote:

> > I am developing a Linux distribution for a Jumptec Embedded PC. It is
> > targeted to an I486, 16MB DRAM, 16MB DiskOnChip. I have decided to use
> > Redhat 6.2  (2.2.14 kernel) and to reduce its size to fit the EPC. I
> > have simplified the kernel (removed support of all unwanted hardware),

> One way is to go back to a 2.0 kernel, which uses somewhat less
> memory. I did that on a 4MB box. There are also ways to reduce memory
> usage further for both 2.0 and 2.2, but it requires a bit of source
> patching. Basically you go through nm --size-sort -t d vmlinux and try
> to reduce all big symbols, like the static super block array and
> reducing sizes of preallocated hash tables (e.g. buffer and networking
> hash is very big in 2.2)

I'm willing to work on a CONFIG_TINY option for 2.5 which
does things like this (but I'll have to finish some VM
things first ;)).

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
