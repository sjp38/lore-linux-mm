Date: Sat, 28 May 2005 09:49:29 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: manual page migration and madvise/mbind
Message-ID: <20050528084929.GA19027@infradead.org>
References: <428A1F6F.2020109@engr.sgi.com> <20050518012627.GA33395@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050518012627.GA33395@muc.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: Ray Bryant <raybry@engr.sgi.com>, Christoph Hellwig <hch@engr.sgi.com>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Wed, May 18, 2005 at 03:26:27AM +0200, Andi Kleen wrote:
> > This is something quite a bit different than what madvise() or mbind()
> > do today.  (They just manipulate vma's AFAIK.)
> 
> Nah, mbind manipulates backing objects too, in particular for shared 
> memory. It is not right now implemented for files, but that was planned
> and Steve L's patches went into that direction with some limitations.
> 
> And yes, the state would need to be stored in the address_space, which
> is shared.  In my version it was in private backing store objects.
> Check Steve's patch.
> 
> The main problem I see with the "hack ld.so" approach is that it 
> doesn't work for non program files. So if you really want to handle
> them you would need a daemon that sets the policies once a file 
> is mapped or hack all the programs to set the policies. I don't
> see that as being practicable. Ok you could always add a "sticky" process
> policy that actually allocates mempolicies for newly read files
> and so marks them using your new flags. But that would seem
> somewhat ugly to me and is probably incompatible with your batch manager
> anyways.  The only sane way to handle arbitary files like this
> would be the xattr.

Storing the full memory policy in the extended attributes seems at least
a little less hackish then what's done currently.  We should read the policy
once at mmap time only instead of letting VM code poke into xattr details,
though.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
