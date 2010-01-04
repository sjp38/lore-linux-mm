Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E9CAE600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 12:21:26 -0500 (EST)
Date: Mon, 4 Jan 2010 17:21:26 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] mm: move sys_mmap_pgoff from util.c
In-Reply-To: <20100104123858.GA5045@us.ibm.com>
Message-ID: <alpine.LSU.2.00.1001041716370.9825@sister.anvils>
References: <alpine.LSU.2.00.0912302009040.30390@sister.anvils> <20100104123858.GA5045@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <ebmunson@us.ibm.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 4 Jan 2010, Eric B Munson wrote:
> On Wed, 30 Dec 2009, Hugh Dickins wrote:
> 
> > Move sys_mmap_pgoff() from mm/util.c to mm/mmap.c and mm/nommu.c,
> > where we'd expect to find such code: especially now that it contains
> > the MAP_HUGETLB handling.  Revert mm/util.c to how it was in 2.6.32.
> > 
> > This patch just ignores MAP_HUGETLB in the nommu case, as in 2.6.32,
> > whereas 2.6.33-rc2 reported -ENOSYS.  Perhaps validate_mmap_request()
> > should reject it with -EINVAL?  Add that later if necessary.
> > 
> > Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> 
> I think that -ENOSYS is the correcet response in the nommu case, but
> I that can be added in a later patch.
> 
> Acked-by: Eric B Munson <ebmunson@us.ibm.com>

Thanks.  I had believed -ENOSYS was solely for unsupported system calls,
so thought it inappropriate here; but we seem to have quite a few places
which are using it indeed for "Function not implemented", and -EINVAL is
always so very overloaded that an alternative can be a lot more helpful.
Okay, I'll send a patch to give -ENOSYS for MAP_HUGETLB on nommu, which
will be consistent with mmu.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
