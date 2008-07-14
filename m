Date: Tue, 15 Jul 2008 04:06:53 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm][PATCH 0/9] putback_lru_page() rework v5
Message-Id: <20080715040402.F6EF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


This patch series is rework of putback_lru_page().
These remove strange unlock_page() from putback_lru_page(),
and improve performance slighly by remove unnecessary lock_page().

Unfortunately current mmotm have tons split-lru related patch
and these depend on each other.
Then, the order of the patches appling is a bit messy.
Please be carefully.



How to apply to this patch series
-----------------------------------------
1. unevictable-lru-infrastructure-putback_lru_page-rework.patch 
   applies after unevictable-lru-infrastructure-remove-redundant-page-mapping-check.patch
2. unevictable-lru-infrastructure-kill-unnecessary-lock_page.patch
   applies after 1.
3. unevictable-lru-infrastructure-revert-migration-change.patch
   applies after 2.
4. shm_locked-pages-are-unevictable-revert-shm-change.patch 
   applies after shm_locked-pages-are-unevictable.patch.
5. replace mlock-mlocked-pages-are-unevictable.patch
   to this patch series's one.
6. mlock-mlocked-pages-are-unevictable-resutore-patch-failure-hunk.patch
   applies after 5.
7. mlock-mlocked-pages-are-unevictable-putback_lru_page-rework.patch
   applies after 6.
8. replace vmstat-unevictable-and-mlocked-pages-vm-events.patch
   to this patch series's one.
9. vmstat-unevictable-and-mlocked-pages-vm-events-restore-patch-failure-hunk.patch
   applies after 8.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
