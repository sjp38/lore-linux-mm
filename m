Date: Sat, 17 Jun 2000 06:04:21 +0200 (CEST)
From: Mike Galbraith <mikeg@weiden.de>
Subject: Re: kswapd eating too much CPU on ac16/ac18
In-Reply-To: <20000617000527.A5485@cesarb.personal>
Message-ID: <Pine.Linu.4.10.10006170555400.662-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cesar Eduardo Barros <cesarb@nitnet.com.br>
Cc: Rik van Riel <riel@conectiva.com.br>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 17 Jun 2000, Cesar Eduardo Barros wrote:

> > OTOH, I can imagine it being better if you have a very small
> > LRU cache, something like less than 1/2 MB.
> 
> You can imagine it being better in some random rare condition I don't care
> about. People have been noticing speed problems related to kswapd. This is not
> microkernel research.

ahem.

If you can do better, please do.   If not, give the man the feedback
he needs to find/fix the problems and spare us such useless comments.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
