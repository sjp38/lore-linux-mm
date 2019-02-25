Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E7B5C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:30:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EC4A2084D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:30:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TSJgbO39"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EC4A2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C73CA8E0016; Mon, 25 Feb 2019 15:30:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C26578E000C; Mon, 25 Feb 2019 15:30:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B16EF8E0016; Mon, 25 Feb 2019 15:30:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 71AD48E000C
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 15:30:47 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 71so8053922plf.19
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 12:30:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Yaq3RFczd2qZjXsU2QljCDi4OLq0Yre6ksGO/t1/+qE=;
        b=b7kjkzYJrpvwPXNQ3lNbnqNO06Ym9nT9r+czEqS5qssDr308woIaoZmZ31VM+9OTZR
         1fAfLYyBa/ci0pW70kfbeyI/v6rHsKWZkgHqIg3Obem+yepRI87lVY97Ir05/DIOCtdl
         VC9zUuT5ASryN/XJx8BWYnhGZXvIcHS+U79T5DKzPlMuTuG/4XPe5vJH4UoSDZRhREGe
         FSoc5ZGWqWGmjGdPhuQ7RVGFCtsucmjsBWAcvb10FkoaC1PUglbSStogd/c9wC9V0Wiv
         FcQKbnV3qVFeB93T+MzLj+sMwhXgC4TynbWoLQ1Ie/CtfdDVXKw8cFX2nruh+mzL8X4N
         cM5w==
X-Gm-Message-State: AHQUAuaqB6ysYAB5/sNmHZ1wPjIXiv9vFV1IAPOdIaT2cA5hTNAhv2Vn
	haZo1aL2N4wIVHiP8hJ7laF8dqFViedFaf+I77lVFATHmEXob+dBDXrH7Sag1nHVQiPMILDqD5r
	RulcmIBFh6ROSpdSCLzHrLwVYOd/wcfyCPV+LLfi6C+5VxMgkiwSgu0TLZJYqG+bKktwHz5fNKp
	dgLpbUc9nKXn58YL16Vnw6DZLmr++4qe6w17kZCNI6T9XVkg6v1eaVM+tdZ0/gXcPwwxohqKwvi
	nKsGOQKV4CMDsWEQQpmi9xvAqr5wz6fzZFmZHL5Kvi5dpjKLyOCExPReNOUif2JSxaTgxVgOTvW
	LvneuYTDR0GeuftWoDxYizZBmNNEXtmvuWRDYXCr1Ib9ji5BSC+sy3woUCFwmfWMs4PmPRgRnZ8
	J
X-Received: by 2002:a63:2a89:: with SMTP id q131mr20177647pgq.216.1551126647136;
        Mon, 25 Feb 2019 12:30:47 -0800 (PST)
X-Received: by 2002:a63:2a89:: with SMTP id q131mr20177590pgq.216.1551126646083;
        Mon, 25 Feb 2019 12:30:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551126646; cv=none;
        d=google.com; s=arc-20160816;
        b=eQXPwmDJXESYLlUO8+VQZrCeJRkNgR24CeHM7Ltweej7H7AMY7YA+e4yt4GRowBuS9
         hXK0IOFj1jgZ0tua0aXExSrPecr+NHtXRhUpfrUOOFpcjnfCC4MXYA+6B79HuL797awZ
         O5wUyWkMC2I+Uc3gEWzR+HKRZFdF1NBb8zs8KECxEIqNLiLzyX9IvPwjo92ig7TViXwz
         vVo5mEynHoe039Yt+c+gemW87lvYD766gI5EUSUZjXRJBOE/yEbSUR3H+fhqIGDc+sy7
         Xq0O+m2sPcD5w1K0PuEJoUpR3+G6jNzp58hXa8b5UBZ4BJ16K3bkVX2OvfmI0RlvilGh
         czfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Yaq3RFczd2qZjXsU2QljCDi4OLq0Yre6ksGO/t1/+qE=;
        b=Ru9W+71tpjsRXDwXNx6lozymJZKH59hxEFbC1BQzvps8ubXLHhr6MY6+ImqxrG1ubd
         7Jc51X0F56PGX81djcwKYR6lSSLWrlVcn5g6BNmKh9f5nj77L2/nFCTIEOfQD1Psy/NW
         erNwKtK218f5gcjBoDfgzdjxtVoKQMmMSO3JF9WEzcFZiZwNsc4B90V2EnLqJXaeg5Gh
         6fCZ604bZDHmlFCf8AxovBkIAdy4qyfNF+jB5COLkD+DrmkPRmg+Q4pQM7QHfCX5qMP+
         S+T6BOJSrB/KbP3hSyO3Yka8kPfZKqJ4oTq1n0oRjvmB6i4JLhvSIoBKcFNoiIeypZfL
         oqUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TSJgbO39;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w16sor3476663plp.55.2019.02.25.12.30.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 12:30:46 -0800 (PST)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TSJgbO39;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Yaq3RFczd2qZjXsU2QljCDi4OLq0Yre6ksGO/t1/+qE=;
        b=TSJgbO39yugGnx2PvUuojmqyvwSgSNGTJgLuDP4aR9Ku68PHWYHKfPXvKsMTnVEd12
         rKIDl+o7PtIwVK1mi5iwJraWvAHszmY/koNoOrj7tA2VHmAwoF80g7XJ6ZdOsp6qzHru
         wmwygNQnR5dcE7pTgQaSjIf1qfXkKiCp69fRYfod5v+8NNf/RbanTq7/ThUASfXkJA1i
         e1AAKUhq5sYU+VTgKVC5zvKTqdXEja24wetM3a866iRV7hHOsVa5k2QACx64uaXCD8oD
         hvZt/Z4nCWu7WOnjNQ8vsT95fv6hO1x0M6B2WXB1ddE63owJguDeUBctEhpK/FDBu5ha
         lU/g==
