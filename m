Message-ID: <3AD3011C.E5F2674C@gmx.de>
Date: Tue, 10 Apr 2001 14:48:28 +0200
From: ernte23@gmx.de
MIME-Version: 1.0
Subject: Re: Fwd: kernel BUG at page_alloc.c:75! / exit.c
References: <Pine.LNX.4.21.0104041915070.25572-100000@imladris.rielhome.conectiva>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Roger Larsson <roger.larsson@norran.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Wed, 4 Apr 2001, Roger Larsson wrote:
> 
> > I'm running the 2.4.3 kernel and my system always (!) crashes when I
> > try to generate the "Linux kernel poster" from lgp.linuxcare.com.au.
> > After working for one hour, the kernel printed this message:
> 
> There are some known bugs in the 2.4 memory management.
> Does 2.4.3-ac<latest> fix this ?
> 
> (note: 2.4.3-ac<latest> isn't stable/safe either, but
> people are working on it and it would be cool to know
> if at least this bug has been fixed)

I tried 2.4.4-pre1 and it showed up again (when there was high disk IO):

this was in the syslog:
kernel BUG at page_alloc.c:75!
invalid operand: 0000
CPU:    0
EIP:    0010:[__free_pages_ok+62/784]
EFLAGS: 00010296
eax: 0000001f   ebx: c1410d6c   ecx: 00000000   edx: 00000006
esi: c1410d6c   edi: c0203518   ebp: 00000000   esp: c1477f78
ds: 0018   es: 0018   ss: 0018

on the screen there was something like:
panic ... in interrupt handler, not syncing ...

I hope this helps.

Grussle, Felix

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
