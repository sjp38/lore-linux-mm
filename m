Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by postfix.conectiva.com.br (Postfix) with SMTP id 8C82A16B19
	for <linux-mm@kvack.org>; Sat, 24 Mar 2001 03:39:47 -0300 (EST)
Date: Sat, 24 Mar 2001 02:55:59 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Prevent OOM from killing init
In-Reply-To: <3ABBC702.AC9C3C92@mvista.com>
Message-ID: <Pine.LNX.4.21.0103240255090.1863-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: george anzinger <george@mvista.com>
Cc: Paul Jakma <paulj@itg.ie>, Szabolcs Szakacsits <szaka@f-secure.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Stephen Clouse <stephenc@theiqgroup.com>, Guest section DW <dwguest@win.tue.nl>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 Mar 2001, george anzinger wrote:

> What happens if you just make swap VERY large?  Does the system thrash
> it self to a virtual standstill?

It does.  I need to implement load control code (so we suspend
processes in turn to keep the load low enough so we can avoid
thrashing).

> Is this a possible answer?  Supposedly you could then sneak in and
> blow away the bad guys manually ...

This certainly works.

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
