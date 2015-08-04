From: Wang Xiaoqiang <wangxq10@lzu.edu.cn>
Subject: [PATCH] memory-failure/hwpoison_user_mappings: move the comment
 about swap cache pages' check to proper location
Date: Tue, 4 Aug 2015 20:20:38 +0800
Message-ID: <20150804202038.0ca2777e@hp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

Hi Naoya,

This patch just move the comment about swap cache pages' check to the
proper location in 'hwpoison_user_mappings' function.

Signed-off-by: Wang Xiaoqiang <wangxq10@lzu.edu.cn>
---
 mm/memory-failure.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 1cf7f29..3253abb 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -945,10 +945,6 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	if (!(PageLRU(hpage) || PageHuge(p)))
 		return SWAP_SUCCESS;
 
-	/*
-	 * This check implies we don't kill processes if their pages
-	 * are in the swap cache early. Those are always late kills.
-	 */
 	if (!page_mapped(hpage))
 		return SWAP_SUCCESS;
 
@@ -957,6 +953,10 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 		return SWAP_FAIL;
 	}
 
+	/*
+	 * This check implies we don't kill processes if their pages
+	 * are in the swap cache early. Those are always late kills.
+	 */
 	if (PageSwapCache(p)) {
 		printk(KERN_ERR
 		       "MCE %#lx: keeping poisoned page in swap cache\n", pfn);
-- 
1.7.10.4



--
thx!
Wang Xiaoqiang
