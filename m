Message-Id: <200006291345.IAA21962@jen.americas.sgi.com>
Subject: Re: kmap_kiobuf() 
In-Reply-To: Message from "Stephen C. Tweedie" <sct@redhat.com>
   of "Thu, 29 Jun 2000 10:34:01 BST." <20000629103401.B3473@redhat.com>
Date: Thu, 29 Jun 2000 08:45:45 -0500
From: Steve Lord <lord@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: lord@sgi.com, David Woodhouse <dwmw2@infradead.org>, linux-mm@kvack.org, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

> Hi,
> 
> On Wed, Jun 28, 2000 at 03:16:42PM -0500, lord@sgi.com wrote:
> 
> > So we are currently using memory managed as an address space to do the
> > caching of metadata. Everything is built up out of single pages, and when w
e
> > need something bigger we glue it together into a larger chunk of address
> > space.
> 
> What do you mean by "address space"?  If you mean kernel VA, then
> there's a clear risk of fragmenting the kernel's remappable area and
> ending up unable to find contiguous regions at all if you're not
> careful.

Sorry, I used the same term for two different things there, we cache meta
data in a 'struct address_space', the second one is the problem issue. XFS
is doing 'bad things' with address space remapping to take a handful of
previously existing pages and remapping them to appear as one chunk of
memory. We do not usually have that many in existence at once. I think it
has pretty much been established that this is not going to be acceptable
in the long term - I always knew that was likely.

Running with a bigger PAGE_CACHE_SIZE will help, some of the code in XFS
may be changable to work without treating the metadata object as a single
chunk of memory, and we may be able to come up with some other tricks too.

Steve



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
