Date: Fri, 9 Jun 2000 12:08:23 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:
 it'snot just the code)
In-Reply-To: <393ECB3C.91299E78@colorfullife.com>
Message-ID: <Pine.LNX.4.21.0006091207360.31358-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Jun 2000, Manfred Spraul wrote:
> "Stephen C. Tweedie" wrote:
> > On Wed, Jun 07, 2000 at 11:40:47PM +0200, Juan J. Quintela wrote:
> > > Hi
> > > Fair enough, don't put pinned pages in the LRU, *why* do you want put
> > > pages in the LRU if you can't freed it when the LRU told it: free that
> > > page?
> > 
> > Because even if the information about which page is least recently
> > used doesn't help you, the information about which filesystems are
> > least active _does_ help.
> 
> What about using a time based aproach for pinned pages?
> 
> * only individually freeable pages are added into the LRU.
> * everyone else registers callbacks.
> * shrink_mmap estimates (*) the age (in jiffies) of the oldest entry in
> the LRU, and then it calls the pressure callbacks with that time.

This is exactly what one global LRU will achieve, at less
cost and with better readable code.

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
