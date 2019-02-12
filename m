Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F9D1C282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 17:57:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30F4420869
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 17:57:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lrYOH5Dd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30F4420869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B273B8E0004; Tue, 12 Feb 2019 12:57:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD4EC8E0001; Tue, 12 Feb 2019 12:57:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9EBF68E0004; Tue, 12 Feb 2019 12:57:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 625048E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 12:57:20 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t65so2980938pfj.19
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:57:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gKD32Yoy3OQX5/4gri4PxomY3lVn8k0uhfbQMdVmPC8=;
        b=r38TmtOCxMrFvutl9Y3O5kPoIrjWLtcuzw0F7Ii0jKwOUel8bUf4T9xIMAuYSko77/
         f7JfXkT42zoEcs+I1FzqbacqinOBHfDOVOII96dEn4yvaywoESDk47jdfH2vMNnKdrH+
         TVn4NnEhODe+mR2DHhxoJUpIMXyRnvi3hCuxwhVt5pp2AXqympv7bCAh3cHqMBT0pM7x
         Jq9jjdhVA2ymTyKhqq4KAudjjgS3LPPy8xK5XKEwJdlGTB4w025Zw8xZKSFdsUYKMtT9
         s1OiH/3c3Uac4pO39CmsnFqEaCrRrF0qfMzh3CUjkEYD3jGvBdoh343NSi0iStijUpQQ
         HlIA==
X-Gm-Message-State: AHQUAuY0WjnDW9JwE/u/a+uaiiy5Cml2I8JLebVSaqhrGQOznpQYi8UR
	oWbTioRMPjS0KPjJjCsnR17wK+2Bh7Pim+Khf5UiSW0yMEYMwyMWW4Jtko1ox48U3WLLXTayBIG
	aYWd1C4BmrX1QFKAifWBoXi3CgRjZMFplhEi8uOQS2UdCttUqJ37xFq17WqcB+N3GN4Ze/2VO8G
	k2TRYQyXTRRpyj6HLAzkeA+IBWoum1hE0DEKRtDbZTEybr+yLAoLqKTJMN7emSDlOFe/nnjhfgL
	dGqF7LFfT6eKNQ/TjzFYHE7AiMjtzv6Ohqx/UrHV1Abx6rfazZ5MZo91h/dm/pwpbMrKsVvIFGR
	43OXMdVUxSj48LGt/ei9Sk+SNxNv6jL3hrUoezUcZfogkJ5MIv6k1ubq6GnxW4Erc5mqYA9Phg6
	B
X-Received: by 2002:a17:902:104:: with SMTP id 4mr5195869plb.62.1549994239938;
        Tue, 12 Feb 2019 09:57:19 -0800 (PST)
X-Received: by 2002:a17:902:104:: with SMTP id 4mr5195824plb.62.1549994239227;
        Tue, 12 Feb 2019 09:57:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549994239; cv=none;
        d=google.com; s=arc-20160816;
        b=AQZsOtIGXlC4KjvEBqdE4PqU/WsBggvyoaqVIRJR77TOZiRHZ7hgAqq8hr56o46szi
         gFBymMS+qLHbe616EhrkV8DVD/a5cTEMiGxvK5ag8jY4LmSTLvDfPeL3rYuPPcFzJKLz
         pvmcDSE/htViQa0/mNH1u2fhWRzYEeQL9x2ibj1DTOnX4jb+kqHaB2m4efjeZR9gCtOz
         JLlEezgAhidCnHw6QDgYxBMIGy2CcBRbA+Fex2M9ZUu8fDhgSOi/e0Z32vwQHBluGbft
         on0byVp595dfl7/o+ynzkIDM3lV180XQhWxKVyKAtI+0y9pcWeMrP02Iv7CiePYofC3a
         udBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=gKD32Yoy3OQX5/4gri4PxomY3lVn8k0uhfbQMdVmPC8=;
        b=N3NM2Rt6Khu63cvVqdRW2q9nNoHVKwvIGCOxeD3g32jCcrzU9bU3jffZTIEaTk/HmB
         7lUHj7u4aeghl+zWQPJmipH5kTGpFNJYvGV2QbEQ0OYJYcTbVqDNBFWzxUba7rM19hpz
         cg+p/zj1F8bit6ddwPhIQ/PMH8a43cN5i7lLNXhCeUGwZem4S0kY6M2A4X1fXnqdkiyp
         A/hSgJIfRqgWHOebHnCHMIKhLKH0GGa0nz/wQNtJBTLLpu1mJDoYQVarpnHZJfdDO78i
         fNnZVJwoig/kaM/sCrAjo6Vyvx3q29sR9q6r0PV+D78/Cl4RCIYR+kCZNpDhngZLH0iI
         h1LQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lrYOH5Dd;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g4sor19501782pgc.74.2019.02.12.09.57.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 09:57:19 -0800 (PST)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lrYOH5Dd;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=gKD32Yoy3OQX5/4gri4PxomY3lVn8k0uhfbQMdVmPC8=;
        b=lrYOH5DduVB4SGWITtLwhHB5PkSnt7X1YF/ulNlufQPN10JdBC3JKMtQnvkf5vzP9A
         YLiuTZoCEu/56JlQngg6SGr+/UVhtpx0a7rvpj98atfRfeSC90uCghKgOA/jrV3byYfR
         DGprnMtdxx+R7cP3dAL5wPq20Lhz1S40qCx/xiOXW987jnfMQQi1jZIpUKswiA5qxLsN
         XcBHq4BkH3HQchxPa9HhnAnVtKHnrXLj2zs/a4wdF+cpd6CagMnzw5KWAmZrD5aKtUvE
         cw33AoTM4HaBgNIVtq6bsALkld1RsUlDXCu2Q1ePr2kSjJGox+I/lilx+murwmqMyiYX
         aSiQ==
