Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C867C32755
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6FD72080C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gkgYcjKv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6FD72080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CC6A6B026B; Thu,  1 Aug 2019 22:20:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED46E6B026C; Thu,  1 Aug 2019 22:20:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFF796B026D; Thu,  1 Aug 2019 22:20:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6C86B026B
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:28 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 6so47130173pfi.6
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Qd17+I20JNTl38JpPt9ENs79+ajS7TX5o2e3ywFXns4=;
        b=EZ75VMTYGMZZbNCNEAaV1e46YbHY0ppgCRxa/ZvQdkls8KtdS/jBB4N30fb4EQ+60l
         qYTGPbKC9zEVmAadwizR/fSeG06l8bpvL6sKf/UKbM11mPpK6t6w3b9i8B12arRw9r91
         kEEzfO2tz6vVceJLUCZ1jUtyyzChT/x6vOV9qgMKM5JLDlByp2oEjgGkMK8Vv5Vjn24+
         vVVVV2KcOfz6hkuZAj2HOWeJmi50qsTw9z1dsM11o4yyA5TYNm/ZorbvkFdMhCM7zv0w
         FZcwQHiWS6x6vZ3rTSpoRXNsI/AsDZFGkXFDCr5+JT4Otc2SCqdlPNsZn3GZkYBhK74s
         GY1g==
X-Gm-Message-State: APjAAAWq6uvXAmurqghU+KT9dIRpGVUO9rj41cHJYL8yvcnWLiEWF8pp
	W7i+ucB94/Pk8e3959vgN8AAtWcvMsbl6ylOFHtVOCyfaLj6OsUt90aPmdpksYEf7nn8fXAbd1t
	d4gpI2bP7jMY3lwaFW1QGxsqV+OGjtCjSNUXTUTsMht9S33U+5zO8AMdU3bswc8qBhA==
X-Received: by 2002:a63:c1c:: with SMTP id b28mr89876845pgl.354.1564712428187;
        Thu, 01 Aug 2019 19:20:28 -0700 (PDT)
X-Received: by 2002:a63:c1c:: with SMTP id b28mr89876819pgl.354.1564712427498;
        Thu, 01 Aug 2019 19:20:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712427; cv=none;
        d=google.com; s=arc-20160816;
        b=coGJPUDQcg7DDK+BwLs2RuA1HBndEA8mkjcaVezdAmczbxR2PnD/VSbATJs97uL3WH
         Ay5ptdf4eYRzoxzjT7ATrU8kIYhf0qqPd1a6PsO6DCXvPkmohyLu5Oh6dMAx9zXC5rF/
         r3lXqLjmkv9anypZyQIxiB7Wm4W2Q+gppy6NpRvqUzHRInBDiWCcPDzmyTVNdOwnzb9s
         6HJ/S3E7JvFCnAtfZbWVSXaAL5NPdGPX9yO4sEBvujg/64KWbdw1/HA5i5juWJv1zwDR
         CxM86Mh3ADgE6F3uu8M6K7BO+Xs7LRsQwg5dr7qkEmTKM1YNcre0J4/fFwY2VzOmPa/7
         gowQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Qd17+I20JNTl38JpPt9ENs79+ajS7TX5o2e3ywFXns4=;
        b=VCMLXQhE97I29aCvWFh2JGVFhuvi0DPChs0XCGPqfWILk5SQNDCGba3Y6b58OiXnYW
         7VOWSnTU43OxMok6Isod0gzCdJAKeFmCYTI/HW3IOWV15Opn6Wx0eGYPB5/ZtKZPII7s
         yvKNwGI3WmAkbYxPRCkYQiiCnp9FSHpPO04fAS75p09sSQo8W0aUKQHIGoDvOrt2CvFl
         n4HAq9CNlOPnhgRePB922JaoEoHZPS610Q7HqZuswPEwYsUUSgkGfpLQocGeAPswxRis
         jlENTV6GUgD+IO7liseI7lSW71mhDPfDROd9gtkvAD/RCHKtPNZMYcUDgX351AHvOXzk
         y59Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gkgYcjKv;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 31sor49670699pgy.17.2019.08.01.19.20.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gkgYcjKv;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Qd17+I20JNTl38JpPt9ENs79+ajS7TX5o2e3ywFXns4=;
        b=gkgYcjKv8mviCpscfvidKdy0yp2exmwhbdFHg1VYLE3YGnNwT45rP9cYRgwxWvdSGD
         XzCmVpBd7+RlIjI+MEb+wWJpyo2f4ZmUYQSjUgDqWwLqeKRJRBA6AZnXsK08IyCyXhiy
         4dNgArxki6iOU/cWoHR8rdD6eQRfJHzRIm1i/ZNo3u5RbTwbDPqtUA6ksm0/Lv2IxLjK
         q70kCAhSPRAGOQENe2IrIBNCWn54pipkVfZgN+QCwPKsZgDTTDuP78ZHv5mKxve9ym1t
         pLsjPHA1rQycUPxkIzWtiiwiI/XQHl1n8MJ/ZwIZ8xTcRU1Mrrugy/JGwgBrkRXuy135
         NXOg==
X-Google-Smtp-Source: APXvYqzcfAPxLmmHN9CIJXSofnjYAmirbplKZ2y79i+8ei53QCOaijMzmdrNExYuUwo7YKHbzyVulQ==
X-Received: by 2002:a63:4e60:: with SMTP id o32mr124066909pgl.68.1564712427200;
        Thu, 01 Aug 2019 19:20:27 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.25
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:26 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	devel@lists.orangefs.org,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org,
	rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>,
	Frank Haverkamp <haver@linux.vnet.ibm.com>,
	"Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 10/34] genwqe: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:41 -0700
Message-Id: <20190802022005.5117-11-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190802022005.5117-1-jhubbard@nvidia.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

This changes the release code slightly, because each page slot in the
page_list[] array is no longer checked for NULL. However, that check
was wrong anyway, because the get_user_pages() pattern of usage here
never allowed for NULL entries within a range of pinned pages.

Cc: Frank Haverkamp <haver@linux.vnet.ibm.com>
Cc: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/misc/genwqe/card_utils.c | 17 +++--------------
 1 file changed, 3 insertions(+), 14 deletions(-)

diff --git a/drivers/misc/genwqe/card_utils.c b/drivers/misc/genwqe/card_utils.c
index 2e1c4d2905e8..2a888f31d2c5 100644
--- a/drivers/misc/genwqe/card_utils.c
+++ b/drivers/misc/genwqe/card_utils.c
@@ -517,24 +517,13 @@ int genwqe_free_sync_sgl(struct genwqe_dev *cd, struct genwqe_sgl *sgl)
 /**
  * genwqe_free_user_pages() - Give pinned pages back
  *
- * Documentation of get_user_pages is in mm/gup.c:
- *
- * If the page is written to, set_page_dirty (or set_page_dirty_lock,
- * as appropriate) must be called after the page is finished with, and
- * before put_page is called.
+ * The pages may have been written to, so we call put_user_pages_dirty_lock(),
+ * rather than put_user_pages().
  */
 static int genwqe_free_user_pages(struct page **page_list,
 			unsigned int nr_pages, int dirty)
 {
-	unsigned int i;
-
-	for (i = 0; i < nr_pages; i++) {
-		if (page_list[i] != NULL) {
-			if (dirty)
-				set_page_dirty_lock(page_list[i]);
-			put_page(page_list[i]);
-		}
-	}
+	put_user_pages_dirty_lock(page_list, nr_pages, dirty);
 	return 0;
 }
 
-- 
2.22.0

