Date: Mon, 24 Jun 2002 12:02:22 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] (1/2) reverse mapping VM for 2.5.23 (rmap-13b)
In-Reply-To: <Pine.LNX.4.44.0206192151390.20865-100000@e2>
Message-ID: <Pine.LNX.4.44L.0206241200310.3937-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Dave Jones <davej@suse.de>, Daniel Phillips <phillips@bonn-fries.net>, Craig Kulesa <ckulesa@as.arizona.edu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, rwhron@earthlink.net
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jun 2002, Ingo Molnar wrote:
> On Wed, 19 Jun 2002, Rik van Riel wrote:
>
> > I am encouraged by Craig's test results, which show that
> > rmap did a LOT less swapin IO and rmap with page aging even
> > less. The fact that it did too much swapout IO means one
> > part of the system needs tuning but doesn't say much about
> > the thing as a whole.
>
> btw., isnt there a fair chance that by 'fixing' the aging+rmap code to
> swap out less, you'll ultimately swap in more? [because the extra swappout
> likely ended up freeing up RAM as well, which in turn decreases the amount
> of trashing.]

Possibly, but I expect the 'extra' swapouts to be caused
by page_launder writing out too many pages at once and not
just the ones it wants to free.

Cleaning pages and freeing them are separate operations,
what is missing is a mechanism to clean enoughh pages but
not all inactive pages at once ;)

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
