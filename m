Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 978D86B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 09:10:49 -0500 (EST)
From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial] mm: Fix typo in cleancache.txt
Date: Wed,  8 Feb 2012 23:10:14 +0900
Message-Id: <1328710214-3185-1-git-send-email-standby24x7@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: trivial@kernel.org, linux-kernel@vger.kernel.org, standby24x7@gmail.com

Correct spelling "implementatation" to "implementation" in
Documentation/vm/cleancache.txt

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 Documentation/vm/cleancache.txt |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Documentation/vm/cleancache.txt b/Documentation/vm/cleancache.txt
index f726717..142fbb0 100644
--- a/Documentation/vm/cleancache.txt
+++ b/Documentation/vm/cleancache.txt
@@ -93,7 +93,7 @@ failed_gets	- number of gets that failed
 puts		- number of puts attempted (all "succeed")
 invalidates	- number of invalidates attempted
 
-A backend implementatation may provide additional metrics.
+A backend implementation may provide additional metrics.
 
 FAQ
 
-- 
1.7.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
