Date: Fri, 16 Jun 2000 12:08:06 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: kswapd eating too much CPU on ac16/ac18
In-Reply-To: <Pine.Linu.4.10.10006160724100.793-100000@mikeg.weiden.de>
Message-ID: <Pine.LNX.4.21.0006161203110.24794-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@weiden.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Cesar Eduardo Barros <cesarb@nitnet.com.br>, linux-kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 16 Jun 2000, Mike Galbraith wrote:
> On Wed, 14 Jun 2000, Alan Cox wrote:
> 
> > Im interested to know if ac9/ac10 is the slow->fast change point
> 
> ac5 is definately the breaking point.  ac5 doesn't survive make
> -j30.. starts swinging it's VM machette at everything in sight.  
> Reversing the VM changes to ac4 restores throughput to test1
> levels (11 minute build vs 21-26 minutes for everything
> forward).
> 
> Exact tested reversals below.  FWIW, page aging doesn't seem to
> be the problem.  I disabled that in ac17 and saw zero
> difference.  (What may or not be a hint is that the /* Let
> shrink_mmap handle this swapout. */ bit in vmscan.c does make a
> consistent difference.  Reverting that bit alone takes a minimum
> of 4 minutes off build time)

Interesting. Not delaying the swapout IO completely broke
performance under the tests I did here...

Delayed swapout vs. non-delayed swapouts was the difference
between 300 swapouts/s vs. 700 swapouts/s  (under a load
with 400 swapins/s).

OTOH, I can imagine it being better if you have a very small
LRU cache, something like less than 1/2 MB.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
