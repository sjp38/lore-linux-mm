Date: Fri, 26 May 2000 08:49:57 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] 2.3/4 VM queues idea
In-Reply-To: <20000526121139.D10082@redhat.com>
Message-ID: <Pine.LNX.4.21.0005260848500.26570-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org, Matthew Dillon <dillon@apollo.backplane.com>, Arnaldo Carvalho de Melo <acme@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Fri, 26 May 2000, Stephen C. Tweedie wrote:
> On Wed, May 24, 2000 at 12:11:35PM -0300, Rik van Riel wrote:
> 
> > - try to keep about one second worth of allocations around in
> >   the inactive queue (we do 100 allocations/second -> at least
> >   100 inactive pages), we do this in order to:
> >   - get some aging in that queue (one second to be reclaimed)
> >   - have enough old pages around to free
> 
> Careful here.  If your box is running several Gig Ethernet
> interfaces, it could well be allocating 100s of MB of skbuffs
> every second, each allocation being very short-lived.  The rate
> of allocation is not a good indicator of memory load.  The rate
> of allocations which could not be satisfied immediately would be
> a far better metric.

Oh definately. The number of pages taken off of the cache
queue (aka. scavenge list) per second, averaged over time,
will probably be the measure to use.

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
