Return-Path: <owner-linux-mm@kvack.org>
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 1/3] mm: Introduce new page flag
Date: Tue, 13 Aug 2013 16:05:00 +0900
Message-Id: <1376377502-28207-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1376377502-28207-1-git-send-email-minchan@kernel.org>
References: <1376377502-28207-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, k.kozlowski@samsung.com, Seth Jennings <sjenning@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, guz.fnst@cn.fujitsu.com, Benjamin LaHaise <bcrl@kvack.org>, Dave Hansen <dave.hansen@intel.com>, lliubbo@gmail.com, aquini@redhat.com, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/page-flags.h |    2 ++
 mm/page_alloc.c            |    1 +
 2 files changed, 3 insertions(+)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 6d53675..75ce843 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -109,6 +109,7 @@ enum pageflags {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	PG_compound_lock,
 #endif
+	PG_pin,
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -197,6 +198,7 @@ struct page;	/* forward declaration */
 
 TESTPAGEFLAG(Locked, locked)
 PAGEFLAG(Error, error) TESTCLEARFLAG(Error, error)
+PAGEFLAG(Pin, pin) TESTCLEARFLAG(Pin, pin)
 PAGEFLAG(Referenced, referenced) TESTCLEARFLAG(Referenced, referenced)
 PAGEFLAG(Dirty, dirty) TESTSCFLAG(Dirty, dirty) __CLEARPAGEFLAG(Dirty, dirty)
 PAGEFLAG(LRU, lru) __CLEARPAGEFLAG(LRU, lru)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b100255..5dd8b43 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6345,6 +6345,7 @@ static const struct trace_print_flags pageflag_names[] = {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	{1UL << PG_compound_lock,	"compound_lock"	},
 #endif
+	{1UL << PG_pin,			"pin"		},
 };
 
 static void dump_page_flags(unsigned long flags)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
