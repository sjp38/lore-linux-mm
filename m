Date: Wed, 3 Nov 1999 22:41:40 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: Why don't we make mmap MAP_SHARED with /dev/zero possible?
In-Reply-To: <Pine.LNX.3.96.991103142946.27233D-100000@kanga.kvack.org>
Message-ID: <Pine.LNX.4.10.9911032238560.11820-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: fxzhang@chpc.ict.ac.cn, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Nov 1999, Benjamin C.R. LaHaise wrote:

> > it's now an unconditional __GFP_HIGHMEM in my tree. HIGHMEM gfp()
> > allocation automatically falls back to allocate in lowmem, if highmem
> > lists are empty.
> 
> I'd like to look through the patches to see how you're doing things before
> making any comments.  Specifically, I want to look at the buffer head

(soon, probably tomorrow)

> address thing that was mentioned -- given that the devices that support
> addressing memory above 4G will expect a 64 bit address, I don't think the
> shift is the right way to go.

i introduced bh->b_page _specifically_ to support 64-bit addresses. Below
<4GB RAM DMA32 can be supported with no IO-layer changes. Right now it
supports up to 2TB DMA64 target space (on 32-bit boxes), which is more
than enough.

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
