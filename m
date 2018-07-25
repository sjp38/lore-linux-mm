Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9FB746B0003
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 18:38:36 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id c2-v6so1068572plz.17
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 15:38:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z4-v6sor4409742pff.50.2018.07.25.15.38.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Jul 2018 15:38:35 -0700 (PDT)
Date: Wed, 25 Jul 2018 15:38:32 -0700
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] mm: Clarify CONFIG_PAGE_POISONING and usage
Message-ID: <20180725223832.GA43733@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The Kconfig text for CONFIG_PAGE_POISONING doesn't mention that it has to
be enabled explicitly. This updates the documentation for that and adds
a note about CONFIG_PAGE_POISONING to the "page_poison" command line docs.
While here, change description of CONFIG_PAGE_POISONING_ZERO too, as it's
not "random" data, but rather the fixed debugging value that would be used
when not zeroing. Additionally removes a stray "bool" in the Kconfig.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 Documentation/admin-guide/kernel-parameters.txt | 5 +++--
 mm/Kconfig.debug                                | 6 +++---
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 533ff5c68970..f8a81b929089 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -2933,8 +2933,9 @@
 			on: enable the feature
 
 	page_poison=	[KNL] Boot-time parameter changing the state of
-			poisoning on the buddy allocator.
-			off: turn off poisoning
+			poisoning on the buddy allocator, available with
+			CONFIG_PAGE_POISONING=y.
+			off: turn off poisoning (default)
 			on: turn on poisoning
 
 	panic=		[KNL] Kernel behaviour on panic: delay <timeout>
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index e5e606ee5f71..9a7b8b049d04 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -46,7 +46,8 @@ config PAGE_POISONING
 	  Fill the pages with poison patterns after free_pages() and verify
 	  the patterns before alloc_pages. The filling of the memory helps
 	  reduce the risk of information leaks from freed data. This does
-	  have a potential performance impact.
+	  have a potential performance impact if enabled with the
+	  "page_poison=1" kernel boot option.
 
 	  Note that "poison" here is not the same thing as the "HWPoison"
 	  for CONFIG_MEMORY_FAILURE. This is software poisoning only.
@@ -65,7 +66,7 @@ config PAGE_POISONING_NO_SANITY
 	   say N.
 
 config PAGE_POISONING_ZERO
-	bool "Use zero for poisoning instead of random data"
+	bool "Use zero for poisoning instead of debugging value"
 	depends on PAGE_POISONING
 	---help---
 	   Instead of using the existing poison value, fill the pages with
@@ -75,7 +76,6 @@ config PAGE_POISONING_ZERO
 	   allocation.
 
 	   If unsure, say N
-	bool
 
 config DEBUG_PAGE_REF
 	bool "Enable tracepoint to track down page reference manipulation"
-- 
2.17.1


-- 
Kees Cook
Pixel Security
