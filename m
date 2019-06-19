Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D12D3C43613
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 22:33:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8747021744
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 22:33:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AykkqRY/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8747021744
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B7F86B0006; Wed, 19 Jun 2019 18:33:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 141928E0002; Wed, 19 Jun 2019 18:33:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 055CD8E0001; Wed, 19 Jun 2019 18:33:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id DB1036B0006
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 18:33:12 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id f22so1480545ioj.9
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 15:33:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=NZX9ozjZ+h++nQ9qTzVYYR055FmQZfSwp2MFV40l/Yg=;
        b=MK9pJpUc3Mif53aI4mf8fHFlkjLt0iC9hI650DYcUan/9iHSdrZO4yYy0ubksIleuO
         QOgfrKYGsGX9ZgkC7dwdj3eKkgKcTTi97sY/5K6b1YJOZGrtoYurGFr6aNALvcHt9pZL
         thL0IY93iRBHIQe7bTmdh/09iAyfN6aGiORsj/+YUcCSoCSCXT8NL+POcu+K7XJfwWW7
         2l/Z2YJrvvVq7v534ottgLsVuScHSJNilHsqaeFyMwJ6te/OZDu89BYj/6bW50oES13H
         Xue2D6MueF3BC8xh8FEUh+M95T2z+e0hMjXZjTQiHeUyVVGlxHJRWTVezmOHOAmF3Y6u
         zStw==
X-Gm-Message-State: APjAAAWyt5b+J5Mu5m4xIL10ZNvDoteuph8AjWNrYAC7vqoAn/W+SJ2k
	K63ue9MWL3t2VlWsCzbpX0/gudMZqlMxn6SnvCrNFJw7wkvijmDzmbs44G3QH/DlkU7/3tNhUbg
	PX89SSI4aBOnwKhglwjRtOq5V8MS/ihWp580MEkCU80PYk1uk56fpZKY0meIcoeIDjw==
X-Received: by 2002:a02:70d6:: with SMTP id f205mr2780686jac.138.1560983592624;
        Wed, 19 Jun 2019 15:33:12 -0700 (PDT)
X-Received: by 2002:a02:70d6:: with SMTP id f205mr2780641jac.138.1560983591982;
        Wed, 19 Jun 2019 15:33:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560983591; cv=none;
        d=google.com; s=arc-20160816;
        b=0O+6bCWiq4IbkEBI3wwHb0mHrjqaDGRnPMzwMlYiJimRbGO+WCQtR8i1ADD5DFrJvC
         UI2fITYvo87kNqWPND8dBgib75g98I0ZeC9DvdY61IiQgqlFANKywBuTbcP6Z0MXD2Du
         ekhZynpiTyeewKCM0rxjbNAYQl7n5Po3BxjatN+OiSzDXMBx6WEaI+t+FIFYLzFYeEAG
         5iL0pMoP3A2dnW8M2uc2u9m3acHrPXob75C5bGgFFXwJkhG9SEO3ywUZFqXXLAZCyMJL
         ovdpjVlTmdtXTEstN5S5hw5F0eCHgeBKWXOqO/Ftab9vVNlauvwrR2MAz9qvx0SbTynt
         htbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=NZX9ozjZ+h++nQ9qTzVYYR055FmQZfSwp2MFV40l/Yg=;
        b=oHXtIjS5qPoD6M0JOJXMakKVLk9jByR1yARbRZ/vij9FHCipD7doA9iJIFNrdT/miY
         zMpyHqjtG7ynnSGkywfUF/4IIo86cDZICsksyO03AeklSPSu3ZLLDtt76weureCo05SH
         62XNh2Fs4NlUnhUb88/2X0KTgbYpS5HkikmJSSLY6k9xOSooeDnpRH+x4BUTpTVqdOak
         MwcvUHaiI9jy3DQn5AOaFS/bfCcZAMXR4cT/mI3ARc2dkKrTV9Fjawqd6yWj86SMZM4b
         rvhVzCTtOUkGhguJxlTBHfGFzdCijKA5uVSZtHD/fxDAzgnFRp/Tr7cBN660Kp7DZt/1
         Pg6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="AykkqRY/";
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f11sor15786256iok.101.2019.06.19.15.33.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 15:33:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="AykkqRY/";
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=NZX9ozjZ+h++nQ9qTzVYYR055FmQZfSwp2MFV40l/Yg=;
        b=AykkqRY/B8jQYskC0hBeay6QNRuqle2AeMVGLRM8LvJGbh2o+2wLfzsOBZFBEUIu9Y
         qCSO6NhEds2PvgNyNoMgHAKvxivTIw9RwSJ2CdlS5Zm4U/SjABUyMfAwNpnYf6X+WqnU
         M7/QbmMXRZZlCzuk9OblJhNYm0tZmX+NxWi693yH6wo7MWpwFAdRKQlJ3U1fwg0m6f0P
         2iROcjzO+q3Rrm3wki11NzixozRES4o5dJ10ciG8N9BtseIWAF4Tn0T3o8HgFZWUpeLy
         Un960tboJzppnKgY/ELquoAi59xkBmskrUyQsnEHENGdgSl3UiTCXoyywpupYHnM0Rdg
         I9Ow==