X-Google-Smtp-Source: AHgI3IZuz86KzJNateQzLeGXd+kLin0VH/37xJYSq9ecmdFKTb6a8cwLDn3FBagE6uMysI09FNqIPg==
X-Received: by 2002:a17:902:8348:: with SMTP id z8mr22713865pln.151.1551126645554;
        Mon, 25 Feb 2019 12:30:45 -0800 (PST)
Received: from tower.thefacebook.com ([2620:10d:c090:200::2:d960])
        by smtp.gmail.com with ESMTPSA id s4sm6189885pfe.16.2019.02.25.12.30.44
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 25 Feb 2019 12:30:44 -0800 (PST)
From: Roman Gushchin <guroan@gmail.com>
X-Google-Original-From: Roman Gushchin <guro@fb.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	Matthew Wilcox <willy@infradead.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	kernel-team@fb.com,
	Roman Gushchin <guro@fb.com>
Subject: [PATCH 3/3] mm: show number of vmalloc pages in /proc/meminfo
Date: Mon, 25 Feb 2019 12:30:37 -0800
Message-Id: <20190225203037.1317-4-guro@fb.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190225203037.1317-1-guro@fb.com>
References: <20190225203037.1317-1-guro@fb.com>
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
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/proc/meminfo.c       |  2 +-
 include/linux/vmalloc.h |  2 ++
 mm/vmalloc.c            | 10 ++++++++++
 3 files changed, 13 insertions(+), 1 deletion(-)

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
index f1f19d1105c4..3a1872ee8294 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -340,6 +340,13 @@ static unsigned long cached_align;
 
 static unsigned long vmap_area_pcpu_hole;
 
+static atomic_long_t nr_vmalloc_pages;
+
+unsigned long vmalloc_nr_pages(void)
+{
+	return atomic_long_read(&nr_vmalloc_pages);
+}
+
 static struct vmap_area *__find_vmap_area(unsigned long addr)
 {
 	struct rb_node *n = vmap_area_root.rb_node;
@@ -1566,6 +1573,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
 			BUG_ON(!page);
 			__free_pages(page, 0);
 		}
+		atomic_long_sub(area->nr_pages, &nr_vmalloc_pages);
 
 		kvfree(area->pages);
 	}
@@ -1742,12 +1750,14 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 		if (unlikely(!page)) {
 			/* Successfully allocated i pages, free them in __vunmap() */
 			area->nr_pages = i;
+			atomic_long_add(area->nr_pages, &nr_vmalloc_pages);
 			goto fail;
 		}
 		area->pages[i] = page;
 		if (gfpflags_allow_blocking(gfp_mask|highmem_mask))
 			cond_resched();
 	}
+	atomic_long_add(area->nr_pages, &nr_vmalloc_pages);
 
 	if (map_vm_area(area, prot, pages))
 		goto fail;
-- 
2.20.1

