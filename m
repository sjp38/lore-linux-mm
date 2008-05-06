Message-ID: <482029E7.6070308@cn.fujitsu.com>
Date: Tue, 06 May 2008 17:50:31 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/page_alloc.c: fix a typo
References: <4820272C.4060009@cn.fujitsu.com> <482027E4.6030300@cn.fujitsu.com>
In-Reply-To: <482027E4.6030300@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: clameter@sgi.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Li Zefan wrote:
> ---

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---

Sorry for the noise, but the signed-off was eaten. :(
Maybe I should leave a blank line before the signed-off.

---

 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bdd5c43..d0ba10d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -303,7 +303,7 @@ static void destroy_compound_page(struct page *page, unsigned long order)
 	for (i = 1; i < nr_pages; i++) {
 		struct page *p = page + i;
 
-		if (unlikely(!PageTail(p) |
+		if (unlikely(!PageTail(p) ||
 				(p->first_page != page)))
 			bad_page(page);
 		__ClearPageTail(p);
-- 1.5.4.rc3 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
