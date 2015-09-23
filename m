Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 757556B025E
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 00:48:01 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so29384205pad.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 21:48:01 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id rq8si734458pbc.226.2015.09.22.21.48.00
        for <linux-mm@kvack.org>;
        Tue, 22 Sep 2015 21:48:00 -0700 (PDT)
Subject: [PATCH 06/15] devm_memunmap: use devres_release()
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 23 Sep 2015 00:41:44 -0400
Message-ID: <20150923044144.36490.28268.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

Remove open coded call to memunmap.

Cc: Christoph Hellwig <hch@lst.de>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 72b0c66628b6..0756273437e0 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -131,9 +131,8 @@ EXPORT_SYMBOL(devm_memremap);
 
 void devm_memunmap(struct device *dev, void *addr)
 {
-	WARN_ON(devres_destroy(dev, devm_memremap_release, devm_memremap_match,
-			       addr));
-	memunmap(addr);
+	WARN_ON(devres_release(dev, devm_memremap_release,
+				devm_memremap_match, addr));
 }
 EXPORT_SYMBOL(devm_memunmap);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
