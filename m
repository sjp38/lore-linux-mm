Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 660BE6B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 23:29:14 -0500 (EST)
From: Weiping Pan <wpan@redhat.com>
Subject: [PATCH] typo: replace kernelcore with Movable
Date: Sat,  5 Jan 2013 12:29:17 +0800
Message-Id: <5aed74b1520f495521fe97b99b714cfe7572faa1.1357359930.git.wpan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mgorman@suse.de, wpan@redhat.com

Han Pingtian found a typo in Documentation/kernel-parameters.txt
about "kernelcore=", that "kernelcore" should be replaced with "Movable" here.

Signed-off-by: Weiping Pan <wpan@redhat.com>
---
 Documentation/kernel-parameters.txt |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 363e348..95fcc5b 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1227,7 +1227,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			pages. In the event, a node is too small to have both
 			kernelcore and Movable pages, kernelcore pages will
 			take priority and other nodes will have a larger number
-			of kernelcore pages.  The Movable zone is used for the
+			of Movable pages.  The Movable zone is used for the
 			allocation of pages that may be reclaimed or moved
 			by the page migration subsystem.  This means that
 			HugeTLB pages may not be allocated from this zone.
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
