Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42809C7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 17:18:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC9AD2184B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 17:18:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC9AD2184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4093A6B000A; Thu, 18 Jul 2019 13:18:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B98A8E0003; Thu, 18 Jul 2019 13:18:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CF728E0001; Thu, 18 Jul 2019 13:18:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id ECE956B000A
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 13:18:13 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s21so14244127plr.2
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 10:18:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=pk/VGOauPVqB0xwGCpfvEG9ZRYSU2ZysHkbfdcq4ro8=;
        b=eX8WcIi2XFIBupaiqTRP2tgdf19CQuGSqF/htUFHcdmqkUAooz/v1h2JPuElQhMtrr
         YpaxfdgCobZMNJH2GAZVTRLm5lHP9dFPfVrVmL+bcVSTtFuZ/lzspFQQ1Uptb63TzYzU
         9krpfj1tI7ChHcX8bElSubYcBXEJxOJ1b4teTiRIR1T7xzUvPSVZj1pRubSq3C5d1qCT
         1lrCcNhsnRVqP9A9pL72GouT2xjEGePgJF1V+afrTK4nL5mptPy5JcUMMPOImZ5zvdGR
         FaDzcXQGY2782RHkKzyw8aY0tg0kGLyWM8dL0VhAmDDunGqgKfFy1hANKFS6FvFGxuWI
         V3lA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUzIwEUnkGbyeAGOzQuk51XEy1MZfh3Z2U3iVcbIdDE1eFhX0jx
	o49sbvY4xALrxzSHAgHd875YnH/Y3nf1kA+Vt2gZir1cA4Nuyoh9lD/7rSDZr+204Hq7QXDFrIy
	DF7mBHQJYk/u1CJoccOY//ORMngRLZ+KZUHw2OFGS+FkpxFMIq1hUmvR34U1AEUX1Ow==
X-Received: by 2002:a17:902:bd06:: with SMTP id p6mr52675831pls.189.1563470293484;
        Thu, 18 Jul 2019 10:18:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsekTg4v9pW67ymXwXvwfuydHt8gYxX2r+fa7Fol9UNLbPock/7HgR7mJhMjJih9gu/5Z9
X-Received: by 2002:a17:902:bd06:: with SMTP id p6mr52675770pls.189.1563470292646;
        Thu, 18 Jul 2019 10:18:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563470292; cv=none;
        d=google.com; s=arc-20160816;
        b=u8M1sLPYvOTbLbLzNgDfDOMUDGVhYDsZqX7sh/YjjhS3CCB256KqHfthdanGrHCtva
         8YcVZv1183g627VB67b9f7mBB3/qi4zxjsi9J7fsT/UuMe65RkvjGgiMKVYTRSWlWjed
         6eLr+8qu1tWzYEIRtWH1SsUPHrVBEwfUUU55tA3LqCsjx+qyS+xs5ke4A4kAsRlKpWrI
         EnMUQFfx04MiXsNNcFw4+PgPPSKXh9KnUfAyRgg8yNhLypxohR8HTc8vyTvvpHrAFut3
         ifPVw4SGXSitiW/tWdSv2P3O4UKJRwhQPErNCPP74r9+DN1ApExlKeKXsNqSHksOGqyl
         pQbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=pk/VGOauPVqB0xwGCpfvEG9ZRYSU2ZysHkbfdcq4ro8=;
        b=b15AfjUlXFLjTOnoUvuoJZHyqhZbRAPXmFQcw3LXdo1tBSmZlUvffuQxBYjKqnOO1I
         s0n4caLsNj7HhjWQyVvKPOFgw8ZOrLeRQGweJqOBLW3yg/w6UAHIrS7VLhV4doWKaAQ9
         T3eqUynrOVaIc2+wlxJvQJcVwtU3m2PmWV7x0bor0vfb88YWBxs1p1cr8ThplMI35jNK
         0MFEK3rYKLTmBN5M1B9lqD8jh9HX6BI/o1kbUjvw+HTeyQkCAGwRTxAK2ZBTaJoLj6qy
         OsCrmSKhQKuxDL+tBb676Hje5kOIeew/SIJ5Afd7Y2lPbLZQ/s1NEi4Ym/fGYP6BoUum
         fTuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id v1si2784598plp.264.2019.07.18.10.18.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 10:18:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) client-ip=115.124.30.56;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R891e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TXDOr4u_1563470282;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TXDOr4u_1563470282)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 19 Jul 2019 01:18:09 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: vbabka@suse.cz,
	mhocko@kernel.org,
	mgorman@techsingularity.net,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org
Subject: [v3 PATCH 0/2] mm: mempolicy: fix mbind()'s inconsistent behavior for unmovable pages
Date: Fri, 19 Jul 2019 01:17:52 +0800
Message-Id: <1563470274-52126-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Changelog
v3: * Adopted the suggestions from Vastimil.  Saved another 20 lines.
      Using flag in struct queue_pages looks not outperform renumbering retval
      too much since we still have to return 1 to tell the caller there are
      unmovable pages.  So just renumber the retval.
    * Manpage is not very clear about shared pages when MPOL_MF_MOVE is
      specified, just leave it as it is for now till it gets clarified.
v2: * Fixed the inconsistent behavior by not aborting !vma_migratable()
      immediately by a separate patch (patch 1/2), and this is also the
      preparation for patch 2/2. For the details please see the commit
      log.  Per Vlastimil.
    * Not abort immediately if unmovable page is met. This should handle
      non-LRU movable pages and temporary off-LRU pages more friendly.
      Per Vlastimil and Michal Hocko.


Yang Shi (2):
      mm: mempolicy: make the behavior consistent when MPOL_MF_MOVE* and MPOL_MF_STRICT were specified
      mm: mempolicy: handle vma with unmovable pages mapped correctly in mbind

 mm/mempolicy.c | 100 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 74 insertions(+), 26 deletions(-)

