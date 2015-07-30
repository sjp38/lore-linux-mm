Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id 569EF6B025E
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 13:04:31 -0400 (EDT)
Received: by ykdu72 with SMTP id u72so39080225ykd.2
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 10:04:31 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id o142si1264864ywd.173.2015.07.30.10.04.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 10:04:23 -0700 (PDT)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv3 02/10] xen/balloon: remove scratch page left overs
Date: Thu, 30 Jul 2015 18:03:04 +0100
Message-ID: <1438275792-5726-3-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
References: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
Cc: David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org, Konrad
 Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Daniel Kiper <daniel.kiper@oracle.com>

Commit 0bb599fd30108883b00c7d4a226eeb49111e6932 (xen: remove scratch
frames for ballooned pages and m2p override) removed the use of the
scratch page for ballooned out pages.

Remove some left over function definitions.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
Reviewed-by: Daniel Kiper <daniel.kiper@oracle.com>
---
 include/xen/balloon.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/include/xen/balloon.h b/include/xen/balloon.h
index a4c1c6a..cc2e1a7 100644
--- a/include/xen/balloon.h
+++ b/include/xen/balloon.h
@@ -29,9 +29,6 @@ int alloc_xenballooned_pages(int nr_pages, struct page **pages,
 		bool highmem);
 void free_xenballooned_pages(int nr_pages, struct page **pages);
 
-struct page *get_balloon_scratch_page(void);
-void put_balloon_scratch_page(void);
-
 struct device;
 #ifdef CONFIG_XEN_SELFBALLOONING
 extern int register_xen_selfballooning(struct device *dev);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
