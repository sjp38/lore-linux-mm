Date: Tue, 7 Aug 2007 16:44:31 +1000
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: + hugetlb-allow-extending-ftruncate-on-hugetlbfs.patch added to -mm tree
Message-ID: <20070807064431.GC8351@localhost.localdomain>
References: <200708061830.l76IUA6j008338@imap1.linux-foundation.org> <20070807041559.GH13522@localhost.localdomain> <b040c32a0708062128r42d6a067l3a0c8c3818660e13@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b040c32a0708062128r42d6a067l3a0c8c3818660e13@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: akpm@linux-foundation.org, agl@us.ibm.com, nacc@us.ibm.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 06, 2007 at 09:28:01PM -0700, Ken Chen wrote:
> On 8/6/07, David Gibson <david@gibson.dropbear.id.au> wrote:
> > Ken, is this quite sufficient?  At least if we're expanding a
> > MAP_SHARED hugepage mapping, we should pre-reserve hugepages on an
> > expanding ftruncate().
> 
> why do we need to reserve them?  mmap segments aren't extended, e.g.
> vma length remains the same.  We only expand file size.

Well.. I suppose it doesn't have to (sorry, I was thinking of my old
version of reservation, where the file's reserve was based on the file
size rather than permitting non-contiguous reserved regions).

But since ftruncate()ing to shorten unreserves pages, it would seem
logical that ftruncate()ing to lengthen would reserve them.  In
general the notion of reserved pages for shared mappings is a
reservation in the inode address space, rather than a reservation for
any process's particular mapping of it.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
