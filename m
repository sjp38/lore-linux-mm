Date: Wed, 27 Aug 2003 12:09:52 -0400 (EDT)
From: "Raghu R. Arur" <rra2002@aria.ncl.cs.columbia.edu>
Subject: Re: mapped pages
In-Reply-To: <20030827160330.GI22495@holomorphy.com>
Message-ID: <Pine.GSO.4.51.0308271204340.24276@aria.ncl.cs.columbia.edu>
References: <Pine.GSO.4.51.0308271154030.24276@aria.ncl.cs.columbia.edu>
 <20030827160330.GI22495@holomorphy.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 So this means that I need to use try_to_release_page() on only those
mapped pages that have page->buffer non-null. Otherwise releasepage
functions of the address space crash. And if I have to return a mapped
page to the freelist that have page->buffer null, i just have to do
__remove_inode_page. I am speaking in the context of 2.4 kernel. Am I
right.

 Thanks a lot,
 Raghu


On Wed, 27 Aug 2003, William Lee Irwin III wrote:

> On Wed, Aug 27, 2003 at 11:55:09AM -0400, Raghu R. Arur wrote:
> >  Do all mapped pages have buffers? Is there a possibility that a mapped
> > page to have its page->buffer to be NULL
>
> No to the first question, yes to the second.
>
> -- wli
>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
