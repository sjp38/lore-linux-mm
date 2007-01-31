Date: Wed, 31 Jan 2007 19:17:54 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] simplify shmem_aops.set_page_dirty method
In-Reply-To: <20070131111146.2b29d851.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0701311915230.19297@blonde.wat.veritas.com>
References: <b040c32a0701302006y429dc981u980bee08f6a42854@mail.gmail.com>
 <Pine.LNX.4.64.0701311648450.28314@blonde.wat.veritas.com>
 <20070131111146.2b29d851.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Ken Chen <kenchen@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 Jan 2007, Andrew Morton wrote:
> On Wed, 31 Jan 2007 17:17:10 +0000 (GMT) Hugh Dickins <hugh@veritas.com> wrote:
> 
> > 2.  Please remind me what good __mark_inode_dirty will do for shmem:
> 
> None that I can think of - tmpfs inodes don't get written back to swap (do
> they?)

That's right, tmpfs inodes are only in RAM, only the data can go to swap.

> 
> > in my patch the equivalent function did nothing beyond SetPageDirty
> > (your TestSetPageDirty looks better, less redirtying the cacheline).
> 
> Will test_and_set_bit() avoid dirtying the cacheline?  I guess it _could_
> do this, and perhaps this depends upon the architecture.  Perhaps
> 
> 	if (!PageDirty(page))
> 		SetPageDirty(page);
> 
> would be better here.

Synchronicity or telepathy?  Our mails on that crossed.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
