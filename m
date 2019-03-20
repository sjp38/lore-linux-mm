Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 194BDC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:36:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC5812186A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:36:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC5812186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F97C6B0007; Wed, 20 Mar 2019 03:36:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A88B6B0008; Wed, 20 Mar 2019 03:36:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 598C96B000A; Wed, 20 Mar 2019 03:36:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3A2476B0007
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:36:07 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id 23so20021087qkl.16
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 00:36:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=NHYm78XeumLt8ir9csQDBL74SYZAX+2NrnzQ7Es7qeA=;
        b=RF0DUwHMZl+eaU1AE9c1ouzIPJh1lZjZcvALiTvUmHmu44uZkxcXtMkdVnIDHl9FsP
         dSdmkcSA7bBjSQ1E9VN2yhIo+ta1DN1+xErqMZpJeXQPTxBHq6yeI5d6DEPoLfLOfnHq
         4vn4OOsdL/rLqMz+8o/tsQjmcmL1IKzoEoA22uiCpskiLrkk9Oqlul0fsmkew5qax8nd
         WSslZEWrtYADNIdqCqvpr8w9A6nVndS8KTOmF5eT07db1RtOtPHMbOWKzKcTBq91SL28
         dBm5fh+pHVrZai4ItyND7pOCwUfZ1l5+Ayhz3p3/xNpOG8EYtpNLuJsa4FT0N6m1Wbdl
         vKhg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVEhlUfasyhpot/+CPKFZ/caO9SH7mKOQoc/eoG4Ru00o/MRP5O
	pZEWvlcQlqXz1P6SIaal0IRB+ShOcAM9vFio0wkSbTIBl1f71sSg4ODRlXgm8WhTrlAHHouk0LC
	wzHi/7ta5ah6IsFEcZ4PvSwsCnPM7S8uKvSd0RleuQDGpzAeTdrW0On9F4mxMmWi9RQ==
X-Received: by 2002:ac8:201:: with SMTP id k1mr5738828qtg.184.1553067367011;
        Wed, 20 Mar 2019 00:36:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTKu1vefQDB4q15xIW3cZJDASAG6h6QGgbvLKCtqM8XcrrqO52EKnLWE2DNKFQKDkdk0Vi
X-Received: by 2002:ac8:201:: with SMTP id k1mr5738803qtg.184.1553067366299;
        Wed, 20 Mar 2019 00:36:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553067366; cv=none;
        d=google.com; s=arc-20160816;
        b=rVxCfJUWbWIztOo3tMnrZ+2d3D8oAfzGoYqd5G8uWwTQpSskvMJrH16zrJtCDvop2n
         c6PCKEyj3n/57yg4ls/lgl+hre/iLPnNpy55I3N+vH7fVCosURWvzfocotXQW4+z0LaT
         SfnyK/wkFT5vE/pO9I+4a7NNQ4vNFG8qVb2baNz+vf8l9HQDM2PbgkeIdZ36+IhOI3fQ
         dwrRKVA2FYxGYgOm1sqM3ofpULJ7/gJhi3gnrvGGu8hubUz5dVhJU8ipIotAsThPc9p5
         Or1R+OAXsx5aS+ZLEkSaVVgbSoq022mxkp+CgZpSecYjxufL8Jfylr7so0V8KXjyan/R
         jo+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=NHYm78XeumLt8ir9csQDBL74SYZAX+2NrnzQ7Es7qeA=;
        b=xugeIA1xoconHtJB9xINNPayezwOYJRjolL6vJQSCHA4NJJFc8FPLmT9HaApeLKd4w
         gN0t0gTANyEoMhQFq9dSSoH4DhlN3gUKMVd/pi6TUavWUtFeEY3klCP18bAs5if+PHah
         7tchxiLjckTiBNFxbM0gPO9jzmGIhB5xTg252YZzZOURFpRYKbwibQCmRPY3Y4Tfv7Rk
         l2RtIg8MrSpcef4yj9WQJflAAPMN26fEjpzEQ3MRJJsdXBQCNmzVMbUXrZMLfReUwwlG
         5+8q/cQL8soR79TRunD8igojyKN+dfRr1Rn/dycVaMlcti0v7+2lu49S5gNFQSPYRlS6
         x9VQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t3si684642qkc.248.2019.03.20.00.36.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 00:36:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 824A5307D981;
	Wed, 20 Mar 2019 07:36:05 +0000 (UTC)
