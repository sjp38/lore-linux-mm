Date: Wed, 7 Jun 2000 11:10:33 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel: it's not just the code)
Message-ID: <20000607111033.B29432@redhat.com>
References: <20000606205447.T23701@redhat.com> <Pine.LNX.4.21.0006061956360.7328-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0006061956360.7328-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Tue, Jun 06, 2000 at 08:06:38PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Hans Reiser <hans@reiser.to>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Jun 06, 2000 at 08:06:38PM -0300, Rik van Riel wrote:
> 
> > journaling itself, but the transactional requirements which are
> > the problem --- basically the VM cannot do _anything_ about
> > individual pages which are pinned by a transaction, but rather
> > we need a way to trigger a filesystem flush, AND to prevent more
> > dirtying of pages by the filesystem (these are two distinct
> > problems), or we just lock up under load on lower memory boxes.
> 
> This is especially tricky in the case of a large mmap()ed
> file. We'll have to restrict the maximum number of read-write
> mapped pages from such a file in order to keep the system
> stable...

We need to restrict *all* pinned pages.  That includes writable
pages on a transactional filesystem, but also includes metadata
being used as part of an existing transaction, as well as any
potential metadata which *might* be used in the future by that
transaction.

> Indeed we need this. Since I seem to be coordinating the VM
> changes at the moment anyway, I'd love to work together with
> the journaling folks on solving this problem...

OK, I'll look up the old writeups I did with Chris about this.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
