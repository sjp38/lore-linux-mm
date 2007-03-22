Date: Wed, 21 Mar 2007 19:31:56 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: pagetable_ops: Hugetlb character device example
Message-ID: <20070322003156.GQ4892@waste.org>
References: <20070319200502.17168.17175.stgit@localhost.localdomain> <1174506228.21684.41.camel@localhost.localdomain> <200703211951.l2LJpVPS020364@turing-police.cc.vt.edu> <20070321222659.GJ2986@holomorphy.com> <20070321225348.GO10459@waste.org> <20070321233528.GL2986@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070321233528.GL2986@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Valdis.Kletnieks@vt.edu, Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, Christoph Hellwig <hch@infradead.org>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 21, 2007 at 04:35:28PM -0700, William Lee Irwin III wrote:
> On Wed, Mar 21, 2007 at 03:26:59PM -0700, William Lee Irwin III wrote:
> >> My exit strategy was to make hugetlbfs an alias for ramfs when ramfs
> >> acquired the necessary functionality until expand-on-mmap() was merged.
> >> That would've allowed rm -rf fs/hugetlbfs/ outright. A compatibility
> >> wrapper for expand-on-mmap() around ramfs once ramfs acquires the
> >> necessary functionality is now the exit strategy.
> 
> On Wed, Mar 21, 2007 at 05:53:48PM -0500, Matt Mackall wrote:
> > Can you describe what ramfs needs here in a bit more detail?
> > If it's non-trivial, I'd rather see any new functionality go into
> > shmfs/tmpfs, as ramfs has done a good job at staying a minimal fs thus
> > far.
> 
> I was referring to fully-general multiple pagesize support. ramfs
> would inherit the functionality by virtue of generic pagecache and TLB
> handling in such an arrangement. It doesn't make sense to modify ramfs
> as a special case; hugetlb is as it stands a ramfs special-cased for
> such purposes.

Ahh, I see.

Good luck!

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
