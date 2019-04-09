Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D5FDC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 13:14:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D60AF2084C
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 13:14:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="INWDeH/L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D60AF2084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E48C6B0008; Tue,  9 Apr 2019 09:14:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4938B6B000D; Tue,  9 Apr 2019 09:14:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 383336B000E; Tue,  9 Apr 2019 09:14:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id F2E656B0008
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 09:13:59 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id v16so12974111pfn.11
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 06:13:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=DQCNVkZnpAZMvXUmJjlw/ftEg86rC+ek0DCgVmjTv7Y=;
        b=AKlAUR0xasaJD8IFu6H+FgWzwe3K4fl8p/4jxzQkCcivJs8QTa6AEYNpknYP60Htjg
         TaiQ8BgJZyvIY4groo5Ef5q9DAv4OphiDQZsUEhXkbtqRQpbkty5Gs5OIrB0ZYjlpbrn
         hhIaB4EZQq++0C8IfCURlomue3YnnpIiJCIrCmeL45KdgZrlt+eAmcRj1ezMfLtRkhOo
         BB1gMdeXGcTRzBQk2nNE4g1LK+tzb4SBopWckU2mKGU7It3Ai2p9usQmq8p6Wquo+eOR
         ebsN/N07hxX50He9U7eKzvIDs3WT6wzb0MfJbXs9h3EgQPACQC0kkHKriItpIYSvTwwr
         7XPA==
X-Gm-Message-State: APjAAAWUXyfTlk5xyFxfUPofYD77f/aYHPgVDhCuxlKU/p6G2bmRrwAE
	YLGH05XsRW6poBp6WpV1tf/62OkV8TavNfvC2mDCSS+Yn7b3sbPB/GgTLW1D3rlzSc6frjlBe8P
	WYLSOeLwz/aOTL6kq5ab51ADMZSZHdtu1RcJMoS3re6rf12DGn2dA14iYBXVNoCs+8A==
X-Received: by 2002:a17:902:1c9:: with SMTP id b67mr15603075plb.158.1554815639480;
        Tue, 09 Apr 2019 06:13:59 -0700 (PDT)
X-Received: by 2002:a17:902:1c9:: with SMTP id b67mr15602859plb.158.1554815637093;
        Tue, 09 Apr 2019 06:13:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554815637; cv=none;
        d=google.com; s=arc-20160816;
        b=qr1GuVNM6Mu4vG9yJsHmpm1Udd+OvXciunstmhcKoCfZF1GeSkWwqSVFJ5lUN8A1j3
         PPrp8IBDVNniAHDK62ZDWtNfw3BnhJQfdj3eeDzx+ozaEvXEVOmIghsJZE3ioI3HwVzT
         Jn8Oy8rG0sw8dIqEFUNEX1k5MDEMpwg7UxNSqctwXfrOASfmqTnig8MMMns8oGhhPS2P
         v/0/8FOHIvVPZVl4AkVLG+xtoulfWWi/scMSZMWFuKp3FQXn8RvBMVdPL5yITzNS+vP6
         J7olOzW94gTa+B0+L4+ufhLGoba23Se5Q9E33hHS1LLOPJOca8KtK/1UvMD96Q3vdxU/
         5cUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=DQCNVkZnpAZMvXUmJjlw/ftEg86rC+ek0DCgVmjTv7Y=;
        b=ZOcBJDXskQgr+BHQtWsR7/hZnVegcdqBp8J9pwtB9i33k2iaIgnmtk0dsHlNnnvVqR
         o/rFMsgI+YxnBa0g/o7ok6rX9BueusYYvRrjIofSSZsTujqtcPfhzPWRYZf1vodW0KnX
         gtj+ooEokfrLf4rYsnOu9ACvTaBtnEE8mcJP/a0+Bx5rWzxkh4tyMAWQXqqO/nMsSrBe
         sB30dZpdifse1GSOcg9j4ZQqXZMg5m4zUzU7sucNOhQ8k21oMLvoLQCgF+vsUy1+/Fc3
         W6iA6J2feHj/cBCtMQrkUWTW+tI8Ah+/isL+QX2YN/xusZ8nu7CeX7L0DLPwh367mRHc
         vNOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="INWDeH/L";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i2sor35138724pgq.75.2019.04.09.06.13.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Apr 2019 06:13:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="INWDeH/L";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=DQCNVkZnpAZMvXUmJjlw/ftEg86rC+ek0DCgVmjTv7Y=;
        b=INWDeH/Lez3wsxZEC00Y56c1jTYeIg2ZQuhwVh8ezwiyKopUvkpU5Xb/XHP60xUvO5
         i+XAnVZT6TixkRNyp1JYXvdYkMSIIhHe8cqYtCCE3MLd8K1BrG1M7orv3+KWXPHQ6UhU
         6ktcplWgowCbHieFzxyA19/G4+Vs7hyPaPQq4X/OQygL9BfAnzkZIUySH5v9SPbuz+Ba
         r4VcsIjlryUczE3C19a4QKlu8govbjFgvbJJrqa2fk86Hf85CaspVq6uPRgz5n8/KATC
         9PX7xHaAKEXPjsONuP8L8qmrjtzLJFe2/Z3aefcIid/qQtAJyr5dSSXTcGRV1/bwdWon
         P2Zw==
