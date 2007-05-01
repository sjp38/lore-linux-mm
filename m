Date: Tue, 1 May 2007 10:24:48 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: 2.6.22 -mm merge plans
Message-ID: <20070501092448.GA21263@infradead.org>
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <84144f020705010217j738e461ey6b09fd738574fb70@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020705010217j738e461ey6b09fd738574fb70@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hch@lst.de, npiggin@suse.de, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

On Tue, May 01, 2007 at 12:17:28PM +0300, Pekka Enberg wrote:
> On 5/1/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> > revoke-special-mmap-handling.patch
> 
> [snip]
> 
> >Hold.  This is tricky stuff and I don't think we've seen sufficient
> >reviewing, testing and acking yet?
> 
> Agreed. While Peter and Nick have done some review of the patches, I
> would really like VFS maintainers to review them before merge.
> Christoph, have you had the chance to take a look at it?

Not so far, but it's on my long list of highly useful things I want to review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
