Date: Wed, 4 Feb 2004 15:03:39 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 0/5] mm improvements
In-Reply-To: <16416.64425.172529.550105@laputa.namesys.com>
Message-ID: <Pine.LNX.4.44.0402041459420.3574-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <Nikita@Namesys.COM>
Cc: Nick Piggin <piggin@cyberone.com.au>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Feb 2004, Nikita Danilov wrote:
> Hugh Dickins writes:
>  > If you go the writepage-while-mapped route (more general gotchas?
>  > I forget), you'll have to make an exception for shmem_writepage.
> 
> May be one can just call try_to_unmap() from shmem_writepage()?

That sounds much cleaner.  But I've not yet found what tree your
p12-dont-unmap-on-pageout.patch applies to, so cannot judge it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
