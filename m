Date: Tue, 15 Apr 2003 07:52:29 +0200
From: Antonio Vargas <wind@cocodriloo.com>
Subject: Re: 2.5.67-mm3
Message-ID: <20030415055229.GJ14552@wind.cocodriloo.com>
References: <20030414015313.4f6333ad.akpm@digeo.com> <20030415020057.GC706@holomorphy.com> <20030415041759.GA12487@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030415041759.GA12487@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 14, 2003 at 09:17:59PM -0700, William Lee Irwin III wrote:
> On Mon, Apr 14, 2003 at 07:00:57PM -0700, William Lee Irwin III wrote:
> > Hence, this "FIXME: do not do for zone highmem". Presumably this is a
> 
> Another FIXME patch:
> 
> 
> It's a bit of an open question as to how much of a difference this one
> makes now, but it says "FIXME". fault_in_pages_writeable() and 
> fault_in_pages_readable() have a limited "range" with respect to the
> size of the region they can prefault; as they are now, they are only
> meant to handle spanning a page boundary. This converts them to iterate
> over the virtual address range specified and so touch each virtual page
> within it once as specified. As per the comment within the "FIXME",
> this is only an issue if PAGE_SIZE < PAGE_CACHE_SIZE.
> 
> [patch snip]

Page clustering? I did a simple patch yesterday called "cow-ahead", which
may be related: on a write to a COW page, it breaks the COW from several pages
at the same time. The implementation survived a complete debian 2.2 boot
and a fork bomb. Please have a look. The idea came from a discussion with
Martin J. Bligh... we liked the name too much not to implement it.

Greets, Antonio.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
