From: Nick Andrew <nick@nick-andrew.net>
Subject: [PATCH] Fix incorrect use of loose in migrate.c
Date: Fri, 05 Dec 2008 14:08:07 +1100
Message-ID: <20081205030807.32309.69191.stgit@marcab.local.tull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Nick Andrew <nick@nick-andrew.net>
List-ID: <linux-mm.kvack.org>

Fix incorrect use of loose in migrate.c

It should be 'lose', not 'loose'.

Signed-off-by: Nick Andrew <nick@nick-andrew.net>
---

 mm/migrate.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/mm/migrate.c b/mm/migrate.c
index 1e0d6b2..7605b2b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -514,7 +514,7 @@ static int writeout(struct address_space *mapping, struct page *page)
 	/*
 	 * A dirty page may imply that the underlying filesystem has
 	 * the page on some queue. So the page must be clean for
-	 * migration. Writeout may mean we loose the lock and the
+	 * migration. Writeout may mean we lose the lock and the
 	 * page state is no longer what we checked for earlier.
 	 * At this point we know that the migration attempt cannot
 	 * be successful.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
