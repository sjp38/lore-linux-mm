Date: Wed, 7 Jun 2000 15:46:20 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel: it'snot just the code)
Message-ID: <20000607154620.O30951@redhat.com>
References: <20000607144102.F30951@redhat.com> <Pine.LNX.4.21.0006071103560.14304-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0006071103560.14304-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Wed, Jun 07, 2000 at 11:27:56AM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Hans Reiser <hans@reiser.to>, "Quintela Carreira Juan J." <quintela@fi.udc.es>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 07, 2000 at 11:27:56AM -0300, Rik van Riel wrote:
> 
> > I'd imagine reiserfs can do something similar, but even if not,
> > it's not important if the filesystem can't do its lookup by
> > page.
> 
> I don't necessarily agree on this point. What if our
> inactive list is filled with pages the filesystem somehow
> regards as new, and the filesystem will be busy flushing
> the "wrong" (in the eyes of the page stealer) pages?

It doesn't matter.  *If* the filesystem knows better than the 
page cleaner what progress can be made, then let the filesystem
make progress where it can.  There are likely to be transaction
dependencies which mean we have to clean some pages in a specific
order.  As soon as the page cleaner starts exerting back pressure
on the filesystem, the filesystem needs to start clearing stuff,
and if that means we have to start cleaning things that shrink_
mmap didn't expect us to, then that's fine.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
