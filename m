Date: Mon, 22 Nov 2004 14:31:02 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH]: 3/4 mm/rmap.c cleanup
In-Reply-To: <20041121131437.4c3bcee0.akpm@osdl.org>
Message-ID: <Pine.LNX.4.44.0411221428080.2867-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nikita Danilov <nikita@clusterfs.com>, Linux-Kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 21 Nov 2004, Andrew Morton wrote:
> Nikita Danilov <nikita@clusterfs.com> wrote:
> >
> > mm/rmap.c:page_referenced_one() and mm/rmap.c:try_to_unmap_one() contain
> >  identical code that
> > 
> >   - takes mm->page_table_lock;
> > 
> >   - drills through page tables;
> > 
> >   - checks that correct pte is reached.
> > 
> >  Coalesce this into page_check_address()
> 
> Looks sane, but it comes at a bad time.  Please rework and resubmit after
> the 4-level pagetable code is merged into Linus's tree, post-2.6.10.

Personally, I prefer the straightforward way it looks without Nikita's
patch.  But it is a matter of personal taste, and I may well be in the
minority.

Would be better justified if the common function were not "inline"?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
