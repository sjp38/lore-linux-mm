Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 69BBC38C60
	for <linux-mm@kvack.org>; Mon,  6 Aug 2001 15:39:23 -0300 (EST)
Date: Mon, 6 Aug 2001 15:39:12 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] kill flush_dirty_buffers
In-Reply-To: <Pine.LNX.4.33.0108061048240.8972-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.33L.0108061538360.1439-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Chris Mason <mason@suse.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 6 Aug 2001, Linus Torvalds wrote:

> The other issue is that I suspect that "flushtime" is completely useless
> these days, and should just be dropped. If we've decided to start flushing
> stuff out, we shouldn't stop flushing just because some buffer hasn't
> quite reached the proper age yet. We'd have been better off maybe deciding
> not to even _start_ flushing at all, but once we've started, we might as
> well do the dirty buffers we see (up to a maximum that is due to IO
> _latency_, not due to "how long since this buffer was dirtied")

OTOH, we don't want flushing to _stop_ early because we already
submitted lots of IO ;)

Rik
--
Executive summary of a recent Microsoft press release:
   "we are concerned about the GNU General Public License (GPL)"


		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
