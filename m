Date: Wed, 4 Feb 2004 20:54:35 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 0/5] mm improvements
In-Reply-To: <20040204103307.7a288ce3.akpm@osdl.org>
Message-ID: <Pine.LNX.4.44.0402042047040.4021-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nikita@Namesys.COM, piggin@cyberone.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Feb 2004, Andrew Morton wrote:
> Hugh Dickins <hugh@veritas.com> wrote:
> >
> >  Sorry, that BUG_ON is there for very good reason.  It's no disgrace
> >  that your testing didn't notice the effect of passing a mapped page
> >  down to shmem_writepage, but it is a serious breakage of tmpfs.
> 
> hm.  Can't I force writepage-of-a-mapped-page with msync()?

I hope not, __filemap_fdatawrite still starts off with:

	if (mapping->backing_dev_info->memory_backed)
		return 0;

Once upon a time you did have vmscan.c calling ->writepages, rather
the effect that Nikita is trying for.  It was that writepages which
led me to insert the BUG_ON and give tmpfs a dummy writepages.
Later on you dropped the ->writepages from vmscan.c:
do you remember why? would be useful info for Nikita.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
