Date: Mon, 9 Sep 2002 12:13:48 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [RFC] On paging of kernel VM.
Message-ID: <20020909121348.B4855@redhat.com>
References: <2653.1031563253@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2653.1031563253@redhat.com>; from dwmw2@infradead.org on Mon, Sep 09, 2002 at 10:20:53AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Sep 09, 2002 at 10:20:53AM +0100, David Woodhouse wrote:
> I think I'd like to introduce 'real' VMAs into kernel space, so that areas
> in the vmalloc range can have 'real' vm_ops and more to the point a real
> nopage function.

The alternative is a kmap-style mechanism for temporarily mapping
pages beyond physical memory on demand.  That would avoid the space
limits we have on vmalloc etc; there's only a few tens of MB of
address space we can use for mmap tricks in kernel space, so
persistent maps are seriously constrained if you've got a lot of flash
you want to map.

And with a kmap interface, your locking problems are much simpler ---
you can trap accesses at source and you don't have to go hunting ptes
to invalidate.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
