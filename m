From: Blaisorblade <blaisorblade@yahoo.it>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Date: Fri, 28 Oct 2005 18:56:51 +0200
References: <1130366995.23729.38.camel@localhost.localdomain> <200510281303.56688.blaisorblade@yahoo.it> <20051028132915.GH5091@opteron.random>
In-Reply-To: <20051028132915.GH5091@opteron.random>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200510281856.52730.blaisorblade@yahoo.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Jeff Dike <jdike@addtoit.com>, Badari Pulavarty <pbadari@us.ibm.com>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Friday 28 October 2005 15:29, Andrea Arcangeli wrote:
> On Fri, Oct 28, 2005 at 01:03:56PM +0200, Blaisorblade wrote:
> > and when I'll get the time to finish the remap_file_pages changes* for
> > UML to use it, UML will _require_ this to be implemented too.

> Would it be possible to make remap_file_pages an option?

Kernel-compile time? Possibly yes...

> I mean, if 
> you're doing a xen-like usage, remap_file_pages is a good thing, but if
> you're in a multiuser system and you want to be friendly when the system
> swaps, remap_file_pages can hurt. The worst is when remap_file_pages
> covers huge large areas, that forces the vm to walk all the ptes for the
> whole vma region for each page that could be mapped by that region.
Insulting 2.4 this way is like when Microsoft said "Win98 could never be 
secure or reliable" :-) . That said, yes, 

Yes, this concern was expressed a bit by Hugh too, time ago...

I think that resurrecting Rik's rss ulimits would be good. Plus, fallbacking 
install_page to install_file_pte when the limit is hit.
-- 
Inform me of my mistakes, so I can keep imitating Homer Simpson's "Doh!".
Paolo Giarrusso, aka Blaisorblade (Skype ID "PaoloGiarrusso", ICQ 215621894)
http://www.user-mode-linux.org/~blaisorblade

	

	
		
___________________________________ 
Yahoo! Mail: gratis 1GB per i messaggi e allegati da 10MB 
http://mail.yahoo.it

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
