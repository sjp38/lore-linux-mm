Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by postfix.conectiva.com.br (Postfix) with SMTP id BF9B816B13
	for <linux-mm@kvack.org>; Sun, 25 Mar 2001 14:59:56 -0300 (EST)
Date: Sun, 25 Mar 2001 14:08:03 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] OOM handling
In-Reply-To: <3ABE0CC2.268D8C3C@evision-ventures.com>
Message-ID: <Pine.LNX.4.21.0103251407420.1863-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Dalecki <dalecki@evision-ventures.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "James A. Sutherland" <jas88@cam.ac.uk>, Guest section DW <dwguest@win.tue.nl>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 25 Mar 2001, Martin Dalecki wrote:
> Rik van Riel wrote:

> > - the AGE_FACTOR calculation will overflow after the system has
> >   an uptime of just _3_ days
> 
> I esp. the behaviour will be predictable.

Ummmm ?

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
