Date: Wed, 16 Aug 2000 18:06:03 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Syncing the page cache, take 2
In-Reply-To: <20000816214929.F4037@redhat.com>
Message-ID: <Pine.LNX.4.21.0008161800540.6164-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Daniel Phillips <daniel.phillips@innominate.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Aug 2000, Stephen C. Tweedie wrote:
> On Wed, Aug 16, 2000 at 12:14:33AM +0200, Daniel Phillips wrote:
> > > 
> > > (and even more ... we just about *need* the flush callback when
> > > we're running in a multi-queue VM)
> > 
> > OK, but what about the case where the filesystem knows it wants the page
> > cache to flush *right now*?  For example, when a filesystem wants to be
> > sure the page cache is synced through to buffers just before marking a
> > consistent state in the journal, say.  How does it make that happen?
> 
> Correct --- remember, Rik, that we talked about this?  It's not just
> enough for the VM to call the address-space to flush dirty pages: you
> also need to delegate the ability to manipulate the dirty status to
> the fs.  In other words, you need a mark_page_dirty/clean() for pages
> just as you already have for buffers.  
> 
> Do that and the filesystems can do pretty much what they want in
> response to the callback.

Indeed. I'll get to work on this right after the new VM patch
is tuned to a level where it works fine for everybody.

(I need to add something to keep the pagecache small during
very heavy, use-once, IO)

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