X-Google-Smtp-Source: APXvYqwRnLuDFzAfR5lMoUpbGfuz69Ko0BWafruD9h5MagTA3O8l8M6s6sqfE+SW8RL4CMOIW1ybvA==
X-Received: by 2002:a02:5489:: with SMTP id t131mr97296596jaa.70.1560983591570;
        Wed, 19 Jun 2019 15:33:11 -0700 (PDT)
Received: from localhost.localdomain (50-126-100-225.drr01.csby.or.frontiernet.net. [50.126.100.225])
        by smtp.gmail.com with ESMTPSA id q13sm17804752ioh.36.2019.06.19.15.33.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 15:33:11 -0700 (PDT)
Subject: [PATCH v1 2/6] mm: Move set/get_pcppage_migratetype to mmzone.h
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Wed, 19 Jun 2019 15:33:09 -0700
Message-ID: <20190619223309.1231.16506.stgit@localhost.localdomain>
In-Reply-To: <20190619222922.1231.27432.stgit@localhost.localdomain>
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

In order to support page aeration it will be necessary to store and
retrieve the migratetype of a page. To enable that I am moving the set and
get operations for pcppage_migratetype into the mmzone header so that they
can be used when adding or removing pages from the free lists.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/mmzone.h |   18 ++++++++++++++++++
 mm/page_alloc.c        |   18 ------------------
 2 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 4c07af2cfc2f..6f8fd5c1a286 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -95,6 +95,24 @@ static inline bool is_migrate_movable(int mt)
 	get_pfnblock_flags_mask(page, page_to_pfn(page),		\
 			PB_migrate_end, MIGRATETYPE_MASK)
 
+/*
+ * A cached value of the page's pageblock's migratetype, used when the page is
+ * put on a pcplist. Used to avoid the pageblock migratetype lookup when
+ * freeing from pcplists in most cases, at the cost of possibly becoming stale.
+ * Also the migratetype set in the page does not necessarily match the pcplist
+ * index, e.g. page might have MIGRATE_CMA set but be on a pcplist with any
+ * other index - this ensures that it will be put on the correct CMA freelist.
+ */
+static inline int get_pcppage_migratetype(struct page *page)
+{
+	return page->index;
+}
+
+static inline void set_pcppage_migratetype(struct page *page, int migratetype)
+{
+	page->index = migratetype;
+}
+
 struct free_area {
 	struct list_head	free_list[MIGRATE_TYPES];
 	unsigned long		nr_free;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ec344ce46587..3e21e01f6165 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -136,24 +136,6 @@ struct pcpu_drain {
 int percpu_pagelist_fraction;
 gfp_t gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;
 
-/*
- * A cached value of the page's pageblock's migratetype, used when the page is
- * put on a pcplist. Used to avoid the pageblock migratetype lookup when
- * freeing from pcplists in most cases, at the cost of possibly becoming stale.
- * Also the migratetype set in the page does not necessarily match the pcplist
- * index, e.g. page might have MIGRATE_CMA set but be on a pcplist with any
- * other index - this ensures that it will be put on the correct CMA freelist.
- */
-static inline int get_pcppage_migratetype(struct page *page)
-{
-	return page->index;
-}
-
-static inline void set_pcppage_migratetype(struct page *page, int migratetype)
-{
-	page->index = migratetype;
-}
-
 #ifdef CONFIG_PM_SLEEP
 /*
  * The following functions are used by the suspend/hibernate code to temporarily

