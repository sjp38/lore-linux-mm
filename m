Date: Mon, 10 Dec 2001 10:38:55 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: how has set_pgdir been replaced in 2.4.x
Message-ID: <20011210103855.A1919@redhat.com>
References: <3C147805.99B2EE4A@scs.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3C147805.99B2EE4A@scs.ch>; from maletinsky@scs.ch on Mon, Dec 10, 2001 at 09:53:25AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Maletinsky <maletinsky@scs.ch>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Dec 10, 2001 at 09:53:25AM +0100, Martin Maletinsky wrote:
 
> I noticed that in the 2.4.x Linux kernel the function set_pgdir() has gone (at least for most platforms). When looking at code that modifies kernel page tables (e.g.
> vmalloc_area_pages) I could not figure out, how the page global directories are kept consistent. It looks to me as if
> global page directory entries were modified in one global page directory (the swapper_pg_dir) only. If this is the case, I wonder how the modifications are 'propagated'
> into all the other global page directories

They are now faulted on demand for vmalloc.  The cost of manually
updating all the pgds for every vmalloc is just too expensive if
you've got tens of thousands of threads in the system.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
