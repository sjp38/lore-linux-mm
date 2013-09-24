Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f41.google.com (mail-oa0-f41.google.com [209.85.219.41])
	by kanga.kvack.org (Postfix) with ESMTP id C10816B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 04:48:32 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id n10so1762948oag.28
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 01:48:32 -0700 (PDT)
From: Weiping Pan <wpan@redhat.com>
Subject: [PATCH resend] typo: replace kernelcore with Movable
Date: Tue, 24 Sep 2013 16:48:14 +0800
Message-Id: <a1714d6a349ac584626a164631c5e2b74d91326d.1380012101.git.wpan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: rob@landley.net, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Han Pingtian found a typo in Documentation/kernel-parameters.txt
about "kernelcore=", that "kernelcore" should be replaced with "Movable" here.

I sent this patch a 8 months ago and got ack from Mel Gorman,
http://marc.info/?l=linux-mm&m=135756720602638&w=2
but it has not been merged so I resent it again.

Signed-off-by: Weiping Pan <wpan@redhat.com>
---
 Documentation/kernel-parameters.txt |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 1a036cd9..c3ea235 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1357,7 +1357,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			pages. In the event, a node is too small to have both
 			kernelcore and Movable pages, kernelcore pages will
 			take priority and other nodes will have a larger number
-			of kernelcore pages.  The Movable zone is used for the
+			of Movable pages.  The Movable zone is used for the
 			allocation of pages that may be reclaimed or moved
 			by the page migration subsystem.  This means that
 			HugeTLB pages may not be allocated from this zone.
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