X-Google-Smtp-Source: APXvYqxgQrotADDr9qgGRCS/57/NB3idLhn852Nc7yrw1r2zIfl5VidEiOcI+rjUw66YP4YPlzNPqg==
X-Received: by 2002:a65:6545:: with SMTP id a5mr23778231pgw.264.1554815636708;
        Tue, 09 Apr 2019 06:13:56 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id p17sm43405490pfn.157.2019.04.09.06.13.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 06:13:55 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: hannes@cmpxchg.org,
	mhocko@kernel.org,
	vdavydov.dev@gmail.com
Cc: akpm@linux-foundation.org,
	cgroups@vger.kernel.org,
	linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm/memcontrol: split pgscan into direct and kswapd for memcg
Date: Tue,  9 Apr 2019 21:13:43 +0800
Message-Id: <1554815623-9353-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Now we count PGSCAN_KSWAPD and PGSCAN_DIRECT into one single item
'pgscan', that's not proper.

PGSCAN_DIRECT is triggered by the tasks in this memcg, which directly
indicates the memory status of this memcg;
while PGSCAN_KSWAPD is triggered by the kswapd(which always reflects the
system level memory status) and it happens to scan the pages in this
memcg.

So we should better split 'pgscan' into 'pgscan_direct' and
'pgscan_kswapd'.

BTW, softlimit reclaim will never happen in cgroup v2.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/memcontrol.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 10af4dd..abd17f8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5635,8 +5635,8 @@ static int memory_stat_show(struct seq_file *m, void *v)
 		   acc.vmstats[WORKINGSET_NODERECLAIM]);
 
 	seq_printf(m, "pgrefill %lu\n", acc.vmevents[PGREFILL]);
-	seq_printf(m, "pgscan %lu\n", acc.vmevents[PGSCAN_KSWAPD] +
-		   acc.vmevents[PGSCAN_DIRECT]);
+	seq_printf(m, "pgscan_direct %lu\n", acc.vmevents[PGSCAN_DIRECT]);
+	seq_printf(m, "pgscan_kswapd %lu\n", acc.vmevents[PGSCAN_KSWAPD]);
 	seq_printf(m, "pgsteal %lu\n", acc.vmevents[PGSTEAL_KSWAPD] +
 		   acc.vmevents[PGSTEAL_DIRECT]);
 	seq_printf(m, "pgactivate %lu\n", acc.vmevents[PGACTIVATE]);
-- 
1.8.3.1

