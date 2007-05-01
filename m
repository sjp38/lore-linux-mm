Subject: Re: 2.6.22 -mm merge plans
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	<84144f020705010217j738e461ey6b09fd738574fb70@mail.gmail.com>
From: Andi Kleen <andi@firstfloor.org>
Date: 01 May 2007 14:19:45 +0200
In-Reply-To: <84144f020705010217j738e461ey6b09fd738574fb70@mail.gmail.com>
Message-ID: <p73y7k8ybvi.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hch@lst.de, npiggin@suse.de, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

"Pekka Enberg" <penberg@cs.helsinki.fi> writes:

> On 5/1/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> >  revoke-special-mmap-handling.patch
> 
> [snip]
> 
> > Hold.  This is tricky stuff and I don't think we've seen sufficient
> > reviewing, testing and acking yet?
> 
> Agreed. While Peter and Nick have done some review of the patches, I
> would really like VFS maintainers to review them before merge.
> Christoph, have you had the chance to take a look at it?

Also have the cache performance concerns raised on the original review
been addressed?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
