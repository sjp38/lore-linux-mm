Date: Tue, 9 May 2000 12:12:46 -0400
From: Simon Kirby <sim@stormix.com>
Subject: Re: [PATCH] Recent VM fiasco - fixed
Message-ID: <20000509121246.A8487@stormix.com>
References: <qwwpuqwp1tv.fsf@sap.com> <Pine.LNX.4.10.10005090844050.1100-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.10.10005090844050.1100-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Tue, May 09, 2000 at 08:44:43AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Tue, May 09, 2000 at 08:44:43AM -0700, Linus Torvalds wrote:

> On 9 May 2000, Christoph Rohland wrote:
> 
> > Daniel Stone <tamriel@ductape.net> writes:
> > 
> > > That's astonishing, I'm sure, but think of us poor bastards who
> > > DON'T have an SMP machine with >1gig of RAM.
> > 
> > He has to care obout us fortunate guys with e.g. 8GB memory also. The
> > recent kernels are broken for that also.
> 
> Try out the really recent one - pre7-8. So far it hassome good reviews,
> and I've tested it both on a 20MB machine and a 512MB one..

On my box with 128 MB dual SMP 450 MHz box, there's still definitely
something broken (pre7-8).  I notice it most with mutt loading the
linux-kernel folder... The folder is about 54 MB, and it takes kswapd
about 3 to 4 seconds of CPU time to clear out old stuff when it loads. 
This is pretty bad considering mutt itself takes only about 5 seconds
of real time to load the folder.

The main thing that fills up my cache is mainly playback of MP3s off
disk, which is pretty much running all the time.  If I open the folder,
quit, let MP3 playing fill eat up the free memory into cache, and then
run mutt again, kswapd use goes up 3 or 4 seconds further again.

I never used to see this with 2.2 kernels...

Simon-

[  Stormix Technologies Inc.  ][  NetNation Communications Inc. ]
[       sim@stormix.com       ][       sim@netnation.com        ]
[ Opinions expressed are not necessarily those of my employers. ]
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
