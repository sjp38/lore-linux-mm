Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id EA75D3B6BA
	for <linux-mm@kvack.org>; Wed, 10 Oct 2001 18:44:20 -0300 (EST)
Date: Wed, 10 Oct 2001 18:44:13 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [CFT][PATCH] smoother VM for -ac
In-Reply-To: <Pine.LNX.4.33L.0110101815140.26495-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.33L.0110101842590.26495-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

On Wed, 10 Oct 2001, Rik van Riel wrote:
> On Wed, 10 Oct 2001, Benjamin LaHaise wrote:

> > There's a small problem with this one: I know that during
> > testing of earlier 2.4 kernels we saw a livelock which was
> > caused by the vm subsystem spinning without scheduling.

I added back the reschedule at the zone->pages_min() limit
and have documented this piece of black magic. New patch
can be found at:

	http://www.surriel.com/patches/

regards,

Rik
-- 
DMCA, SSSCA, W3C?  Who cares?  http://thefreeworld.net/  (volunteers needed)

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
