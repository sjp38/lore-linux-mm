Message-Id: <47CF2626.7030408@ap.jp.nec.com>
Date: Thu, 06 Mar 2008 08:00:54 +0900
From: Itaru Kitayama <i-kitayama@ap.jp.nec.com>
MIME-Version: 1.0
Subject: slub: fix typo in Documentation/vm/slub.txt
Content-Type: multipart/mixed;
 boundary="------------030202050000070905000007"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------030202050000070905000007
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit

Hi Christoph,
Could you include this typo fix patch to your slub tree?

slub_debug=,dentry is correct, not dentry_cache.

Signed-off-by: Itaru Kitayama <i-kitayama@ap.jp.nec.com>


--------------030202050000070905000007
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

--------------030202050000070905000007--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
