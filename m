Date: Wed, 4 Apr 2001 19:16:17 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Fwd: kernel BUG at page_alloc.c:75! / exit.c
In-Reply-To: <01040421360901.00634@jeloin>
Message-ID: <Pine.LNX.4.21.0104041915070.25572-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-mm@kvack.org, ernte23@gmx.de
List-ID: <linux-mm.kvack.org>

On Wed, 4 Apr 2001, Roger Larsson wrote:

> ----------  Forwarded Message  ----------
> Subject: kernel BUG at page_alloc.c:75! / exit.c
> Date: Wed, 04 Apr 2001 13:23:51 +0200
> From: ernte23@gmx.de
> To: linux-kernel@vger.kernel.org
> 
> I'm running the 2.4.3 kernel and my system always (!) crashes when I
> try to generate the "Linux kernel poster" from lgp.linuxcare.com.au.
> After working for one hour, the kernel printed this message:

There are some known bugs in the 2.4 memory management.
Does 2.4.3-ac<latest> fix this ?

(note: 2.4.3-ac<latest> isn't stable/safe either, but
people are working on it and it would be cool to know
if at least this bug has been fixed)

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
