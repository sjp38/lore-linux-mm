Received: from mailgate3.nec.co.jp (mailgate53F.nec.co.jp [10.7.69.162])
	by tyo201.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id m25ChqKQ025837
	for <linux-mm@kvack.org>; Wed, 5 Mar 2008 21:43:52 +0900 (JST)
Received: (from root@localhost) by mailgate3.nec.co.jp (8.11.7/3.7W-MAILGATE-NEC)
	id m25Chqh15347 for linux-mm@kvack.org; Wed, 5 Mar 2008 21:43:52 +0900 (JST)
Received: from yonosuke.jp.nec.com (yonosuke.jp.nec.com [10.26.220.15])
	by mailsv.nec.co.jp (8.13.8/8.13.4) with ESMTP id m25ChpRw014618
	for <linux-mm@kvack.org>; Wed, 5 Mar 2008 21:43:51 +0900 (JST)
Message-Id: <47CE95FC.9070307@ap.jp.nec.com>
Date: Wed, 05 Mar 2008 21:45:48 +0900
From: Itaru Kitayama <i-kitayama@ap.jp.nec.com>
MIME-Version: 1.0
Subject: typo fix in Documentation/vm/slub.txt
Content-Type: multipart/mixed;
 boundary="------------040009090304080404080407"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040009090304080404080407
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit

Change dentry_cache to dentry. If not fixed in upstream, please
apply this patch.
 
-- 
Itaru Kitayama
i-kitayama@ap.jp.nec.com

--------------040009090304080404080407
Content-Type: text/x-patch;
 name="slub.txt.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="slub.txt.patch"

diff --git a/Documentation/vm/slub.txt b/Documentation/vm/slub.txt
index dcf8bcf..7c13f22 100644
--- a/Documentation/vm/slub.txt
+++ b/Documentation/vm/slub.txt
@@ -50,14 +50,14 @@ F.e. in order to boot just with sanity checks and red zoning one would specify:
 
 Trying to find an issue in the dentry cache? Try
 
-	slub_debug=,dentry_cache
+	slub_debug=,dentry
 
 to only enable debugging on the dentry cache.
 
 Red zoning and tracking may realign the slab.  We can just apply sanity checks
 to the dentry cache with
 
-	slub_debug=F,dentry_cache
+	slub_debug=F,dentry
 
 In case you forgot to enable debugging on the kernel command line: It is
 possible to enable debugging manually when the kernel is up. Look at the

--------------040009090304080404080407--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
