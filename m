Received: by ey-out-1920.google.com with SMTP id 21so1137603eyc.44
        for <linux-mm@kvack.org>; Mon, 24 Nov 2008 12:05:31 -0800 (PST)
Message-ID: <154e089b0811241205m293b5824of0fa753c1f8c33a6@mail.gmail.com>
Date: Mon, 24 Nov 2008 21:05:31 +0100
From: "Hannes Eder" <hannes@hanneseder.net>
Subject: [PATCH] hugetlb: fix sparse warnings
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Fix the following sparse warnings:

  mm/hugetlb.c:375:3: warning: returning void-valued expression
  mm/hugetlb.c:408:3: warning: returning void-valued expression

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 mm/hugetlb.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6058b53..56e1406 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -371,8 +371,10 @@ static void clear_huge_page(struct page *page,
 {
 	int i;

-	if (unlikely(sz > MAX_ORDER_NR_PAGES))
-		return clear_gigantic_page(page, addr, sz);
+	if (unlikely(sz > MAX_ORDER_NR_PAGES)) {
+		clear_gigantic_page(page, addr, sz);
+		return;
+	}

 	might_sleep();
 	for (i = 0; i < sz/PAGE_SIZE; i++) {
@@ -404,8 +406,10 @@ static void copy_huge_page(struct page *dst,
struct page *src,
 	int i;
 	struct hstate *h = hstate_vma(vma);

-	if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES))
-		return copy_gigantic_page(dst, src, addr, vma);
+	if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES)) {
+		copy_gigantic_page(dst, src, addr, vma);
+		return;
+	}

 	might_sleep();
 	for (i = 0; i < pages_per_huge_page(h); i++) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
