Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88520C04AAB
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 18:38:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F91420675
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 18:38:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F91420675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEF556B0003; Tue,  7 May 2019 14:38:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9F726B0006; Tue,  7 May 2019 14:38:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98D4A6B0007; Tue,  7 May 2019 14:38:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 756456B0003
	for <linux-mm@kvack.org>; Tue,  7 May 2019 14:38:25 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id n39so20309907qtn.0
        for <linux-mm@kvack.org>; Tue, 07 May 2019 11:38:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=X3Se80q1dKdim+vPqx/FPGIOapUfHtVIBKJDjYe8V8k=;
        b=CjinF/w3oTEj1XHUUxl+s+vuw8d/lE+ezDsJCNr9RN24fgHlX6mrZW1p3kC7gchl+L
         xpzfpqirgVE1vTM7ukZxEz+iuic18JMpdodnXOxvMSlLtUQjz9mqx0kjdOuluinP05XQ
         KgoACxZ8qKAijpVCJ2ablAbwiM+mbib9ikhgDmDNgUfJg0Zbd44IO5yanu8ICuY5HY5G
         y7c02T3Tu2ifkfss43PKA9WT1MthChvgf7ADl5QGYvj6oZD5vIiAeibdexqjFew0l14E
         g52EIKl/B/wrVnTVpefZze2j/qCbEChpG6AWWS11Aja2tacFs3L1yPyp22IPT44gb2ky
         XgSA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWUHzOukG5b/3SkgF3mBV9uWxBJZ7BPanEGM2E5EznVvX5UUUF4
	kq5teNX6NG0Fr6bc/H/INT0TqnwgBMQRnTHZwQadKXfop3MPFgzU30dfykCPaBLZzl6dSWQe/aj
	jsQd419U4Yjusjf0wZ2OHwL485IeG2JA8cFFXmhrfsDbkh0oY+BmKL0TFrvzBtY5NMA==
X-Received: by 2002:a37:b683:: with SMTP id g125mr313310qkf.249.1557254305147;
        Tue, 07 May 2019 11:38:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAqBFuiWFJNfQxchoxM9forM1wuUPL7XTMzAk2Rt7GoxISFJKRXsTELwToYEw+BwZiy4fY
X-Received: by 2002:a37:b683:: with SMTP id g125mr313261qkf.249.1557254304209;
        Tue, 07 May 2019 11:38:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557254304; cv=none;
        d=google.com; s=arc-20160816;
        b=zul8zOF/K9Se66ufyZurVlflSOlPbuyiY+U+2Ajbg2lITxE++97fp9LV99Jk+UGoIU
         n/VpWbAfgke8kk/PmSPDwLUtXdiyzi/Xy73SD/ncqLGAIete1rgZk8Ymsob8vclcM0va
         Se0HBNWDYxTFVq8hVxyOERrJBjfwJnJBmoLXiiXnIIjKA6z3Cb8uNmYfO/gKx1L0HY/l
         TLhwFg5CofEzFb8ECg6fyVyUDGvUyZrebICOH6m/y7tYH9GDJRjnZPrp1/sIXMMf4WW+
         LFpCDE6MuP9c0J2m6KillILGhYh8LeYOGx3HUrONxFe6m0yxbZuH/oEw6lzsiX1DuDoC
         p2Nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=X3Se80q1dKdim+vPqx/FPGIOapUfHtVIBKJDjYe8V8k=;
        b=D/g3Nwix/N7DwSZyl3x7ExzILOWnZrGI1Zao4oAwXLyJtH+ODselZ14/D2Y8PgKoxk
         gmh8O9IZE0qeBdJsG3NYVKeargJadDC26sx/z+iNw6JOM7kkHegh3XjkJlzYCtGFZgNE
         9+rFD18XC605nMJrj84MXX/mAhgSooccx3eto+V4Hgo1jE/9L+6kNXT9UFjbfEtnKfVr
         o8+6Y044KGnNQ7yupW6mhXLA2XAhoyFfKuE2Fb/fdWDpjiVrQlAbYlwMZd8BqJFmeIGC
         r2cq67MbMqKwO2il4U225Zivw3QpA+8l2SAbqxLC4pXtstvi4zXhL+zfCpUR4ECKsEWC
         pzhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f67si5841625qkj.72.2019.05.07.11.38.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 11:38:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5F73F83F3C;
	Tue,  7 May 2019 18:38:23 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-95.ams2.redhat.com [10.36.116.95])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5B9301778E;
	Tue,  7 May 2019 18:38:20 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	David Hildenbrand <david@redhat.com>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Qian Cai <cai@lca.pw>,
	Wei Yang <richard.weiyang@gmail.com>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: [PATCH v2 1/8] mm/memory_hotplug: Simplify and fix check_hotplug_memory_range()
Date: Tue,  7 May 2019 20:37:57 +0200
Message-Id: <20190507183804.5512-2-david@redhat.com>
In-Reply-To: <20190507183804.5512-1-david@redhat.com>
References: <20190507183804.5512-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 07 May 2019 18:38:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

By converting start and size to page granularity, we actually ignore
unaligned parts within a page instead of properly bailing out with an
error.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Mathieu Malaterre <malat@debian.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 328878b6799d..202febe88b58 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1050,16 +1050,11 @@ int try_online_node(int nid)
 
 static int check_hotplug_memory_range(u64 start, u64 size)
 {
-	unsigned long block_sz = memory_block_size_bytes();
-	u64 block_nr_pages = block_sz >> PAGE_SHIFT;
-	u64 nr_pages = size >> PAGE_SHIFT;
-	u64 start_pfn = PFN_DOWN(start);
-
 	/* memory range must be block size aligned */
-	if (!nr_pages || !IS_ALIGNED(start_pfn, block_nr_pages) ||
-	    !IS_ALIGNED(nr_pages, block_nr_pages)) {
+	if (!size || !IS_ALIGNED(start, memory_block_size_bytes()) ||
+	    !IS_ALIGNED(size, memory_block_size_bytes())) {
 		pr_err("Block size [%#lx] unaligned hotplug range: start %#llx, size %#llx",
-		       block_sz, start, size);
+		       memory_block_size_bytes(), start, size);
 		return -EINVAL;
 	}
 
-- 
2.20.1

