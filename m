Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10F16C282D7
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 05:21:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1A9A2147A
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 05:21:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pWRckgR/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1A9A2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF1CC8E0036; Mon,  4 Feb 2019 00:21:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C79E38E001C; Mon,  4 Feb 2019 00:21:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA4048E0036; Mon,  4 Feb 2019 00:21:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5DB458E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 00:21:49 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 12so10853451plb.18
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 21:21:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=katn607xCpcBthNGn7+F5ucUPJVzfFnzNUcsboMYyFc=;
        b=HrEMavouSLukgwaHZJXRoABNCkUZFE3y9uwRtNrzFuUga4DyRVUV7kRf3VM3ley1Fb
         z90z0YQWpz0tQKXL1JZM3lQweU9L/6b+LQaYZxC3SGP4veN5rn+vm/V/Jydhk9q81ox3
         mWkTdCYH/r77y+L07kJ1FLYsYEy8hGnqU78shMnDZFV6zzgaRqnqbZt3rd+mywhCR6kW
         kkQElhd3ZT9puewcNj5y4OAGDGMpeA8lxrkWtrXBF9YjJZl1MrGGbkz3/9EtYMmVQaxf
         wcgNDXhneRorOZjFbzsGAsaS0eHAsuiO8aQGYUkj2TjJ9DJbQvjgwvuj+NWZfoexGAoW
         m0Hg==
X-Gm-Message-State: AHQUAuYMf8fHrfCdfBqX5cKThk5WuGKJRDlMDgdO1Eb2UplSz7vgsDT0
	xH0T3O0k6IXmzlH+Nb+09kupp6a90++f/X/T0/WSp+WQGoJywpAg7+/g5ou+qLFGWrIEdKmrwpl
	Md3YDdHV9RZT+aQbt5isJJmYJ80eACzO4ag7pemdORIpnYbYqboaSiAIFAkDi3DKSzN8TtqFvq/
	txXKJct+cba7rdCho0CwN8AaEYOgHq5xgV061uNvP3GjAKqsNMATLf8aF3w7j0grmCUaV9BBsaR
	xfBuNCwxOn6RcAAVWLpxZ4TVzkq4sZJw3sgnmcSWhFrtNWBc9fLdvc7aCjJBAvBLDu+oLEWHEf9
	Egw7Rbt79Gfsm5hpzlHNjAbxXdKQeb8CBJ+4ke/D7F0BXJkyHgSElkNqZLAoMXPVLVikP5vf19W
	s
X-Received: by 2002:a17:902:8c93:: with SMTP id t19mr326657plo.293.1549257708918;
        Sun, 03 Feb 2019 21:21:48 -0800 (PST)
X-Received: by 2002:a17:902:8c93:: with SMTP id t19mr326618plo.293.1549257708114;
        Sun, 03 Feb 2019 21:21:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549257708; cv=none;
        d=google.com; s=arc-20160816;
        b=czE1Z6mdfBFmFId9XKv/B7IdvK+Jc5MnhYtc75Jkd0TIbirdLqOzHiXIHLr5j028Nu
         EZEYByzeAngCSv3pETE2YMdAcgfOovGxz6HrZvdvCQhy5qS+u55lAft3ju/PrM3/3GgE
         VQEQgyShBmC5pT3mzoKwof767gXTpSXMTe8p1FgspBa8jml6zBKTSSl/8LZMigUjjvxZ
         0DrMaUWdLO/prgJ585f0JCMg73wSc/lPbMOe4NPG/RiNVTRVFPyJ1QWpy9ZTMYgStnsr
         Zz/4R0v+dqtmJOp8p2A4qIxj7RyoghwwXmpYMdsN+HgokrxBD3SOaIoPnlnfx7fHCsA6
         6hGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=katn607xCpcBthNGn7+F5ucUPJVzfFnzNUcsboMYyFc=;
        b=pVPxGJvPPXAm3+kbAHhHFJaHUMzU/xFV+aHirrhVVws4W+jpxuXa7W13eFCfrXgHCn
         efUN6YS4BnbakuTszelER9EifdYCLjcrrtDpzXaugJntIRHdQH4hvKNT5BQgUP0UVF67
         qc9xxrGU2kej8su2VJ4b5OdaPZxnCQeVMEGucfKmPdI9zyFLNx7QIetGfm+iH5HCc1+W
         2Dn/dwTKmrDBqaDWI97WawY1XWKutjwxMXuurr7fxk5G946mi5LYTBGvXRXcIZN0HA7F
         Vdrgl/mUPz4bMAmu4I+hSJzIdm4hxAX7ZH5SeLqp/xFSkK5v7xX0Z2qBwLe2q4xqUYwo
         0pMw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="pWRckgR/";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z11sor23510912pln.25.2019.02.03.21.21.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 03 Feb 2019 21:21:48 -0800 (PST)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="pWRckgR/";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=katn607xCpcBthNGn7+F5ucUPJVzfFnzNUcsboMYyFc=;
        b=pWRckgR/GrduefqkubKAWLQN0QrlrUwOrK7viKf3yv/6PWVbr1Pp8hgvbfONr6kC5G
         t6GvCRh/EkiZPF+nfYnu/qrWGHgm8Hq/Td62zDdEDJlL+VuHVtsgVtFUbSVzSRdNK3pi
         jv6gPyVCTWaCY6LB7pVFX1QXuHTIVlLClfnQeFlUXR4XyYY4KVZ3sp/9W4TYNaWINzpQ
         8xRwio3rrIFI5ifkwgKiNaW33pTP+AUTABByEc0m2RyDqGO1tYJr61JJeIy20Mgg+AE/
         +QQRUUu7iaFMM7pd+Vzp3ESaQYTevVgDD8OhP3SKb8yDyXrzFiSeyIRlFhrH+f1rfy+w
         xoVw==
