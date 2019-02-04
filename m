Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 159D3C282D7
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 05:21:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDA292147A
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 05:21:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dCgCM4kx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDA292147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA65C8E0034; Mon,  4 Feb 2019 00:21:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BA128E001C; Mon,  4 Feb 2019 00:21:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 770978E0034; Mon,  4 Feb 2019 00:21:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2BE388E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 00:21:46 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id p9so11559224pfj.3
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 21:21:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=R4CKeqTOSmKlGqbqNcuRp8AhVSkNF996muKePf4UyiQ=;
        b=br2wB7rqnsNJsuWrjH6vjhu1k4eeBLspyUxHLSh7+9EnWysoOGLSkq/6bnkS1oAwcE
         TfjJVFEk4Z9ilcsArX5ndeojnsR5U7wFYIegZEAWxZTRdMUhu1eYi6nr7E2wjB9u/2di
         Qynx9R+mynr1pZeMHrKg15OM0RmLK7x1wyzcBjCJuo5wXCFz08nUOY5+dUyZydlyn+WN
         ddP0GBQix7BF+wsa1+9/4OPu4l6+BRyiEJ5S2kwLPB1QMYK8e7ef4z1JiGxYVz2wGujM
         Qgt6+eJNmr+HgD0U2YSZRVqaCoWZUO78uLoidYLO4GeIAzDawWCc0BBPVb70+TpieGHP
         DZIA==
X-Gm-Message-State: AHQUAuaOQGODG2ty+TP0UGH0fq5pDRKDmGmIDnb8zkQhYsYaLdfBnvD4
	KG4Ljzt2ZZdZtRQbxHLeGLWtrIDocTpltrt8Ra5SH1p7JR+eBfBRQY3vb0/9SoJS0xJKJxUxAfU
	XBKHPZuI0DblxTprf3ycT1N906+xB8svWxt8jyOTUQbP5dU/40BJMyqcAqpheOKc+wMxCrUhbnq
	SezAmrpdA8DRRsOxsPrVSQDgZ0Tj8aVfUFa/pt4q4TNY4nq52U28TSQ70ddBvCQ3YsH6+75Myav
	AJTQDDpLP6ImZRo2ETXKFU/Bzb5l2idup3kcUP88wZVHgtcWrqlB7qqt6foZl9NF/yzZYEn0KOE
	RkMsFYEkgw6ztv/h8Qt6gdT5p+yEcbil7RzTYJzihUcZjzKfg8Z5to2AcEpT/IpNmkBD9AIOQN7
	f
X-Received: by 2002:a63:d547:: with SMTP id v7mr11581074pgi.339.1549257705749;
        Sun, 03 Feb 2019 21:21:45 -0800 (PST)
X-Received: by 2002:a63:d547:: with SMTP id v7mr11581053pgi.339.1549257705038;
        Sun, 03 Feb 2019 21:21:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549257705; cv=none;
        d=google.com; s=arc-20160816;
        b=kqwuwdTLWzLGF9HNPYR1h/ravlAiF1CZz2kDnAMCED1wU6oGA37So9iQYMrZt8nlc/
         FLLIWSpfD8d/5vl6JxDSdycDXVfKPbMYf2BgmqWs0PWqjxBJvbGdg5P5zfOUX56bwWAU
         7Exihmjk2f/wiK9ebSez8mRx4OoYDEHuBiUgncGxJeYkOMkXlrp7Yhr81gil7Ocxz6dG
         +KXkmN4sRwwR/d5j9l2d9ZHaFybw5Id5/Pvue5hdJrDipyeHbnGdmrVBrruNQPvAnbmC
         niGcgh1OSDfNujcBw3IW0Om2cNRdIyQgxtYVrEjIRKat5k9aGk3zWaEPthxQ04Lj+53g
         NMTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=R4CKeqTOSmKlGqbqNcuRp8AhVSkNF996muKePf4UyiQ=;
        b=T/tMwasBJBV85DblplFw2uH+uOlnIIV8XK59Eg1ZsUZSdnO7s95FS5CK6lSX9zQu7C
         LY6QvCsJlq+ccsDt7eUdgkKGARCdqZ98fUdvL7hxql2yXPeu/07R2fGLQjGYmH8ioEBU
         Kbw7ITK0r/sizTpNBYCZTkaC+H1JiQnNuB2vOfTNRXXtmbUnfvmpg/9yQJI/Bg768qaE
         TGuP0UMfIyyAAQM9LdjPo+NzPPHmbK353j10L/zJPKj7+m8cDfkIufFNfjkjFkQ5thwx
         oTpOXCwJD03u1kyr5tYqvvSOvf3AvwUEjDEe2G/p5UurTkE14wSGGADfB0DuF67hYOz0
         zCRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dCgCM4kx;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a83sor25981773pfj.39.2019.02.03.21.21.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 03 Feb 2019 21:21:45 -0800 (PST)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dCgCM4kx;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=R4CKeqTOSmKlGqbqNcuRp8AhVSkNF996muKePf4UyiQ=;
        b=dCgCM4kxkIkNx8+lyGzDwBsFdjtmMfYX9Ec4JWeIZUivWzFtxYJVkSB80D6rlAgUXt
         apMTDk1LWohYbDZuEG/0M/XdQeXxySgj974NdakDIygVov0GdzdX2pAnT2F/LkGteN29
         9kFxQ5oupLMOwDR/m7805Q2dlqRRW2TTo67oIR/RcHYDMCJeYD5lZI2rujNzyv7U/pKM
         9Ic07Tv/rivdrPTddLlgR703NdoAvU4UYSE9bErMcbUgA2K1ZKlIascnv+vTLQFhsK6N
         yQ/7vmOMgW3iojCLDyrbIAA2cUJNPl3wLnr6BazZPAL8dN5O4ikJTYdkDOuy+5ITVBYv
         WXEQ==
