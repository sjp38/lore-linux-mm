Date: Sun, 30 Dec 2001 10:05:44 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH *] 2.4.17 rmap based VM #9
In-Reply-To: <1009699023.343.0.camel@psuedomode>
Message-ID: <Pine.LNX.4.33L.0112301004560.24031-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: safemode <safemode@speakeasy.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 30 Dec 2001, safemode wrote:

> Seems that not all of the live-deadlocks were fixed.  The one i saw in
> the last version is still present.   It occurs when you're heavily
> swapping out and the nall of a sudden require something to heavily swap

I've reproduced it with 'mem=12m'.  It seems the system spends all
of its time in try_to_free_pages() and friends, now I need to find
out why ;)

regards,

Rik
-- 
Shortwave goes a long way:  irc.starchat.net  #swl

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
