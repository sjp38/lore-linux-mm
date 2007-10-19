Date: Fri, 19 Oct 2007 04:20:44 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: Avoid atomic operation for slab_unlock
In-Reply-To: <200710190949.01019.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0710190420180.29352@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0710181514310.3584@schroedinger.engr.sgi.com>
 <200710190949.01019.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Slub can use the non-atomic version to unlock because other flags will not
get modified with the lock held.

Signed-off-by: Nick Piggin <npiggin@suse.de>

---
 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c
+++ linux-2.6/mm/slub.c
@@ -1185,7 +1185,7 @@ static __always_inline void slab_lock(st
 
 static __always_inline void slab_unlock(struct page *page)
 {
-	bit_spin_unlock(PG_locked, &page->flags);
+	__bit_spin_unlock(PG_locked, &page->flags);
 }
 
 static __always_inline int slab_trylock(struct page *page)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
