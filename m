From: Nikita Danilov <Nikita@Namesys.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16416.64425.172529.550105@laputa.namesys.com>
Date: Wed, 4 Feb 2004 17:03:21 +0300
Subject: Re: [PATCH 0/5] mm improvements
In-Reply-To: <Pine.LNX.4.44.0402041337350.3479-100000@localhost.localdomain>
References: <16416.62172.489558.39126@laputa.namesys.com>
	<Pine.LNX.4.44.0402041337350.3479-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <piggin@cyberone.com.au>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins writes:
 > On Wed, 4 Feb 2004, Nikita Danilov wrote:
 > > 
 > > 4. I found that shmem_writepage() has BUG_ON(page_mapped(page))
 > > check. Its removal had no effect, and I am not sure why the check was
 > > there at all.
 > 
 > Sorry, that BUG_ON is there for very good reason.  It's no disgrace
 > that your testing didn't notice the effect of passing a mapped page
 > down to shmem_writepage, but it is a serious breakage of tmpfs.
 > 
 > I'd have to sit here thinking awhile to remember if there are further
 > reasons why it's a no-no.  But the reason that springs to mind is it
 > breaks the semantics of a tmpfs file mapped shared into different mms.
 > shmem_writepage changes the tmpfs-file identity of the page to swap
 > identity: so if it's unmapped later, the instances would then become
 > private (to be COWed) instead of shared.

Ah, I see.

 > 
 > If you go the writepage-while-mapped route (more general gotchas?
 > I forget), you'll have to make an exception for shmem_writepage.

May be one can just call try_to_unmap() from shmem_writepage()?

 > 
 > Hugh
 > 

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