X-Google-Smtp-Source: AHgI3IZhYffp2PH7FKVUiJPsXoBJbIKMUQ1HUjrZNqYRs3NJ330iJtQbZGLQcYh48USkmoj6KgfrrQ==
X-Received: by 2002:a17:902:7786:: with SMTP id o6mr2206970pll.234.1549257707798;
        Sun, 03 Feb 2019 21:21:47 -0800 (PST)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id m9sm33428844pgd.32.2019.02.03.21.21.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Feb 2019 21:21:47 -0800 (PST)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jerome Glisse <jglisse@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 5/6] mm/gup: /proc/vmstat support for get/put user pages
Date: Sun,  3 Feb 2019 21:21:34 -0800
Message-Id: <20190204052135.25784-6-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190204052135.25784-1-jhubbard@nvidia.com>
References: <20190204052135.25784-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

Add five new /proc/vmstat items, to provide some
visibility into what get_user_pages() and put_user_page()
are doing.

After booting and running fio (https://github.com/axboe/fio)
a few times on an NVMe device, as a way to get lots of
get_user_pages_fast() calls, the counters look like this:

$ cat /proc/vmstat |grep gup
nr_gup_slow_pages_requested 21319
nr_gup_fast_pages_requested 11533792
nr_gup_fast_page_backoffs 0
nr_gup_page_count_overflows 0
nr_gup_pages_returned 11555104

Interpretation of the above:
   Total gup requests (slow + fast): 11555111
   Total put_user_page calls:        11555104

This shows 7 more calls to get_user_pages(), than to
put_user_page(). That may, or may not, represent a
problem worth investigating.

Normally, those last two numbers should be equal, but a
couple of things may cause them to differ:

1) Inherent race condition in reading /proc/vmstat values.

2) Bugs at any of the get_user_pages*() call sites. Those
sites need to match get_user_pages() and put_user_page() calls.

Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/mmzone.h |  5 +++++
 mm/gup.c               | 20 ++++++++++++++++++++
 mm/swap.c              |  1 +
 mm/vmstat.c            |  5 +++++
 4 files changed, 31 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 842f9189537b..f20c14958a2b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -183,6 +183,11 @@ enum node_stat_item {
 	NR_DIRTIED,		/* page dirtyings since bootup */
 	NR_WRITTEN,		/* page writings since bootup */
 	NR_KERNEL_MISC_RECLAIMABLE,	/* reclaimable non-slab kernel pages */
+	NR_GUP_SLOW_PAGES_REQUESTED,	/* via: get_user_pages() */
+	NR_GUP_FAST_PAGES_REQUESTED,	/* via: get_user_pages_fast() */
+	NR_GUP_FAST_PAGE_BACKOFFS,	/* gup_fast() lost to page_mkclean() */
+	NR_GUP_PAGE_COUNT_OVERFLOWS,	/* gup count overflowed: gup() failed */
+	NR_GUP_PAGES_RETURNED,		/* via: put_user_page() */
 	NR_VM_NODE_STAT_ITEMS
 };
 
