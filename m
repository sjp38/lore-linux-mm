Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by postfix.conectiva.com.br (Postfix) with SMTP id C07C416B17
	for <linux-mm@kvack.org>; Sun, 25 Mar 2001 12:08:01 -0300 (EST)
Date: Sun, 25 Mar 2001 12:06:56 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] OOM handling
In-Reply-To: <3ABDF8A6.7580BD7D@evision-ventures.com>
Message-ID: <Pine.LNX.4.21.0103251156450.1863-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Dalecki <dalecki@evision-ventures.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "James A. Sutherland" <jas88@cam.ac.uk>, Guest section DW <dwguest@win.tue.nl>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 25 Mar 2001, Martin Dalecki wrote:

> Ah... and of course I think this patch can already go directly 
> into the official kernel. The quality of code should permit 
> it. I would esp. request Rik van Riel to have a closer look
> at it...

- the algorithms are just as much black magic as the old ones
- it hasn't been tested in any other workload than your Oracle
  server (at least, not that I've heard of)
- the comments are just too rude  ;)
  (though fun)
- the AGE_FACTOR calculation will overflow after the system has
  an uptime of just _3_ days 
- your code might be good for server loads, but for normal
  users it will kill what amounts to a random process ... this
  is horribly wrong for desktop systems

In short, I like some of your ideas, but I really fail to see why
this version of the code would be any better than what we're having
now. In fact, since there seem to be about 1000x more desktop boxes
than Oracle boxes (probably even more), I'd say that the current
algorithm in the kernel is better (since it's right for more systems).

Now if you can make something which preserves the heuristics which
serve us so well on desktop boxes and add something that makes it
also work on your Oracle servers, then I'd be interested.

Alternatively, I also wouldn't mind a completely new algorithm, as
long as it turns out to work well on desktop boxes too. But remember
that we cannot tell this without first testing the thing on a few
dozen (hundreds?) of machines with different workloads...

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
