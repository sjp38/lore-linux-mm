Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by postfix.conectiva.com.br (Postfix) with SMTP id AABA816EC5
	for <linux-mm@kvack.org>; Thu, 22 Mar 2001 14:00:07 -0300 (EST)
Date: Thu, 22 Mar 2001 13:29:44 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Prevent OOM from killing init
In-Reply-To: <4605B269DB001E4299157DD1569079D2809930@EXCHANGE03.plaza.ds.adp.com>
Message-ID: <Pine.LNX.4.21.0103221329000.21415-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tom Kondilis <tomk@plaza.ds.adp.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Mar 2001, Tom Kondilis wrote:

> I had a 2.4.3pre3 do a 'Killing Init'
> My assuption is that I had a large benchmark running, while the benchmark
> was running,  I updated inittab to uncomment a mgetty of my serial port, and
> followed it with a 'telinit q'.
> When the system thought it ran out of memory with '1-order allocation
> failures' during a fork, which I think its a defect , because I still have
> 14GB of Swap left in the system. My system was dead.
> A real life case of killing Init.

That's not the OOM killer however, but init dying because it
couldn't get the memory it needed to satisfy a page fault or
somesuch...

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