X-Google-Smtp-Source: AHgI3IaILzRq1X2DE5NdW31PIJY1d8o4nzOM96VGqUakZek+QPBqTvVl5YHHHJPpQ2A6etEQ4l7PmA==
X-Received: by 2002:a65:614a:: with SMTP id o10mr4701974pgv.387.1549994238809;
        Tue, 12 Feb 2019 09:57:18 -0800 (PST)
Received: from tower.thefacebook.com ([2620:10d:c090:200::5:4d62])
        by smtp.gmail.com with ESMTPSA id z186sm18608427pfz.119.2019.02.12.09.57.17
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Feb 2019 09:57:18 -0800 (PST)
From: Roman Gushchin <guroan@gmail.com>
X-Google-Original-From: Roman Gushchin <guro@fb.com>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <willy@infradead.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	kernel-team@fb.com,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	Roman Gushchin <guro@fb.com>
Subject: [PATCH v2 3/3] mm: show number of vmalloc pages in /proc/meminfo
Date: Tue, 12 Feb 2019 09:56:48 -0800
Message-Id: <20190212175648.28738-4-guro@fb.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190212175648.28738-1-guro@fb.com>
References: <20190212175648.28738-1-guro@fb.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Vmalloc() is getting more and more used these days (kernel stacks,
bpf and percpu allocator are new top users), and the total %
of memory consumed by vmalloc() can be pretty significant
and changes dynamically.

/proc/meminfo is the best place to display this information:
its top goal is to show top consumers of the memory.

Since the VmallocUsed field in /proc/meminfo is not in use
for quite a long time (it has been defined to 0 by the
commit a5ad88ce8c7f ("mm: get rid of 'vmalloc_info' from
/proc/meminfo")), let's reuse it for showing the actual
physical memory consumption of vmalloc().

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Matthew Wilcox <willy@infradead.org>
---
 fs/proc/meminfo.c       |  2 +-
 include/linux/vmalloc.h |  2 ++
 mm/vmalloc.c            | 16 ++++++++++++++++
 3 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 568d90e17c17..465ea0153b2a 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -120,7 +120,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	show_val_kb(m, "Committed_AS:   ", committed);
 	seq_printf(m, "VmallocTotal:   %8lu kB\n",
 		   (unsigned long)VMALLOC_TOTAL >> 10);
-	show_val_kb(m, "VmallocUsed:    ", 0ul);
+	show_val_kb(m, "VmallocUsed:    ", vmalloc_nr_pages());
 	show_val_kb(m, "VmallocChunk:   ", 0ul);
 	show_val_kb(m, "Percpu:         ", pcpu_nr_pages());
 
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 398e9c95cd61..0b497408272b 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -63,10 +63,12 @@ extern void vm_unmap_aliases(void);
 
 #ifdef CONFIG_MMU
 extern void __init vmalloc_init(void);
+extern unsigned long vmalloc_nr_pages(void);
 #else
 static inline void vmalloc_init(void)
 {
 }
+static inline unsigned long vmalloc_nr_pages(void) { return 0; }
 #endif
 
 extern void *vmalloc(unsigned long size);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index f1f19d1105c4..8dd490d8d191 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -340,6 +340,19 @@ static unsigned long cached_align;
 
 static unsigned long vmap_area_pcpu_hole;
 
+static DEFINE_PER_CPU(unsigned long, nr_vmalloc_pages);
+
+unsigned long vmalloc_nr_pages(void)
+{
+	unsigned long pages = 0;
+	int cpu;
+
+	for_each_possible_cpu(cpu)
+		pages += per_cpu(nr_vmalloc_pages, cpu);
+
+	return pages;
+}
+
 static struct vmap_area *__find_vmap_area(unsigned long addr)
 {
 	struct rb_node *n = vmap_area_root.rb_node;
@@ -1566,6 +1579,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
 			BUG_ON(!page);
 			__free_pages(page, 0);
 		}
+		this_cpu_sub(nr_vmalloc_pages, area->nr_pages);
 
 		kvfree(area->pages);
 	}
@@ -1742,12 +1756,14 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 		if (unlikely(!page)) {
 			/* Successfully allocated i pages, free them in __vunmap() */
 			area->nr_pages = i;
+			this_cpu_add(nr_vmalloc_pages, area->nr_pages);
 			goto fail;
 		}
 		area->pages[i] = page;
 		if (gfpflags_allow_blocking(gfp_mask|highmem_mask))
 			cond_resched();
 	}
+	this_cpu_add(nr_vmalloc_pages, area->nr_pages);
 
 	if (map_vm_area(area, prot, pages))
 		goto fail;
-- 
2.20.1

