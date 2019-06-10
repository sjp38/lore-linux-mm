Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3881C282DD
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 11:13:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96C4C206C3
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 11:13:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="C/EGTTb9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96C4C206C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3AEEF6B026C; Mon, 10 Jun 2019 07:13:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3382F6B026D; Mon, 10 Jun 2019 07:13:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D9846B026E; Mon, 10 Jun 2019 07:13:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id DBF5D6B026C
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 07:13:16 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id f9so7019074pfn.6
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 04:13:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rtdW0n4Q4ONaBgNzSNMHKzSk3rd1hSsd9/TPUeo4Zf4=;
        b=sRMXiMHgo0zMTCr9Vvnjxgb0gvsvrEU6ZrvH1ZCa7DDxhodSHpb+jAhEGdmhTkMMaO
         vyx+l59udLiigDRI/8SRiDYbS1SSuOdM7/rbR0THmOGFZdAf6NGehoP3o8ABmhOPJiGK
         5OCd7fMoHNat8ZcT3lXtzXTdzg9Pv5/9xGOPRyWWZiNvv1eJn1SNFFSZTD+SIjdqYHz2
         zfx+5prIKRXzrvwJAkKHXonZPZkdZwBHHCefr1zZ/Dh5pMibbFHhsUW3DpegnBAYNs4V
         CvXkdq64bQHMKx+vyfRXlldVr1hUtmTkG92EH5bX22ra6jw+uk0l0KHYIQu0ty6wH/6u
         pgAw==
X-Gm-Message-State: APjAAAUTMxh4ucTofTJ9UojwVe0LiQ9cd+LS2XMAa/9h31GdSIjnVh8W
	EdCwatxOAsBrsD4VqoB8aajJ42A1IdZi+R06a0Pa744NkYAIBPWwkUfm0x04ptmEMb3PGaj4KuS
	Eit2Ni9+q2HCwz/YwhZ9akNqSLMdaYAAAnMBR1ux8SiaqRE/yuKGTukSvBm5LPk4=
X-Received: by 2002:a63:d4c:: with SMTP id 12mr15695155pgn.30.1560165196475;
        Mon, 10 Jun 2019 04:13:16 -0700 (PDT)
X-Received: by 2002:a63:d4c:: with SMTP id 12mr15695101pgn.30.1560165195666;
        Mon, 10 Jun 2019 04:13:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560165195; cv=none;
        d=google.com; s=arc-20160816;
        b=T6T2hy381SpnJULKFxQLuX9WWEtEvSw+wIx1zJ7jcpXlUwgnvUc0dJOKBC5gMMGfTR
         ZpsvXdEy8aTrk7fJ4N6NhrkertNz49oicKWN+m/E6O3FMz5GJsbN0PyvP2iheWDx+t5E
         PryIQB0faYNmRuTHLvo6rCeT6xwFIr5iDAPhuzHLSat0wFNFvQltumuFEI7O/fz1BAVW
         5DyeTsRLB+xZzSK9lnodB5721WfYfjYhsR2psmGLSszZqSLM69MEyiK9nGCche3Z7hOT
         Y/gV86fbJiSSP84FP8FptkC/608dstQPkxWawN8gIE9a2wnXQnNFXJ7Tisg61UeFVZL+
         Xjdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=rtdW0n4Q4ONaBgNzSNMHKzSk3rd1hSsd9/TPUeo4Zf4=;
        b=t3jsAFObH/xXYc69/lkC0SlIKnKKAZF4sVWNcDHsNodN8QR07yC+nzpIZ0LW5IuDLg
         bbj61wQdM/hTSh7cudWMAaOiQxzOACbCqEqQ2uWgXp/3JCJxgdn2xA7SzlZZRwpf1cpB
         q00BnelatYEroT9og7d395vSt6n5TsQb0I4K4OfKA78Or2ZVNwpbGmtgzX//vycwviHA
         bFPHdah1/JQ7w3EmEwm/dEreQ0OUQx+YMP52FCDcIyz0jL3ZtnF9fD5Enfc/PtyUL3VZ
         I9zwDtqvYwbiQpEnKa/75fcF/DsIkIe6MIbXZsTa6t/TG0l99Ha2kC4kc7P8SS06+cmI
         CNdg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="C/EGTTb9";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t1sor11441120pjo.17.2019.06.10.04.13.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Jun 2019 04:13:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="C/EGTTb9";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=rtdW0n4Q4ONaBgNzSNMHKzSk3rd1hSsd9/TPUeo4Zf4=;
        b=C/EGTTb9dJdZwxuMIvqZVsbbUIRUqEq0Y0GOsoig6NyIpHoHymWCD8ih6Z7c/JT9EQ
         TPYVc6XiFmXsMqqJzzrQfDUkaww3pkzUGlgYKvwRnrUDUd7rMI6YVnlA4QVMw+Iz1ICW
         il5vU458YFkhGj2rBqvx8tEeXt4JQ+GJPR9SuoRXU/7NfzDgWKFqLp8mtwue9uFuOZJE
         YvB9yTdlV946j0YWbsCSQ18+xYS863GYrva8WhdjFwLVK1Ghishf2h2q+kiQAraavvvH
         Yx/2mN058ASCIvAQo909hzJ5sk4SkIChiKgnRD+he2K94Fe8/w89Q5FDi11PRzboCdya
         lsuw==
