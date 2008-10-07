Date: Tue, 7 Oct 2008 15:38:44 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH, RFC, v2] shmat: introduce flag SHM_MAP_HINT
In-Reply-To: <20081007112631.GH20740@one.firstfloor.org>
Message-ID: <Pine.LNX.4.64.0810071532280.29910@blonde.site>
References: <20081006192923.GJ3180@one.firstfloor.org>
 <1223362670-5187-1-git-send-email-kirill@shutemov.name>
 <20081007082030.GD20740@one.firstfloor.org> <20081007100854.GA5039@localhost.localdomain>
 <20081007112631.GH20740@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 7 Oct 2008, Andi Kleen wrote:
> > I want say that we shouldn't do this check if shmaddr is a search hint.
> > I'm not sure that check is unneeded if shmadd is the exact address.
> 
> mmap should fail in this case because it does the same check for 
> MAP_FIXED. Obviously it cannot succeed when there is already something
> else there.

I'm not really following this, so forgive me if I'm reading you
out of context, but I think you're wrong on that...

The dangerous feature of mmap MAP_FIXED (why we don't usually use
it except within an address range we've already staked out earlier)
is that it does unmap whatever stands in its way.  See the early
	if (flags & MAP_FIXED)
		return addr;
in arch_get_unmapped_area(), and the do_munmap() in mmap_region().

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
