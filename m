Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [PATCH] (2/2) reverse mappings for current 2.5.23 VM
Date: Wed, 19 Jun 2002 19:01:23 +0200
References: <Pine.LNX.4.44L.0206190853190.2598-100000@imladris.surriel.com>
In-Reply-To: <Pine.LNX.4.44L.0206190853190.2598-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17Kipf-0000uu-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Craig Kulesa <ckulesa@as.arizona.edu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 19 June 2002 13:58, Rik van Riel wrote:
> > 2.5.22 vanilla:
> > Total kernel swapouts during test = 29068 kB
> > Total kernel swapins during test  = 16480 kB
> > Elapsed time for test: 141 seconds
> >
> > 2.5.23-rmap (this patch -- "rmap-minimal"):
> > Total kernel swapouts during test = 24068 kB
> > Total kernel swapins during test  =  6480 kB
> > Elapsed time for test: 133 seconds
> >
> > 2.5.23-rmap13b (Rik's "rmap-13b complete") :
> > Total kernel swapouts during test = 40696 kB
> > Total kernel swapins during test  =   380 kB
> > Elapsed time for test: 133 seconds
> 
> Interesting to see that both rmap versions have the same
> performance, it would seem that swapouts are much cheaper
> than waiting for a pagefault to swap something in ...

You might conclude from the above that the lru+rmap is superior to 
aging+rmap: while they show the same wall-clock time, lru+rmap consumes 
considerably less disk bandwidth.  Naturally, it would be premature to 
conclude this from one trial on one load.

These patches need benchmarking - lots of it, and preferrably in the next few 
days.

We need to see cpu stats as well.

-- 
Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