X-Google-Smtp-Source: APXvYqzUKtfBzCkt8JOrcNL3JVApJN7IuSow2TUbfeFGWUJOWH42s56iyctqroAHvajIeMPIzhFSOA==
X-Received: by 2002:a17:90b:d8b:: with SMTP id bg11mr20724547pjb.30.1560165195244;
        Mon, 10 Jun 2019 04:13:15 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id h14sm9224633pgj.8.2019.06.10.04.13.09
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 04:13:13 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>,
	jannh@google.com,
	oleg@redhat.com,
	christian@brauner.io,
	oleksandr@redhat.com,
	hdanton@sina.com,
	lizeb@google.com,
	Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 2/5] mm: change PAGEREF_RECLAIM_CLEAN with PAGE_REFRECLAIM
Date: Mon, 10 Jun 2019 20:12:49 +0900
Message-Id: <20190610111252.239156-3-minchan@kernel.org>
X-Mailer: git-send-email 2.22.0.rc2.383.gf4fbbf30c2-goog
In-Reply-To: <20190610111252.239156-1-minchan@kernel.org>
References: <20190610111252.239156-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The local variable references in shrink_page_list is PAGEREF_RECLAIM_CLEAN
as default. It is for preventing to reclaim dirty pages when CMA try to
migrate pages. Strictly speaking, we don't need it because CMA didn't allow
to write out by .may_writepage = 0 in reclaim_clean_pages_from_list.

Moreover, it has a problem to prevent anonymous pages's swap out even
though force_reclaim = true in shrink_page_list on upcoming patch.
So this patch makes references's default value to PAGEREF_RECLAIM and
rename force_reclaim with ignore_references to make it more clear.

This is a preparatory work for next patch.

* RFCv1
 * use ignore_referecnes as parameter name - hannes

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 84dcb651d05c..0973a46a0472 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1102,7 +1102,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				      struct scan_control *sc,
 				      enum ttu_flags ttu_flags,
 				      struct reclaim_stat *stat,
-				      bool force_reclaim)
+				      bool ignore_references)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
@@ -1116,7 +1116,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		struct address_space *mapping;
 		struct page *page;
 		int may_enter_fs;
-		enum page_references references = PAGEREF_RECLAIM_CLEAN;
+		enum page_references references = PAGEREF_RECLAIM;
 		bool dirty, writeback;
 		unsigned int nr_pages;
 
@@ -1247,7 +1247,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		if (!force_reclaim)
+		if (!ignore_references)
 			references = page_check_references(page, sc);
 
 		switch (references) {
-- 
2.22.0.rc2.383.gf4fbbf30c2-goog

