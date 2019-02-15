Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27251C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:14:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D27562192C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:14:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="a1C9++zg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D27562192C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7772C8E0005; Fri, 15 Feb 2019 13:14:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D17F8E0004; Fri, 15 Feb 2019 13:14:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C5988E0005; Fri, 15 Feb 2019 13:14:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2EF818E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 13:14:34 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id m17so6322566ybk.21
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 10:14:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=5+WUd014/LJCShtLmJFavi/k6g9qeRBc8qLTGaKJAsU=;
        b=IW2qz0AV2A79RUK27T/ZDDGPubC+mgV38Sa7XzXcYCktpzSFIz4VH15/TtF1nwYeMa
         pJW6UkrK3fokT5K+CzMyBr7V8nv0R7T83FTDB2HYXcd6Rio9NFA8dDToyaaXuw+uKkeo
         wMb/qpy2Q9Q1Mzo+08bTDAmRqtJAO/bseKh1fOiDsnN0Fat0EOUwnnVV3i4XrVmRqoFZ
         7YLOjS+TzYT9Cp79ZnaencABwiEGIvWg9BeyVUTU/MhnvmyBPRTUkEHKH4vq6VCqacXS
         M45pvT6/QzDQF/vnatjg2mGD7Vrx9P6EfEa2E97my63herkbRKHmAJilm957uCodhF6K
         yljA==
X-Gm-Message-State: AHQUAuZGOrm4jUXWLFEyl/PR4IYqy/KusrWN1zlM5y41lF5mrFD7kI8q
	UWDG6cLOA5zTzTiMgbd/JsN2l6FQMS45xK7PH+pUtA1uIQ0DzYoeoVIR0SzV/hhPmPRhxWjqLlj
	ei4ISoJ8t3TFpLlSZPZrxUv8nvsQV3+3SoXcpzNf3iJTd/j+FXJ3TUo7Ktr+29fE8E0Egb8yPKk
	RsZXRogoBJRjfnF+k3whCLcyY/yZhB+taVI8nQUp37y+cjMGIFJC9yUldUvDB92fV5/PGW0arsk
	Pu0dC+c3qvu+tjjPRCQifey46RrFKEr/uH4J1lZf4lRbFl+ukGEWuR9OjwV51iX7cYGTR3i0rjO
	/IH9JqDmGQ3Peivs8AOV6Rpq5wpA5Ips6L1L+uvPF+JkNjU2HDG9/2YcnrHFhrZxstZV+R3X5vI
	h
X-Received: by 2002:a25:3885:: with SMTP id f127mr9202665yba.10.1550254473886;
        Fri, 15 Feb 2019 10:14:33 -0800 (PST)
X-Received: by 2002:a25:3885:: with SMTP id f127mr9202565yba.10.1550254472457;
        Fri, 15 Feb 2019 10:14:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550254472; cv=none;
        d=google.com; s=arc-20160816;
        b=bwhwBSOCMnbtxgB0hq9UiLGSldVtsd6leI/J9mziFhf7+zVB9VfwQ10nFOopQSFpzi
         y04jY8BbGU0gBUX4WEwf89mjP6xrSUbLTHHdt0iDpSPVyIVOYWoRu1Zgx2XjA+8yfcVa
         prpFbR8BrPeUGj/ChqOoLEL0hkgh2UdGmIW7ImBsrmlJLC4nJdxVzVvZwSgR7LAu0Ygg
         2Jk/EybTKDmkLjQNim4LwmxhxMCbxeNjwlJn7uwEo3pRYuM1gi2LNi5xb1eLcM38jRcK
         4l8LDxQk2Vd2LXelVkOb4vl2ON9agkmiKR1KMJqFugVT7etMi7UY2pFXtdmpIst2mciq
         o4hA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=5+WUd014/LJCShtLmJFavi/k6g9qeRBc8qLTGaKJAsU=;
        b=nOebUUrj4n8GdSB6Eon71DM8x5WBeaYmYT1ccLvhCMbv5TW76jefQ6IDR9FR4xZzjQ
         j04f63leMs4pIQ9RliSlUAJ1fhyLw6vx52vDBWOPFvcIntx9L6zgb3j3gGwrO2/DKc4O
         rER5dY8WqzmWww0Jl07zt5GBkYFPCpABBZ6+HnQeGPwJ+neDuyMUvT2ZYKdvXZ84lHwJ
         tYH4FSvm/WQQO7dDcJdnbIMc2LMJjp8w81z6do4DRgjuQkyZTKKktql5Xh12CuaS1UEi
         02JhAV7H7pG4ypzTmwBKI/np7e1vwNji/ydPFr8De1t4cr3mek9gwtIesFrco+n6V1oK
         RjSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=a1C9++zg;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h125sor907467ywf.156.2019.02.15.10.14.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Feb 2019 10:14:29 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=a1C9++zg;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=5+WUd014/LJCShtLmJFavi/k6g9qeRBc8qLTGaKJAsU=;
        b=a1C9++zg/8Xow9jJtcRPER7lqOqA1xZ/VEeGI/x4i7V07mc76UEu2txWrBTwYlTQMy
         MA4EPF8kN5QqA4OQPMrTu66ZhOhde/Am0GRS65q3N7EfRFRR3z9diBn5LH9IyH5nhRs7
         NhxjLvYwGbKfpiWvzrCAHAm+m0Y5MWauAir24VuIFJ9x5/8tvpt0MVvrfGhbcXgv8oCM
         DZEQPzM3qwpCm9lAClj4TwtskFXajON48W/UdXwVEwvxP1/EBdu6+w5goqmM/Tot222V
         oX9iJIgWFQqsbayx0Buib7Jj52TL/tiGTi+NI78UPh4sqvBBXCfgSQ1KDVj/Z0Ok3WP7
         6gmQ==
X-Google-Smtp-Source: AHgI3IYTX5lnhvZHQEN+YihHwwia31uJ3zDJzj3kiVMLj9iTKxSvAREKWHdagDlzSpi65TjvKxg+gw==
X-Received: by 2002:a81:5a86:: with SMTP id o128mr8612249ywb.205.1550254469589;
        Fri, 15 Feb 2019 10:14:29 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::4:33c1])
        by smtp.gmail.com with ESMTPSA id 82sm2214565ywq.97.2019.02.15.10.14.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Feb 2019 10:14:28 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 0/6] mm: memcontrol: clean up the LRU counts tracking
Date: Fri, 15 Feb 2019 13:14:19 -0500
Message-Id: <20190215181425.32624-1-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The memcg LRU stats usage is currently a bit messy. Memcg has private
per-zone counters because reclaim needs zone granularity sometimes,
but we also have plenty of users that need to awkwardly sum them up to
node or memcg granularity. Meanwhile the canonical per-memcg vmstats
do not track the LRU counts (NR_INACTIVE_ANON etc.) as you'd expect.

This series enables LRU count tracking in the per-memcg vmstats array
such that lruvec_page_state() and memcg_page_state() work on the enum
node_stat_item items for the LRU counters. Then it converts all the
callers that don't specifically need per-zone numbers over to that.

 include/linux/memcontrol.h | 28 ---------------
 include/linux/mm_inline.h  |  2 +-
 include/linux/mmzone.h     |  5 ---
 mm/memcontrol.c            | 85 +++++++++++++++++++++++++-------------------
 mm/vmscan.c                |  2 +-
 mm/workingset.c            |  5 +--
 6 files changed, 54 insertions(+), 73 deletions(-)


