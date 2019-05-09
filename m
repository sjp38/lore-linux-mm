Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BD0EC04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 08:08:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC60F216C4
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 08:08:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bA0qFJhQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC60F216C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05F346B0006; Thu,  9 May 2019 04:08:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00FFC6B0007; Thu,  9 May 2019 04:08:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E40B66B0008; Thu,  9 May 2019 04:08:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id AB5A36B0006
	for <linux-mm@kvack.org>; Thu,  9 May 2019 04:08:05 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z7so1164959pgc.1
        for <linux-mm@kvack.org>; Thu, 09 May 2019 01:08:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=H6pwDfurTwvymXFL+GjiNLQ/ZlmPmWdTfSv7esEAkNY=;
        b=V87nYxV322u8mEMtpGNrL5+t+OOcAeI0B4HAQzXELmc7K4+6SliMdx41949QbdCUpF
         Ht9BoXqRov0JFQ3GFkxUek/F6c5R9JGs21476GRxpYEEZdyiPGGjWblINccb33V+Wd+u
         h/etYkYmaUEd1T5egwp5QiUcD+k6+ZXbtQGPrJToQWkG8vPDrPh92cWvFJPEdXftdgKh
         mgGAMv9Em62bL5VYnpnXUuOagJDQHZ84oi0h2fH31i0FviwBqMHxLdmJ17y1FbuRkAH7
         igu14BdOnMLYSKqCa1lOunXQeNuGH38s6EAssVxTe5i1mrAjluKQFB9TWVW+nELb5xKw
         WyqA==
X-Gm-Message-State: APjAAAXSkibDOnrdUk5M+Hn5ZgnZ5hzC3gk/+eQJpH7rDE/69B0mp8Ai
	KlwgXtV3QbVaFRM09cUiK3B2eu5276HjpEqxi0PbYieuWSqV6R0ksy0yUazk7hq88teZqHcYa+3
	3Mggqel7bdGjukm4L3HPHJNCGpmf/p7gF1TO34EcPVt3BRISkBtJraVb2JoPR/l4oEg==
X-Received: by 2002:a17:902:302:: with SMTP id 2mr3288440pld.232.1557389285303;
        Thu, 09 May 2019 01:08:05 -0700 (PDT)
X-Received: by 2002:a17:902:302:: with SMTP id 2mr3288357pld.232.1557389284307;
        Thu, 09 May 2019 01:08:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557389284; cv=none;
        d=google.com; s=arc-20160816;
        b=CK5jKQ7ucQsMl2t72nOYU0XuhDoXmeiQs/bWTttWXj8brEelEf0eyWJFsu71QWRN12
         tb0M89iHsbhtm8mbySaKakwE2XNrEEZIlZ5lwSJrPh/pwhkf67qX7B/USl6TtSIlSaNv
         +NISgVqYUcsTFQlSEVAQ4JD9JrciU/pvbZMTiFG58FrgGol03sgvBUAgK7dEGqrQwbqH
         lnFnQezzBcWffZ0VE8Qg99BG92a7cYYBB2hqsueqQAW/L1kUby8ePsBa5aNL8KFR2Jkg
         69DndtV1bP189qm6zwtl3iN1OjCRilYuEwuV0baq0gG4qZpJ4cXy8timaB9Y9ao3NWU1
         i83A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=H6pwDfurTwvymXFL+GjiNLQ/ZlmPmWdTfSv7esEAkNY=;
        b=fKTdDYoXT0gdiZ4V5tvZsGmmDHAljsHyexBW9jCT5BKgCAsuOFBSV2/4A3yAcYdVlh
         tdpSqnpieIYrj30guIG0UpUxr43x63Y9/fB9ABEdJV5i5gWUlLl+N1qHlam8CWGjpoUr
         XJC++3e3s5xdwvud0aym++mfvk6EKQWBZ08kAM5cK6UCzgxQ9D/dWY2wpXFu6j9vtxko
         yzI50Ky51kpDOlhzrJrZyGRObSDdaRhx0l58Hf1l2p2xeq37sujhD5qgKCWG58CD4jTI
         3pb4cdfdQoWydT7gc7KUWqwPiKTz1Q6V8/gZvQ7O1CBMKPsPMveTWPX7BX3B5tZyCsBt
         U62A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bA0qFJhQ;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c13sor1790921pfm.33.2019.05.09.01.08.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 May 2019 01:08:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bA0qFJhQ;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=H6pwDfurTwvymXFL+GjiNLQ/ZlmPmWdTfSv7esEAkNY=;
        b=bA0qFJhQKRl5jKpJ2Zy/A310jSNANtgHJumZzv3BjUmmIzMJFsCjAgVFvq2W9JIQbe
         hzLCEcg2NUZoeE0JXqNclJeubBxQE0/nNWXLld7fCK9xfueGVILIcagCNZ2b023VvPTy
         RzUo4EGBGtaqSP8Cc5nBi0RanWSR4oOR2BjxBz50CfHCCdkqIr8VKRReGwWUGcB74F5/
         4rkB4v1upv702fGDLgI42cOojs07DGZkZ1Hzy7O10UYhVpvaOxlvbhXytrWL6kEpTjSk
         25c9+yQE9PjcFMU9Cac1b51yIRaC8nWJt2MfOAluvIUse9yNXltuF87YmEDnoUkSFsRH
         qfRA==
X-Google-Smtp-Source: APXvYqyOem3fIt47qokFydBDWrDUILZ9SZDb6yMRFMeU5NG3cpeU6HXB1BRzecjf9ThTNjYaoq8hjg==
X-Received: by 2002:a62:56d9:: with SMTP id h86mr3198371pfj.195.1557389284019;
        Thu, 09 May 2019 01:08:04 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id d186sm1620900pgc.58.2019.05.09.01.08.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 01:08:02 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: mhocko@suse.com,
	akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH 1/2] mm/vmstat: expose min_slab_pages in /proc/zoneinfo
Date: Thu,  9 May 2019 16:07:48 +0800
Message-Id: <1557389269-31315-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On one of our servers, we find the dentry is continuously growing
without shrinking. We're not sure whether that is because reclaimable
slab is still less than min_slab_pages.
So if we expose min_slab_pages, it would be easy to compare.

As we can set min_slab_ratio with sysctl, we should expose the effective
min_slab_pages to user as well.

That is same with min_unmapped_pages.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/vmstat.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index a7d4933..bb76cfe 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1549,7 +1549,15 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 				NR_VM_NUMA_STAT_ITEMS],
 				node_page_state(pgdat, i));
 		}
+
+#ifdef CONFIG_NUMA
+		seq_printf(m, "\n      %-12s %lu", "min_slab",
+			   pgdat->min_slab_pages);
+		seq_printf(m, "\n      %-12s %lu", "min_unmapped",
+			   pgdat->min_unmapped_pages);
+#endif
 	}
+
 	seq_printf(m,
 		   "\n  pages free     %lu"
 		   "\n        min      %lu"
-- 
1.8.3.1

