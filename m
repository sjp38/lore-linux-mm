Date: Sun, 5 Aug 2001 15:40:39 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <996985193.982.7.camel@gromit>
Message-ID: <Pine.LNX.4.21.0108051540010.10618-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Rothwell <rothwell@holly-springs.nc.us>
Cc: Linus Torvalds <torvalds@transmeta.com>, Mike Black <mblack@csihq.com>, Ben LaHaise <bcrl@redhat.com>, Daniel Phillips <phillips@bonn-fries.net>, Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <andrewm@uow.edu.au>
List-ID: <linux-mm.kvack.org>


On 5 Aug 2001, Michael Rothwell wrote:

> On 04 Aug 2001 10:08:56 -0700, Linus Torvalds wrote:
> > 
> > On Sat, 4 Aug 2001, Mike Black wrote:
> > >
> > > I'm testing 2.4.8-pre4 -- MUCH better interactivity behavior now.
> > 
> > Good.. However.. [...]  before we get too happy about the interactive thing, let's
> > remember that sometimes interactivity comes at the expense of throughput,
> > and maybe if we fix the throughput we'll be back where we started.
> 
> Could there be both interactive and throughput optimizations, and a way
> to choose one or the other at run-time? Or even just at compile time? 

You can increase the queue size (somewhere in drivers/block/ll_rw_block.c)
to get higher throughtput.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
