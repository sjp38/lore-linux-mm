Message-ID: <393E8204.D7AAACC5@timpanogas.com>
Date: Wed, 07 Jun 2000 11:10:28 -0600
From: "Jeff V. Merkey" <jmerkey@timpanogas.com>
MIME-Version: 1.0
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:
 it'snot just the code)
References: <20000607144102.F30951@redhat.com> <Pine.LNX.4.21.0006071103560.14304-100000@duckman.distro.conectiva> <20000607154620.O30951@redhat.com> <yttog5decvq.fsf@serpe.mitica> <20000607163519.S30951@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Quintela Carreira Juan J." <quintela@fi.udc.es>, Rik van Riel <riel@conectiva.com.br>, Hans Reiser <hans@reiser.to>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

Stephen,

When will the journalling subsystem you are working on be available, and
where can I get it to start integration work.  It sounds like you will
be "bundling"  associated LRU meta-data blocks in the buffer cache for
journal commits?  What Alan described to me sounds fairly decent.  I am
wondering when you will have this posted so the rest of us can
instrument your journalling code into our FS's.

Please advise.

:-)

Jeff 

"Stephen C. Tweedie" wrote:
> 
> Hi,
> 
> On Wed, Jun 07, 2000 at 05:20:41PM +0200, Quintela Carreira Juan J. wrote:
> >
> > stephen> It doesn't matter.  *If* the filesystem knows better than the
> > stephen> page cleaner what progress can be made, then let the filesystem
> > stephen> make progress where it can.  There are likely to be transaction
> > stephen> dependencies which mean we have to clean some pages in a specific
> > stephen> order.  As soon as the page cleaner starts exerting back pressure
> > stephen> on the filesystem, the filesystem needs to start clearing stuff,
> > stephen> and if that means we have to start cleaning things that shrink_
> > stephen> mmap didn't expect us to, then that's fine.
> >
> > I don't like that, if you put some page in the LRU cache, that means
> > that you think that _this_ page is freeable.
> 
> Remember that Rik is talking about multiple LRUs.  Pages can only
> be on the inactive LRU if they are clean and unpinned, yes, but we
> still need a way of tracking pages which are in a more difficult
> state.
> 
> > If you need pages in the LRU cache only for getting notifications,
> > then change the system to send notifications each time that we are
> > short of memory.
> 
> It's a matter of pressure.  The filesystem with most pages in the LRU
> cache, or with the oldest pages there, should stand the greatest chance
> of being the first one told to clean up its act.
> 
> Cheers,
>  Stephen
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.rutgers.edu
> Please read the FAQ at http://www.tux.org/lkml/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
