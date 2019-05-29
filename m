Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB5A3C28CC2
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 22:54:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F3F5242BC
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 22:54:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="i2m6pNEp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F3F5242BC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05F2D6B026A; Wed, 29 May 2019 18:54:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00FEA6B026D; Wed, 29 May 2019 18:54:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E412F6B026E; Wed, 29 May 2019 18:54:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id AD19A6B026A
	for <linux-mm@kvack.org>; Wed, 29 May 2019 18:54:33 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d125so3043569pfd.3
        for <linux-mm@kvack.org>; Wed, 29 May 2019 15:54:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=jSKQLZwrhmnSigLvBb1y7bTu3QweUmRNvIXEtuAqha8=;
        b=Fn52LCAPW8gtIORrHK1r2YTFO/t9O0WrPTQMha7j3uoKkoyJ5kTCKVBPx2tdEJPIgN
         yR0iZupRhCxifulz5N73Xo46Bu9yDkd/1Z089YazoOnL/cpvkhovVjP/1vKqvXrS2VKi
         +PifcFkOSpP7d5XzFozt1RG6r+Mm687gqu6lSehIJc6RcfFwnXf5TWzNjSCfCeU8AtQl
         hX9VDtFF1qkL6DmT26+IN3ii8Ym3D3/Nq2lZTrdUkM+trDcUWSTYzBfqTBmGJ0xW4yEC
         +9g53PFFcklX6R7PE6uafIngv4dqTFyIZkdhP3dfL9YUo5KqJORmeeG9SBtmElpQDdcF
         7Itw==
X-Gm-Message-State: APjAAAWD6/4/i5W+QPtoSSATwPVWbynUrhYhPDyWhY++bzNY4Hm5fzMd
	XOuh1o5kuhuFsAvK4Hb/4ad1go0grq+586lPJ9wddxrLHtgI9Zi3ECARD2UFrqZ0FcZ9WNRTt3q
	zcYWjsnd+OT8CZYx+3zO1BDb00C79m7I4JVVD1/fA/knwjUcwOlZuFt/k1zcgx8KiWA==
X-Received: by 2002:a17:90a:ac18:: with SMTP id o24mr388404pjq.116.1559170473238;
        Wed, 29 May 2019 15:54:33 -0700 (PDT)
X-Received: by 2002:a17:90a:ac18:: with SMTP id o24mr388335pjq.116.1559170472450;
        Wed, 29 May 2019 15:54:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559170472; cv=none;
        d=google.com; s=arc-20160816;
        b=gEt3Jch7QBvq7Bb3Q7bRWkpWYNwkiHVm+ML8+bstXMUvZo5Mwx15FHGTdtGbHKTY6p
         LfZrqCprkuVwUhq3kb2zvbgpdFlayUBXZxCbWulDRBlpw9tbDhmXiOiIRnzDnyUY2rRh
         9zi9vqP6uscATLWVg7RJeU23ROgmIynF7vD2vbuGILzhcG9ECwnzSIN5deQhDstg/xXf
         hlkLl9/uGaPWwTMVhCHoIu1qYJ8/8449Yx0okvld71gYIXCL0LIx7ZAUorNwhJvVUN3l
         eZBErGk/Fdl2iMkYA+4Qfgiso3k2wBgL5oEnhglqQpodq7uMIZOr2ieq0U6Z93GafF3y
         743Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=jSKQLZwrhmnSigLvBb1y7bTu3QweUmRNvIXEtuAqha8=;
        b=eW5jVLtdDEokHpk2WaC0xFz5h4nldSM+9wmXGYSWUKfZp5EV8oG4cSWSJXSCAq3OfY
         D0aZHP9RrRa8Cg0LEE1WedTshTJFVHr9u1kErlnsjnB7EHuHB//7MD2Lj4QoE3YPSTwd
         sYBSSsXFP9OjEWgVDu2F+CjCga1rwRq2c+HGrq5nEY8UsuOjhWcUlcnFGdwBSxlFyqtQ
         hq5edIQ4pg4pNRG9QiL3KfDKlNqpl/qetoWX9wcagLR6jlW0YAgt4D5zcW0RRt82kL3b
         ml4JGPhva27OpVnoHVWAmyS/BYt8+ehiXzBvF9lVJ+/9Z6dLC/tcKtxSHr9cRGTEmkuw
         rzVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=i2m6pNEp;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m184sor1142927pgm.36.2019.05.29.15.54.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 15:54:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=i2m6pNEp;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=jSKQLZwrhmnSigLvBb1y7bTu3QweUmRNvIXEtuAqha8=;
        b=i2m6pNEp//jAEdoVKlUepZrqCrxOeGMnhLpqIgwHYjCZuF1j3b+HZSW8SKuGwf1zDt
         0bhyfZQPgyaivPOywVbLs91S4hzEVqMfYIG3C5qkLNxgmWMxMkjSo7UKUzLzHVsKOgvb
         2r2aceu5kfodmmZkfuuAz0O4G4lZv5m/9XI0on/lp9xeE60SF9e+JH3tFD3v0ohkBZoV
         w+7veRU2N4ilJsskcWqJRw3UYj6ram4axcu3rhFFM6R8kQJtHkKuJlk17BYP4tYHHjY9
         Ye2nbDpDWlhbhMpO7j+4cMkzYkUwtNMixcy88LTT3FUX0DPvQNzrI/nWRZXRQqSH6+ix
         kraA==
X-Google-Smtp-Source: APXvYqwxpupc9N7njSo6f+msnHvsDLFKL5Sq7Tzn0RujPl74omIALXvHB2HQqQuQvOJWf8s9Yh/43Q==
X-Received: by 2002:a63:d157:: with SMTP id c23mr504819pgj.125.1559170471934;
        Wed, 29 May 2019 15:54:31 -0700 (PDT)
Received: from mylaptop.redhat.com ([2408:8207:782a:8650:1229:85cd:500a:f525])
        by smtp.gmail.com with ESMTPSA id e12sm690266pfl.122.2019.05.29.15.54.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 15:54:31 -0700 (PDT)
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
Subject: [PATCH] mm/gup: fix omission of check on FOLL_LONGTERM in get_user_pages_fast()
Date: Thu, 30 May 2019 06:54:04 +0800
Message-Id: <1559170444-3304-1-git-send-email-kernelfans@gmail.com>
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
 mm/gup.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/mm/gup.c b/mm/gup.c
index f173fcb..00feab3 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2235,6 +2235,18 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 		local_irq_enable();
 		ret = nr;
 	}
+#if defined(CONFIG_CMA)
+	if (unlikely(gup_flags & FOLL_LONGTERM)) {
+		int i, j;
+
+		for (i = 0; i < nr; i++)
+			if (is_migrate_cma_page(pages[i])) {
+				for (j = i; j < nr; j++)
+					put_page(pages[j]);
+				nr = i;
+			}
+	}
+#endif
 
 	if (nr < nr_pages) {
 		/* Try to get the remaining pages with get_user_pages */
-- 
2.7.5