diff --git a/mm/gup.c b/mm/gup.c
index 3291da342f9c..848ee7899831 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -37,6 +37,8 @@ int get_gup_pin_page(struct page *page)
 	page = compound_head(page);
 
 	if (page_ref_count(page) >= (UINT_MAX - GUP_PIN_COUNTING_BIAS)) {
+		mod_node_page_state(page_pgdat(page),
+				    NR_GUP_PAGE_COUNT_OVERFLOWS, 1);
 		WARN_ONCE(1, "get_user_pages pin count overflowed");
 		return -EOVERFLOW;
 	}
@@ -184,6 +186,8 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 			page = ERR_PTR(ret);
 			goto out;
 		}
+		mod_node_page_state(page_pgdat(page),
+				    NR_GUP_SLOW_PAGES_REQUESTED, 1);
 	}
 	if (flags & FOLL_TOUCH) {
 		if ((flags & FOLL_WRITE) &&
@@ -527,6 +531,8 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
 	ret = get_gup_pin_page(*page);
 	if (ret)
 		goto unmap;
+
+	mod_node_page_state(page_pgdat(*page), NR_GUP_SLOW_PAGES_REQUESTED, 1);
 out:
 	ret = 0;
 unmap:
@@ -1461,7 +1467,12 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 		if (!page_cache_gup_pin_speculative(head))
 			goto pte_unmap;
 
+		mod_node_page_state(page_pgdat(head),
+				    NR_GUP_FAST_PAGES_REQUESTED, 1);
+
 		if (unlikely(pte_val(pte) != pte_val(*ptep))) {
+			mod_node_page_state(page_pgdat(head),
+					    NR_GUP_FAST_PAGE_BACKOFFS, 1);
 			put_user_page(head);
 			goto pte_unmap;
 		}
@@ -1522,6 +1533,9 @@ static int __gup_device_huge(unsigned long pfn, unsigned long addr,
 			return 0;
 		}
 
+		mod_node_page_state(page_pgdat(page),
+				    NR_GUP_FAST_PAGES_REQUESTED, 1);
+
 		(*nr)++;
 		pfn++;
 	} while (addr += PAGE_SIZE, addr != end);
@@ -1607,6 +1621,8 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 		return 0;
 	}
 
+	mod_node_page_state(page_pgdat(head), NR_GUP_FAST_PAGES_REQUESTED, 1);
+
 	if (unlikely(pmd_val(orig) != pmd_val(*pmdp))) {
 		*nr -= refs;
 		put_user_page(head);
@@ -1644,6 +1660,8 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 		return 0;
 	}
 
+	mod_node_page_state(page_pgdat(head), NR_GUP_FAST_PAGES_REQUESTED, 1);
+
 	if (unlikely(pud_val(orig) != pud_val(*pudp))) {
 		*nr -= refs;
 		put_user_page(head);
@@ -1680,6 +1698,8 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
 		return 0;
 	}
 
+	mod_node_page_state(page_pgdat(head), NR_GUP_FAST_PAGES_REQUESTED, 1);
+
 	if (unlikely(pgd_val(orig) != pgd_val(*pgdp))) {
 		*nr -= refs;
 		put_user_page(head);
diff --git a/mm/swap.c b/mm/swap.c
index 39b0ddd35933..49e192f242d4 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -150,6 +150,7 @@ void put_user_page(struct page *page)
 
 	VM_BUG_ON_PAGE(page_ref_count(page) < GUP_PIN_COUNTING_BIAS, page);
 
+	mod_node_page_state(page_pgdat(page), NR_GUP_PAGES_RETURNED, 1);
 	page_ref_sub(page, GUP_PIN_COUNTING_BIAS);
 }
 EXPORT_SYMBOL(put_user_page);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 83b30edc2f7f..18a1a4a2dd29 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1164,6 +1164,11 @@ const char * const vmstat_text[] = {
 	"nr_dirtied",
 	"nr_written",
 	"nr_kernel_misc_reclaimable",
+	"nr_gup_slow_pages_requested",
+	"nr_gup_fast_pages_requested",
+	"nr_gup_fast_page_backoffs",
+	"nr_gup_page_count_overflows",
+	"nr_gup_pages_returned",
 
 	/* enum writeback_stat_item counters */
 	"nr_dirty_threshold",
-- 
2.20.1

