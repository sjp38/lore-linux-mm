Date: Fri, 8 Feb 2002 11:07:47 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: addresses returned by __get_free_pages()
Message-ID: <20020208110747.A2354@redhat.com>
References: <3C63989D.5D973803@scs.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3C63989D.5D973803@scs.ch>; from maletinsky@scs.ch on Fri, Feb 08, 2002 at 10:21:33AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Maletinsky <maletinsky@scs.ch>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Feb 08, 2002 at 10:21:33AM +0100, Martin Maletinsky wrote:
 
> In the 2.4.x kernel, can I apply the virt_to_page() macro to any address allocated by __get_free_pages() (i.e. when calling ret = __get_free_pages(flags, order), to any
> address in the interval [retval,  2^order * PAGE_SIZE])?

Yes, but it's easier just to call "alloc_pages(flags, order)", which
returns a struct page in the first place.

> In other words are those addresses guaranteed to be kernel logical addresses (i.e. between PAGE_OFFSET and PAGE_OFFSET + high_memory (on ix86))?

Yes, unless you specify GFP_HIGHMEM in the allocation flags.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
