Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 350F3C04AB6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 06:34:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA08D27BFC
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 06:34:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BhMamTU0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA08D27BFC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 35D5C6B000C; Mon,  3 Jun 2019 02:34:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E6916B0269; Mon,  3 Jun 2019 02:34:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1397C6B026A; Mon,  3 Jun 2019 02:34:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF9886B000C
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 02:34:32 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s3so9275848pgv.12
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 23:34:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=CBsIkBvODy2SMAroMU4TmKj7JDPTiCcRWf3bIgO8CHE=;
        b=hfZJ7RlHbvB5iuGF7muNetEMGbfVX9sVPUeSSNhqXjggKy1u2svzgYUrP4aySib4ns
         ZM8bUI35sbJTgrLwXYZ7f9kMeabsGb15OIHGpNmWBgGi2fnqlDswRply629raqT09oQn
         Q40pRJiks0GszAE1ccBAGl5iW6fEwM2z4WupRk6wTXbwXHqRql+V2Q8LGbg4BUa426o5
         yseBMd9D4jzPecu4UIQAkdcQkAV0FAi/vGOHJG563wcsgVtoo6Gi2z7Ylk8D+j/PkZmT
         NarPtjo0Fw3dF9fShGEZimORlvd3x87jA/AVdW3Hox1b7Cnng8t4A6VhWoKAAWePA/LX
         lvlg==
X-Gm-Message-State: APjAAAXUK/xTxtv53Ur0kUpGaE5xhRZKjZW9uCStllyqwZ3CbcEV6Uxa
	vh8KHk7kIw0Tmxx+4yC4Rh+vrvAZwwvZbTcO1n9vpnLUK94adIrEPrb9IWXq1p4S827hya6VBeK
	wVefA2Eagd4Qg5jt3FL5hOrqxzjcO8Z+0XLPbVOCBFPN9ZpJCioyvZU9X55ihkDiGXg==
X-Received: by 2002:a63:18e:: with SMTP id 136mr26302268pgb.277.1559543672336;
        Sun, 02 Jun 2019 23:34:32 -0700 (PDT)
X-Received: by 2002:a63:18e:: with SMTP id 136mr26302223pgb.277.1559543671350;
        Sun, 02 Jun 2019 23:34:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559543671; cv=none;
        d=google.com; s=arc-20160816;
        b=qvFdmEa3cQAT+qkcvPoHWAnf+F00xJ5WyjGfA3wTPHvAs/ZPooJIEVYnmC9ZSGkdIA
         1XlHJmMmX0L9KsnGdzUrr4wavKJTkERu+Etw0heJqjAvjRpbbykK6POTK8tFyhZTy5H2
         XnJgAzOd95hrnNsiBHozSQ3RWlbB5s6sDlCZpCTVcl/V1eAEP7DMyQkcM62XsWms1NQZ
         PmCvg7fwekKY+6zaiLzvUFBMyv37ReEJdjaZDfrIxT4GgjBLGUFBSN62PW4Rv5BHww7p
         m4HbXq7r5b4J/X70nKHiLfYG982cJRso/+mrk7a2szvreo0um3ER+zalTzz+ULina5Na
         lVow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=CBsIkBvODy2SMAroMU4TmKj7JDPTiCcRWf3bIgO8CHE=;
        b=a2qFVQTu8Wm9AjD7L8tX6+0/TQLsrp7o7j1heYYOcmGYTEuO7WTFU2Jj3lYTY6x0+o
         aAdnZuLLqaa1ZoXD4/whTHbJ9Q7IOTNMpMJmdsDam1sUWUSUmLpTuPukEyREseHBoxe2
         iGLcht+AKiZUYUXs21xb8dc6zU19I5FMCs6afzdxOSaVt/Cr+x4vacJ9fgvrmPHYFnTa
         mHFDgKIiL0bx0SxTwZ6+kTUpNyqXRKsMVTsfCPXHfMomQM7LsarVWZ93/JldbgMV2sKd
         Tfz+ws5DJlJ83hBTGzM5exbvYW4YfnHmY5VyC5lvmqgz50h6srBSGHq/Edx13zwkV6hz
         pVfA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BhMamTU0;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o5sor13939217pgk.82.2019.06.02.23.34.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 02 Jun 2019 23:34:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BhMamTU0;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=CBsIkBvODy2SMAroMU4TmKj7JDPTiCcRWf3bIgO8CHE=;
        b=BhMamTU0Mc/0EVu+/M0cSdxLSLtdEF4XdEDqq7cwIDqJ7R77OQ6DzkQx8nK1FEbT1z
         4eBywr+SqVgYb04iLdG+/a8DSBrlu5KiO5U47jSQVrXKBW1a0G34o5ggzIhiREoNDvlk
         7M2jOQlgXRYFa/bV2ss2jvJvHnZyl4wT68FX+ihBeaCkm09Yb4Ju5jSl+ni/0sz7yb14
         XSCCuNn4L/L0f3REr3TwEheSyYh34Nfgs9BmZaviqWTlA6thycR71efgcT7PEou8I13m
         9OPKCF0lbheyuixt8G7ahGo4tYBS65QA2LNGZU6zYTHpXQKOStN9Cu5ITqVI21372TMD
         Q8Fw==
