Date: Mon, 9 Apr 2001 17:01:06 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH] 2.4.4-pre1 sparc/mm typo
In-Reply-To: <Pine.LNX.4.21.0103301457460.1080-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.21.0104091653370.1028-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--- 2.4.4-pre1/arch/sparc/mm/generic.c	Sat Apr  7 08:15:16 2001
+++ linux/arch/sparc/mm/generic.c	Mon Apr  9 16:48:42 2001
@@ -21,7 +21,7 @@
 		struct page *ptpage = pte_page(page);
 		if ((!VALID_PAGE(ptpage)) || PageReserved(ptpage))
 			return;
-		page_cache_release(page);
+		page_cache_release(ptpage);
 		return;
 	}
 	swap_free(pte_to_swp_entry(page));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