Received: from MiWiFi-R3L-srv.redhat.com (ovpn-12-38.pek2.redhat.com [10.72.12.38])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8178F60BF3;
	Wed, 20 Mar 2019 07:36:00 +0000 (UTC)
From: Baoquan He <bhe@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org,
	pasha.tatashin@oracle.com,
	mhocko@suse.com,
	rppt@linux.vnet.ibm.com,
	richard.weiyang@gmail.com,
	linux-mm@kvack.org,
	Baoquan He <bhe@redhat.com>
Subject: [PATCH 3/3] mm/sparse: Rename function related to section memmap allocation/free
Date: Wed, 20 Mar 2019 15:35:40 +0800
Message-Id: <20190320073540.12866-3-bhe@redhat.com>
In-Reply-To: <20190320073540.12866-1-bhe@redhat.com>
References: <20190320073540.12866-1-bhe@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Wed, 20 Mar 2019 07:36:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

These functions are used allocate/free section memmap, have nothing
to do with kmalloc/free during the handling. Rename them to remove
the confusion.

Signed-off-by: Baoquan He <bhe@redhat.com>
---
 mm/sparse.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 054b99f74181..374206212d01 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -579,13 +579,13 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 #endif
 
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
-static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
+static inline struct page *alloc_section_memmap(unsigned long pnum, int nid,
 		struct vmem_altmap *altmap)
 {
 	/* This will make the necessary allocations eventually. */
 	return sparse_mem_map_populate(pnum, nid, altmap);
 }
-static void __kfree_section_memmap(struct page *memmap,
+static void __free_section_memmap(struct page *memmap,
 		struct vmem_altmap *altmap)
 {
 	unsigned long start = (unsigned long)memmap;
@@ -603,7 +603,7 @@ static void free_map_bootmem(struct page *memmap)
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #else
-static struct page *__kmalloc_section_memmap(void)
+static struct page *__alloc_section_memmap(void)
 {
 	struct page *page, *ret;
 	unsigned long memmap_size = sizeof(struct page) * PAGES_PER_SECTION;
@@ -624,13 +624,13 @@ static struct page *__kmalloc_section_memmap(void)
 	return ret;
 }
 
-static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
+static inline struct page *alloc_section_memmap(unsigned long pnum, int nid,
 		struct vmem_altmap *altmap)
 {
-	return __kmalloc_section_memmap();
+	return __alloc_section_memmap();
 }
 
-static void __kfree_section_memmap(struct page *memmap,
+static void __free_section_memmap(struct page *memmap,
 		struct vmem_altmap *altmap)
 {
 	if (is_vmalloc_addr(memmap))
@@ -701,7 +701,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 	usemap = __kmalloc_section_usemap();
 	if (!usemap)
 		return -ENOMEM;
-	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
+	memmap = alloc_section_memmap(section_nr, nid, altmap);
 	if (!memmap) {
 		kfree(usemap);
 		return -ENOMEM;
@@ -726,7 +726,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 out:
 	if (ret < 0) {
 		kfree(usemap);
-		__kfree_section_memmap(memmap, altmap);
+		__free_section_memmap(memmap, altmap);
 	}
 	return ret;
 }
@@ -777,7 +777,7 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap,
 	if (PageSlab(usemap_page) || PageCompound(usemap_page)) {
 		kfree(usemap);
 		if (memmap)
-			__kfree_section_memmap(memmap, altmap);
+			__free_section_memmap(memmap, altmap);
 		return;
 	}
 
-- 
2.17.2

