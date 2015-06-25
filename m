Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8216A6B006C
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 13:11:17 -0400 (EDT)
Received: by ykdt186 with SMTP id t186so43951105ykd.0
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 10:11:17 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id r4si11761763yhg.164.2015.06.25.10.11.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Jun 2015 10:11:16 -0700 (PDT)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1 2/8] xen/balloon: remove scratch page left overs
Date: Thu, 25 Jun 2015 18:10:57 +0100
Message-ID: <1435252263-31952-3-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
References: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xenproject.org
Cc: David Vrabel <david.vrabel@citrix.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Kiper <daniel.kiper@oracle.com>

Commit 0bb599fd30108883b00c7d4a226eeb49111e6932 (xen: remove scratch
frames for ballooned pages and m2p override) removed the use of the
scratch page for ballooned out pages.

Remove some left over function definitions.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 include/xen/balloon.h |    3 ---
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
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
