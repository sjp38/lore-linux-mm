Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8AB49680DD3
	for <linux-mm@kvack.org>; Fri, 25 Dec 2015 17:10:38 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id bx1so85175097obb.0
        for <linux-mm@kvack.org>; Fri, 25 Dec 2015 14:10:38 -0800 (PST)
Received: from g4t3428.houston.hp.com (g4t3428.houston.hp.com. [15.201.208.56])
        by mx.google.com with ESMTPS id lg5si8677429oeb.90.2015.12.25.14.10.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Dec 2015 14:10:38 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v2 15/16] checkpatch: Add warning on deprecated walk_iomem_res
Date: Fri, 25 Dec 2015 15:09:24 -0700
Message-Id: <1451081365-15190-15-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
References: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@canonical.com>, Joe Perches <joe@perches.com>, Toshi Kani <toshi.kani@hpe.com>

Use of walk_iomem_res() is deprecated in new code.  Change
checkpatch.pl to check new use of walk_iomem_res() and suggest
to use walk_iomem_res_desc() instead.

Cc: Andy Whitcroft <apw@canonical.com>
Cc: Joe Perches <joe@perches.com>
Cc: Borislav Petkov <bp@alien8.de>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 scripts/checkpatch.pl |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 2b3c228..07a2dbe 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -3424,6 +3424,12 @@ sub process {
 			}
 		}
 
+# check for uses of walk_iomem_res()
+		if ($line =~ /\bwalk_iomem_res\(/) {
+			WARN("walk_iomem_res",
+			     "Use of walk_iomem_res is deprecated, please use walk_iomem_res_desc instead\n" . $herecurr)
+		}
+
 # check for new typedefs, only function parameters and sparse annotations
 # make sense.
 		if ($line =~ /\btypedef\s/ &&

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
