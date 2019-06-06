Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54559C28D1E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 10:15:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEDC520866
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 10:15:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bIH+aH+V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEDC520866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 465C66B0006; Thu,  6 Jun 2019 06:15:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 416A56B000E; Thu,  6 Jun 2019 06:15:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B8D06B0010; Thu,  6 Jun 2019 06:15:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E6C646B0006
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 06:15:13 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id o184so1533516pfg.1
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 03:15:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=iNB/HCcaK/QRlIufduytfBFGZHFQaC2XGb/nKoC9fBo=;
        b=MfR3l3aQOeeo072VdDXMKq8zYzmLILnq8Qkl3xT72syqkDUluSEcQpme1vk1Jllq/e
         0JRUaBluadZEVPQLU1Z7yw2nSOSPilUwTNxi0Ip0Dr4yClWwLqpcgUlvbBJh2TulghDJ
         TBi+3cITR/RhuC2oIL7CPj6NfYEL2EMLz9AXo9Hz0jV5Os9P22Fz2UJTmugKfbcvjUHx
         y0Rf3XiJjkdnarEGKJdf1rsBpceP0VN9myMjTCQUHLXApLMxJMI+qQXxevpZPhCkPO64
         l74yQCy9fDcIEacsQLd9jUwF5sM+h+JVv741HsW4tmo9ssHpq+r/Jg/v68dNk41YkLM1
         AZKA==
X-Gm-Message-State: APjAAAXze3cCfFGnLPom+jZ+qhzk567skHkGgOpnUgAqbiO0TxzvNk0l
	XLoKZwCen+eSgwkncf2nLb8sM4ZEdqASqjf2c/uMIjAvey1N3tx5WMk17IRfwF8EsZv95Gha5o/
	iadIXqXe8lGKI39l5HFhdndRvYaF2xjVgCO3RQsgOXgovK35/vf5HsPMmdmwPfj119g==
X-Received: by 2002:aa7:8dd6:: with SMTP id j22mr54014827pfr.192.1559816113239;
        Thu, 06 Jun 2019 03:15:13 -0700 (PDT)
X-Received: by 2002:aa7:8dd6:: with SMTP id j22mr54014707pfr.192.1559816111966;
        Thu, 06 Jun 2019 03:15:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559816111; cv=none;
        d=google.com; s=arc-20160816;
        b=sCE++AJKMGjxrKbglkO0Nxzq9ew/bhgOk7/jjuv1s8M/S6eqNLpss0ESvtiBVJWCEa
         usmwrw5CJvO2QTUjGYay6EIvu3fIZmtDdYBVRp8dyZK4rhsSJqmGHY5vxeqWU/S2gy/6
         8s8V1lPeOu0/b9rlQBhSpZH/meefE+g2tpotqW7g3wcbxjt+8v+sWQrWlnHxqO32BM7y
         WQBAneOMQkB3TZ8k1yM+/pDzWb7o8Yd6XM+2rLg+67jrO+WQ+8pnrOoXmjLfG4Ux9WVr
         aSuiijo6JdU00oM57RZJlgB/NDAdBz2gR1eajbBwM56YlXfnbfzD2TZVsIwcZw4R+jr8
         rp3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=iNB/HCcaK/QRlIufduytfBFGZHFQaC2XGb/nKoC9fBo=;
        b=zJsTjnW42j5UrqamUIu5XO860wBHTY92zk5TmzEbIZ5RL8h6aYFrOgkKaQx/HPu/0q
         FlwoG5Xxib+t37D7II6va9/0mPzndIb5hzfF1r8Pc2vQ4iQw2Q77qDsHokj8em19MW/P
         9Xq/j7iuRgbw01CkzyB+0QIdtpGV5yiy/2LzHxCmr8R3eXZMiCRr5lVJqJsF52gKlwdY
         v163M3uNwZjOCxmxhwZ0TLDGcPcFb7wcj0j9+HVv8NiNo2MijxV/rcHOfLjLmdh5V3aH
         ddxEnn1KPqZXf+tFjRJyctQ2VPoRY6pyY8nDDnrkidjMgJ3hoN6cSmFHZo+h85YCfoYt
         ECwg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bIH+aH+V;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m4sor1225214pgs.14.2019.06.06.03.15.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 03:15:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bIH+aH+V;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=iNB/HCcaK/QRlIufduytfBFGZHFQaC2XGb/nKoC9fBo=;
        b=bIH+aH+VFCR22GiSmRRpw4RBZQcF7w3FKsJBBruhJJY/I+fF23genmo89PI6EG2Zkx
         d1RtkzUs5DahBzkK9nbGhfyXV1CzbYFOsU/WN48Ft+jBpr5cxM+LtLJYYCZNgdxpbH1l
         Pm65jbs4yIv5pxNuGGvFTG6FrUOEXcqJXP0F2o15L3/M+dOtRxk6wwOF3QW+Bzeeys0h
         pqV9H9zVWla31UyIu2ViYVaJO89bA7QM3yldafH0aA7UeVAyUjCzmOzwLqYpvId1Z8//
         58jsy02cUSgj9+CZz09gyWyGxhUbe4crP2E511ymDOzwBi11HD0+5WX83wmE+Rojo4O2
         xhEA==
X-Google-Smtp-Source: APXvYqyb1r4K726OPMfPWYxOJrSJ8VKM7YBay4BitGQ2BiXxuGVdzww5IwZspkRQjHns0N5phAqL6g==
X-Received: by 2002:a65:5003:: with SMTP id f3mr2631613pgo.336.1559816111409;
        Thu, 06 Jun 2019 03:15:11 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id z68sm1895829pfb.37.2019.06.06.03.15.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 03:15:10 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org,
	mhocko@suse.com,
	linux.bhar@gmail.com
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH v4 0/3] mm: improvements in shrink slab
Date: Thu,  6 Jun 2019 18:14:37 +0800
Message-Id: <1559816080-26405-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In the past few days, I found an issue in shrink slab.
We I was trying to fix it, I find there are something in shrink slab need
to be improved.

- #1 is to expose the min_slab_pages to help us analyze shrink slab.

- #2 is an code improvement.

- #3 is a fix to a issue. This issue is very easy to produce.
In the zone reclaim mode.
First you continuously cat a random non-exist file to produce
more and more dentry, then you read big file to produce page cache.
Finally you will find that the denty will never be shrunk.
In order to fix this issue, a new bitmask no_pagecache is introduce,
which is 0 by defalt.

Changes since v3:
A new bitmask no_pagecache is introduced in struct scan_control.

Yafang Shao (3):
  mm/vmstat: expose min_slab_pages in /proc/zoneinfo
  mm/vmscan: change return type of shrink_node() to void
  mm/vmscan: shrink slab in node reclaim

 mm/vmscan.c | 33 +++++++++++++++++++++++++++++----
 mm/vmstat.c |  8 ++++++++
 2 files changed, 37 insertions(+), 4 deletions(-)

-- 
1.8.3.1

