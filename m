Date: Wed, 7 Jun 2000 16:35:19 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel: it'snot just the code)
Message-ID: <20000607163519.S30951@redhat.com>
References: <20000607144102.F30951@redhat.com> <Pine.LNX.4.21.0006071103560.14304-100000@duckman.distro.conectiva> <20000607154620.O30951@redhat.com> <yttog5decvq.fsf@serpe.mitica>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <yttog5decvq.fsf@serpe.mitica>; from quintela@fi.udc.es on Wed, Jun 07, 2000 at 05:20:41PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Quintela Carreira Juan J." <quintela@fi.udc.es>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Hans Reiser <hans@reiser.to>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 07, 2000 at 05:20:41PM +0200, Quintela Carreira Juan J. wrote:
> 
> stephen> It doesn't matter.  *If* the filesystem knows better than the 
> stephen> page cleaner what progress can be made, then let the filesystem
> stephen> make progress where it can.  There are likely to be transaction
> stephen> dependencies which mean we have to clean some pages in a specific
> stephen> order.  As soon as the page cleaner starts exerting back pressure
> stephen> on the filesystem, the filesystem needs to start clearing stuff,
> stephen> and if that means we have to start cleaning things that shrink_
> stephen> mmap didn't expect us to, then that's fine.
> 
> I don't like that, if you put some page in the LRU cache, that means
> that you think that _this_ page is freeable.

Remember that Rik is talking about multiple LRUs.  Pages can only
be on the inactive LRU if they are clean and unpinned, yes, but we
still need a way of tracking pages which are in a more difficult
state.

> If you need pages in the LRU cache only for getting notifications,
> then change the system to send notifications each time that we are
> short of memory.

It's a matter of pressure.  The filesystem with most pages in the LRU
cache, or with the oldest pages there, should stand the greatest chance
of being the first one told to clean up its act.

Cheers, 
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
