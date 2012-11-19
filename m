Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id DDA7F6B0071
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 00:30:20 -0500 (EST)
From: Josh Triplett <josh@joshtriplett.org>
Subject: [PATCH 26/58] mm/internal.h: Declare vma_address unconditionally
Date: Sun, 18 Nov 2012 21:28:05 -0800
Message-Id: <1353302917-13995-27-git-send-email-josh@joshtriplett.org>
In-Reply-To: <1353302917-13995-1-git-send-email-josh@joshtriplett.org>
References: <1353302917-13995-1-git-send-email-josh@joshtriplett.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Josh Triplett <josh@joshtriplett.org>

mm/internal.h declares vma_address inside an ifdef
CONFIG_TRANSPARENT_HUGEPAGE; however, mm/rmap.c defines the function
unconditionally.  Move the function outside of the ifdef.

This eliminates a warning from gcc (-Wmissing-prototypes) and from
Sparse (-Wdecl).

mm/rmap.c:527:1: warning: no previous prototype for =E2=80=98vma_address=E2=
=80=99 [-Wmissing-prototypes]

Signed-off-by: Josh Triplett <josh@joshtriplett.org>
---
 mm/internal.h |    2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index a4fa284..6cd14dc 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -221,10 +221,8 @@ static inline void mlock_migrate_page(struct page *n=
ewpage, struct page *page)
 	}
 }
=20
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 extern unsigned long vma_address(struct page *page,
 				 struct vm_area_struct *vma);
-#endif
 #else /* !CONFIG_MMU */
 static inline int mlocked_vma_newpage(struct vm_area_struct *v, struct p=
age *p)
 {
--=20
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
