Date: Wed, 16 Aug 2000 21:49:29 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Syncing the page cache, take 2
Message-ID: <20000816214929.F4037@redhat.com>
References: <20000815194635.H12218@redhat.com> <Pine.LNX.4.21.0008151557040.2466-100000@duckman.distro.conectiva> <news2mail-3999C0C9.301BB475@innominate.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <news2mail-3999C0C9.301BB475@innominate.de>; from news-innominate.list.linux.mm@innominate.de on Wed, Aug 16, 2000 at 12:14:33AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <daniel.phillips@innominate.de>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Aug 16, 2000 at 12:14:33AM +0200, Daniel Phillips wrote:
> > 
> > (and even more ... we just about *need* the flush callback when
> > we're running in a multi-queue VM)
> 
> OK, but what about the case where the filesystem knows it wants the page
> cache to flush *right now*?  For example, when a filesystem wants to be
> sure the page cache is synced through to buffers just before marking a
> consistent state in the journal, say.  How does it make that happen?

Correct --- remember, Rik, that we talked about this?  It's not just
enough for the VM to call the address-space to flush dirty pages: you
also need to delegate the ability to manipulate the dirty status to
the fs.  In other words, you need a mark_page_dirty/clean() for pages
just as you already have for buffers.  

Do that and the filesystems can do pretty much what they want in
response to the callback.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
