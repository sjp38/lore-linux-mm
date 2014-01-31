Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 449FE6B0037
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 19:35:41 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id k19so8362648igc.4
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 16:35:41 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id z11si37810530igj.8.2014.01.30.16.35.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jan 2014 16:35:39 -0800 (PST)
Message-ID: <52EAEFD8.6030003@infradead.org>
Date: Thu, 30 Jan 2014 16:35:36 -0800
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: [PATCH] Documentation: fix memmap= language in kernel-parameters.txt
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andiry Xu <andiry.xu@gmail.com>, Rob Landley <rob@landley.net>

From: Randy Dunlap <rdunlap@infradead.org>

Clean up descriptions of memmap= boot options.

Add periods (full stops), drop commas, change "used" to
"reserved" or "marked".

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Andiry Xu <andiry.xu@gmail.com>
Cc: David Rientjes <rientjes@google.com>
---
 Documentation/kernel-parameters.txt |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

--- lnx-313.orig/Documentation/kernel-parameters.txt
+++ lnx-313/Documentation/kernel-parameters.txt
@@ -1668,16 +1668,16 @@ bytes respectively. Such letter suffixes
 			option description.
 
 	memmap=nn[KMG]@ss[KMG]
-			[KNL] Force usage of a specific region of memory
-			Region of memory to be used, from ss to ss+nn.
+			[KNL] Force usage of a specific region of memory.
+			Region of memory to be used is from ss to ss+nn.
 
 	memmap=nn[KMG]#ss[KMG]
 			[KNL,ACPI] Mark specific memory as ACPI data.
-			Region of memory to be used, from ss to ss+nn.
+			Region of memory to be marked is from ss to ss+nn.
 
 	memmap=nn[KMG]$ss[KMG]
 			[KNL,ACPI] Mark specific memory as reserved.
-			Region of memory to be used, from ss to ss+nn.
+			Region of memory to be reserved is from ss to ss+nn.
 			Example: Exclude memory from 0x18690000-0x1869ffff
 			         memmap=64K$0x18690000
 			         or

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
