Date: Thu, 29 Jun 2000 10:34:01 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: kmap_kiobuf()
Message-ID: <20000629103401.B3473@redhat.com>
References: <200006282016.PAA19321@jen.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200006282016.PAA19321@jen.americas.sgi.com>; from lord@sgi.com on Wed, Jun 28, 2000 at 03:16:42PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lord@sgi.com
Cc: "Stephen C. Tweedie" <sct@redhat.com>, David Woodhouse <dwmw2@infradead.org>, linux-mm@kvack.org, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 28, 2000 at 03:16:42PM -0500, lord@sgi.com wrote:

> So we are currently using memory managed as an address space to do the
> caching of metadata. Everything is built up out of single pages, and when we
> need something bigger we glue it together into a larger chunk of address
> space.

What do you mean by "address space"?  If you mean kernel VA, then
there's a clear risk of fragmenting the kernel's remappable area and
ending up unable to find contiguous regions at all if you're not
careful.

> p.s. Woudn't the remapping of pages be a way to let modules etc get larger
> arrays of memory after boot time - doing it a few times is not going to
> kill the system.

That's what vmalloc does.  If you mean actually moving physical pages
to clear space, it's really not so simple --- what happens if you
encounter mlock()ed pages?  The kernel also mixes user pages with
pinned kernel data structures which simply cannot be moved, so it's
not straightforward to support that sort of thing.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
