Date: Mon, 3 Jul 2000 14:59:55 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: get_page_map in 2.2 vs 2.4
Message-ID: <20000703145955.C3284@redhat.com>
References: <20000630175015Z131177-21002+72@kanga.kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000630175015Z131177-21002+72@kanga.kvack.org>; from ttabi@interactivesi.com on Fri, Jun 30, 2000 at 12:38:19PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Jun 30, 2000 at 12:38:19PM -0500, Timur Tabi wrote:
> 
> In 2.4, it's been changed to this:
> 
> /* 
>  * Given a physical address, is there a useful struct page pointing to
>  * it?  This may become more complex in the future if we start dealing
>  * with IO-aperture pages in kiobufs.
>  */
> 
> static inline struct page * get_page_map(struct page *page)
> {
> 	if (page > (mem_map + max_mapnr))
> 		return 0;
> 	return page;
> }

Yes.  get_page_map() takes a "struct page *" which has been obtained
through some magic pointer arithmetic; we still have to do the bounds
checking to make sure that the resulting pointer pointed to a valid
part of the mem_map array.  The comment about IO aperture memory still
stands, as in the future we may want to support the creation of
additional mem_map arrays at run time to map struct page *'s beyond
the end of physical memory, to allow kiobuf I/O on things like
framebuffers.

> Am I missing something?  What was wrong with the original implementation?

It didn't work on IA32 systems with >=1GB memory.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