X-Google-Smtp-Source: ALg8bN6krfQfG2WWpOOlWKb1k4NMAXG/wa4T0P0f3PRSih/YugmwJosjeTH7sTGtR69+kLBSK2MARg==
X-Received: by 2002:a62:e201:: with SMTP id a1mr48715738pfi.75.1549257704697;
        Sun, 03 Feb 2019 21:21:44 -0800 (PST)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id m9sm33428844pgd.32.2019.02.03.21.21.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Feb 2019 21:21:43 -0800 (PST)
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
	John Hubbard <jhubbard@nvidia.com>,
	Nick Piggin <npiggin@suse.de>,
	Dave Kleikamp <shaggy@linux.vnet.ibm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 3/6] mm: page_cache_add_speculative(): refactoring
Date: Sun,  3 Feb 2019 21:21:32 -0800
Message-Id: <20190204052135.25784-4-jhubbard@nvidia.com>
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

This combines the common elements of these routines:

    page_cache_get_speculative()
    page_cache_add_speculative()

This was anticipated by the original author, as shown by the comment
in commit ce0ad7f095258 ("powerpc/mm: Lockless get_user_pages_fast()
for 64-bit (v3)"):

    "Same as above, but add instead of inc (could just be merged)"

An upcoming patch for get_user_pages() tracking will use these routines,
so let's remove the duplication now.

There is no intention to introduce any behavioral change, but there is a
small risk of that, due to slightly differing ways of expressing the
TINY_RCU and related configurations.

Cc: Nick Piggin <npiggin@suse.de>
Cc: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/pagemap.h | 33 +++++++++++----------------------
 1 file changed, 11 insertions(+), 22 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index e2d7039af6a3..5c8a9b59cbdc 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -164,8 +164,10 @@ void release_pages(struct page **pages, int nr);
  * will find the page or it will not. Likewise, the old find_get_page could run
  * either before the insertion or afterwards, depending on timing.
  */
-static inline int page_cache_get_speculative(struct page *page)
+static inline int __page_cache_add_speculative(struct page *page, int count)
 {
+	VM_BUG_ON(in_interrupt());
+
 #ifdef CONFIG_TINY_RCU
 # ifdef CONFIG_PREEMPT_COUNT
 	VM_BUG_ON(!in_atomic() && !irqs_disabled());
@@ -180,10 +182,10 @@ static inline int page_cache_get_speculative(struct page *page)
 	 * SMP requires.
 	 */
 	VM_BUG_ON_PAGE(page_count(page) == 0, page);
-	page_ref_inc(page);
+	page_ref_add(page, count);
 
 #else
-	if (unlikely(!get_page_unless_zero(page))) {
+	if (unlikely(!page_ref_add_unless(page, count, 0))) {
 		/*
 		 * Either the page has been freed, or will be freed.
 		 * In either case, retry here and the caller should
@@ -197,27 +199,14 @@ static inline int page_cache_get_speculative(struct page *page)
 	return 1;
 }
 
-/*
- * Same as above, but add instead of inc (could just be merged)
- */
-static inline int page_cache_add_speculative(struct page *page, int count)
+static inline int page_cache_get_speculative(struct page *page)
 {
-	VM_BUG_ON(in_interrupt());
-
-#if !defined(CONFIG_SMP) && defined(CONFIG_TREE_RCU)
-# ifdef CONFIG_PREEMPT_COUNT
-	VM_BUG_ON(!in_atomic() && !irqs_disabled());
-# endif
-	VM_BUG_ON_PAGE(page_count(page) == 0, page);
-	page_ref_add(page, count);
-
-#else
-	if (unlikely(!page_ref_add_unless(page, count, 0)))
-		return 0;
-#endif
-	VM_BUG_ON_PAGE(PageCompound(page) && page != compound_head(page), page);
+	return __page_cache_add_speculative(page, 1);
+}
 
-	return 1;
+static inline int page_cache_add_speculative(struct page *page, int count)
+{
+	return __page_cache_add_speculative(page, count);
 }
 
 #ifdef CONFIG_NUMA
-- 
2.20.1

