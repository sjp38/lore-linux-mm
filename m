Date: Wed, 19 Jun 2002 14:18:31 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] (2/2) reverse mappings for current 2.5.23 VM
In-Reply-To: <E17Kipf-0000uu-00@starship>
Message-ID: <Pine.LNX.4.44L.0206191417290.2598-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Craig Kulesa <ckulesa@as.arizona.edu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jun 2002, Daniel Phillips wrote:

> > > 2.5.23-rmap (this patch -- "rmap-minimal"):
> > > Total kernel swapouts during test = 24068 kB
> > > Total kernel swapins during test  =  6480 kB
> > > Elapsed time for test: 133 seconds
> > >
> > > 2.5.23-rmap13b (Rik's "rmap-13b complete") :
> > > Total kernel swapouts during test = 40696 kB
> > > Total kernel swapins during test  =   380 kB
> > > Elapsed time for test: 133 seconds

> You might conclude from the above that the lru+rmap is superior to
> aging+rmap: while they show the same wall-clock time, lru+rmap consumes
> considerably less disk bandwidth.  Naturally, it would be premature to
> conclude this from one trial on one load.

On the contrary, aging+rmap shows a lot less swapins.

The fact that it has more swapouts than needed means
we need to fix one aspect of the thing (page_launder),
it doesn't mean we should get rid of the whole thing.

kind regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