X-Google-Smtp-Source: APXvYqwQ1TToPxYTZgvBH7nocMRSyjS+MAPRo/77b8NkuXiJ+gfrhgYYiGq1j9IXEVMHW9lP+JJuTw==
X-Received: by 2002:a65:518d:: with SMTP id h13mr25383136pgq.186.1559543670700;
        Sun, 02 Jun 2019 23:34:30 -0700 (PDT)
Received: from mylaptop.nay.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id j14sm13859027pfe.10.2019.06.02.23.34.26
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 23:34:30 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Keith Busch <keith.busch@intel.com>,
	linux-kernel@vger.kernel.org
Subject: [PATCHv2 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in get_user_pages_fast()
Date: Mon,  3 Jun 2019 14:34:12 +0800
Message-Id: <1559543653-13185-1-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

As for FOLL_LONGTERM, it is checked in the slow path
__gup_longterm_unlocked(). But it is not checked in the fast path, which
means a possible leak of CMA page to longterm pinned requirement through
this crack.

Place a check in the fast path.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Keith Busch <keith.busch@intel.com>
Cc: linux-kernel@vger.kernel.org
---
 mm/gup.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/mm/gup.c b/mm/gup.c
index f173fcb..6fe2feb 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2196,6 +2196,29 @@ static int __gup_longterm_unlocked(unsigned long start, int nr_pages,
 	return ret;
 }
 
+#if defined(CONFIG_CMA)
+static inline int reject_cma_pages(int nr_pinned, unsigned int gup_flags,
+	struct page **pages)
+{
+	if (unlikely(gup_flags & FOLL_LONGTERM)) {
+		int i = 0;
+
+		for (i = 0; i < nr_pinned; i++)
+			if (is_migrate_cma_page(pages[i])) {
+				put_user_pages(pages + i, nr_pinned - i);
+				return i;
+			}
+	}
+	return nr_pinned;
+}
+#else
+static inline int reject_cma_pages(int nr_pinned, unsigned int gup_flags,
+	struct page **pages)
+{
+	return nr_pinned;
+}
+#endif
+
 /**
  * get_user_pages_fast() - pin user pages in memory
  * @start:	starting user address
@@ -2236,6 +2259,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 		ret = nr;
 	}
 
+	nr = reject_cma_pages(nr, gup_flags, pages);
 	if (nr < nr_pages) {
 		/* Try to get the remaining pages with get_user_pages */
 		start += nr << PAGE_SHIFT;
-- 
2.7.5

