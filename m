Date: Wed, 19 Jun 2002 13:21:29 -0700 (MST)
From: Craig Kulesa <ckulesa@as.arizona.edu>
Subject: Re: [PATCH] (1/2) reverse mapping VM for 2.5.23 (rmap-13b)
In-Reply-To: <Pine.LNX.4.44.0206192151390.20865-100000@e2>
Message-ID: <Pine.LNX.4.44.0206191310590.4292-100000@loke.as.arizona.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Rik van Riel <riel@conectiva.com.br>, Dave Jones <davej@suse.de>, Daniel Phillips <phillips@bonn-fries.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, rwhron@earthlink.net
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jun 2002, Ingo Molnar wrote:

> btw., isnt there a fair chance that by 'fixing' the aging+rmap code to
> swap out less, you'll ultimately swap in more? [because the extra swappout
> likely ended up freeing up RAM as well, which in turn decreases the amount
> of trashing.]

Agree.  Heightened swapout in this rather simplified example) isn't a 
problem in itself, unless it really turns out to be a bottleneck in a 
wide variety of loads.  As long as the *right* pages are being swapped 
and don't have to be paged right back in again.   

I'll try a more varied set of tests tonight, with cpu usage tabulated.

-Craig

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
