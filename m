Date: Tue, 6 Jun 2000 21:12:32 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: memory pressure callbacks (was: 2.5 TODO)
Message-ID: <20000606211232.U23701@redhat.com>
References: <yttr9aahgrx.fsf@serpe.mitica> <Pine.LNX.4.10.10006061232040.9710-100000@home.suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10006061232040.9710-100000@home.suse.com>; from mason@suse.com on Tue, Jun 06, 2000 at 01:06:00PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <mason@suse.com>
Cc: "Quintela Carreira Juan J." <quintela@fi.udc.es>, sct@redhat.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, "reiserfs@devlinux.com" <reiserfs@devlinux.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Jun 06, 2000 at 01:06:00PM -0700, Chris Mason wrote:
> > 
> > Chris, I think that you don't want to put that in the address space
> > operations, the main reason is that you don't want your pages to stay
> > in the main LRU queue, because you need to freed them in an specific
> > order (not LRU at all).  Then if shrink_mmap is not scanning your
> > pages, it is better to use your own reclaim function, that would be
> > called from do_try_to_free_pages (a la shrink_[di]cache way).
> 
> The goal isn't to make something perfect for the journaled filesystems, it
> is a generic facility that also happens to work for the journaled
> filesystems.  So, I like the address space operations, mostly
> because this is an operation on an address space ;-)

Right.  There's one other major problem with a lot of page reclaim 
algorithms --- the algorithm can be the best in the world, but it needs
to be balanced against the other page stealers in the kernel too. 
Using the main LRUs for all filesystems, with address_space callbacks
to free pages, should make such balancing a lot easier to achieve.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
