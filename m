Date: Wed, 2 Jan 2002 04:11:20 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH *] 2.4.17 rmap based VM #10
In-Reply-To: <Pine.LNX.4.33L.0201020239070.24031-100000@imladris.surriel.com>
Message-ID: <Pine.LNX.4.33L.0201020410290.24031-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 Jan 2002, Rik van Riel wrote:

> The 10th version of the reverse mapping based VM is now available.
> This is an attempt at making a more robust and flexible VM
> subsystem, while cleaning up a lot of code at the same time. The patch
> is available from:
>
>            http://surriel.com/patches/2.4/2.4.17-rmap-10
> and        http://linuxvm.bkbits.net/

Of course, Andrew Morton found a logic inversion bug in
wakeup_kswapd() which could cause system hangs. Please
get this patch instead:

	http://surriel.com/patches/2.4/2.4.17-rmap-10a

Rik
-- 
Shortwave goes a long way:  irc.starchat.net  #swl

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
