Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 8EB3E16B63
	for <linux-mm@kvack.org>; Wed, 23 May 2001 12:34:16 -0300 (EST)
Date: Wed, 23 May 2001 12:34:04 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC][PATCH] Re: Linux 2.4.4-ac10
In-Reply-To: <20010521223212.C4934@khan.acc.umu.se>
Message-ID: <Pine.LNX.4.33.0105231233070.311-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Weinehall <tao@acc.umu.se>
Cc: Pavel Machek <pavel@suse.cz>, Mike Galbraith <mikeg@wen-online.de>, "Stephen C. Tweedie" <sct@redhat.com>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 21 May 2001, David Weinehall wrote:

> IMVHO every developer involved in memory-management (and indeed, any
> software development; the authors of ntpd comes in mind here) should
> have a 386 with 4MB of RAM and some 16MB of swap. Nowadays I have the
> luxury of a 486 with 8MB of RAM and 32MB of swap as a firewall, but it's
> still a pain to work with.

You're absolutely right. The smallest thing I'm testing with
on a regular basis is my dual pentium machine, booted with
mem=8m or mem=16m.

Time to hunt around for a 386 or 486 which is limited to such
a small amount of RAM ;)

cheers,

Rik
--
Linux MM bugzilla: http://linux-mm.org/bugzilla.shtml

Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
