Date: Tue, 25 Apr 2000 12:09:55 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
In-Reply-To: <20000424212516.A4019@stormix.com>
Message-ID: <Pine.LNX.4.21.0004251208520.10408-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Simon Kirby <sim@stormix.com>
Cc: linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Ben LaHaise <bcrl@redhat.com>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Mon, 24 Apr 2000, Simon Kirby wrote:
> On Sat, Apr 22, 2000 at 11:08:35PM -0300, Rik van Riel wrote:
> 
> > the following patch makes VM in 2.3.99-pre6+ behave more nice
> > than in previous versions. It does that by:

[snip]

> 0 2 0  17204  2728  3544  60088   0  40   452   10  434  1788   1   5  94
> 1 1 0  17236  2932  3588  59752   0  32   253    8  333  1591  12  38  50
> 
> It seems a bit odd that it is swapping out here when there is a
> lot of cache memory available.

If you look closer, you'll see that none of the swapped out
stuff is swapped back in again. This shows that the VM
subsystem did make the right choice here...

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
