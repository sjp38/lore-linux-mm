Date: Wed, 25 Aug 2004 21:59:30 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [Bug 3268] New: Lowmemory exhaustion problem with v2.6.8.1-mm4
    16gb
In-Reply-To: <20040825135308.2dae6a5d.akpm@osdl.org>
Message-ID: <Pine.LNX.4.44.0408252157300.2738-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: kmannth@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Aug 2004, Andrew Morton wrote:
> Hugh Dickins <hugh@veritas.com> wrote:
> >
> > (hmm, does lowmem shortage exert
> >  any pressure on highmem cache these days, I wonder?);
> 
> It does, indirectly - when we reclaim an unused inode we also shoot down
> all that inode's pagecache.

Not much help in the tmpfs case, where the inode cannot get to be unused
without being deleted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
