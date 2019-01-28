Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77679C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:23:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 355DB2171F
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:23:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Php/GzsF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 355DB2171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF66F8E0008; Mon, 28 Jan 2019 11:23:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA5FC8E0001; Mon, 28 Jan 2019 11:23:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A96468E0008; Mon, 28 Jan 2019 11:23:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6898E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 11:23:38 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id p9so14440331pfj.3
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 08:23:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=4R25XwSO7CtAnUxmQcg9pX95148svhslnyKIkJP43+Y=;
        b=I94+QwwyNQklg4D7m5BdiHYzMMQx+QJAtBA3lT6Wblz808oStqasnqXHcT/m/KV/Iz
         Qn1j6GmLbWHap8D0qRIpbaK33wfHgw5W+J5z7J8i1OpG3ebRN2PTzDiRKYuZJvx4GO7Q
         eVJ9Lq8A+bayMVP9uNb7ojajNQ7olvnzHcXuUTg89YK2Mxw7PvfbavDg/AHPEabC+Jm9
         9NEnapqZoVjafqMZQhRM72+U+lXNscJvq6gS5p8n87uI0NsFFFhKrnypx7NzfIXvGF9/
         0wh9/29vuLe040UmKkBVE4IpQq5llBomOJs/1ZPo2mNRNWvU6yWDZUIGVB9KmbDx3ttJ
         yaag==
X-Gm-Message-State: AJcUukdKtbmu+t9mCytVs29dq82O4hchZ5ISWPSJ1OAeTI+1P34QiLiw
	5FAOdpGkVw5jU2/JS8kO630DnqKPaBgIVT2C5sjPMl0R6EbVNU9BhfrJPd0b2qxbPs/Kx3sLpMm
	LYgebea6E1gkF+aWQlkLO3eq5qY+XwDN6tbLELu/AySf+Xy27P98Gol40kdXejzSJnw==
X-Received: by 2002:a63:e21:: with SMTP id d33mr20338068pgl.272.1548692618128;
        Mon, 28 Jan 2019 08:23:38 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5k7P+DjlJ9utJEZzA9/msXUKwrbFxeYmaMBsv9BURGV/dLcFaxQ6dVkinBuZPdGx5yS7J2
X-Received: by 2002:a63:e21:: with SMTP id d33mr20338042pgl.272.1548692617554;
        Mon, 28 Jan 2019 08:23:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548692617; cv=none;
        d=google.com; s=arc-20160816;
        b=Frrbx3pZARe3keAKM8f5L5+XGB69pZe0kjvSO5EjP8JHqiOxvufcDMAc7SzTnAAdfd
         zaR/9wGevLuWKph45XiZpn63o0w+XoAgbBc67NyZkNHrvCDcgytpKhjSm7y95ALRzaxi
         MVxM6OBBvJdcNyeWX078QV2Uv0n+LdiJ/DBGhMiGXlO6RO7r8mEkyVvVz7PRqII6Qewp
         BAoUwKAfLhTkROICdmEGrTxOuV7ZwydUx+Uwk7B9//LScdwVZJMGU6R1BFwf+m1Y4Jy6
         8CqK/J9BWnKW1ogkaJY7VqK0CBd+OrSpTo9YlW9o6yrdp1VNIXg/un4yTQMQIJuh37Tb
         +JWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=4R25XwSO7CtAnUxmQcg9pX95148svhslnyKIkJP43+Y=;
        b=o/6o/6wiLKOuMe1v/EF/O05mD4JXo93RxMSLReng3SLUALWkm7JEiVc/ADwJb7RuEz
         X1aggwUXKHjK3zBILP7HsyBGC7G6zyj36uxdFsylz+z7MA/QIwuiminfY8h/fOum34lo
         GmNRCNuZ7tQBwWyMTgdoaqF4/vXjXxD4hItV1QC6fQNc3r64giJBd8Ql0WJXjFbmTuib
         aXlNbzUMPOx5j+T5ddd/vjkkntqmg+9eX4OvH14InSzHjWBE94WjcuX1Gu0/bFMAViPa
         Ji8GLqPQepPn0aFt8/uHMtSm8eeqCkPGHNacr52417sdSAWAmbsWnNdBFD9Q95V2Q1qk
         xBMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="Php/GzsF";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i189si33951708pfg.265.2019.01.28.08.23.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 08:23:37 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="Php/GzsF";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2B5D32084A;
	Mon, 28 Jan 2019 16:23:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548692617;
	bh=UDb8Jhwvr7eVHJPSNm2zCvrpRoX2M+DIKCDTmJCDcxE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Php/GzsFV99i0V7MjJ6/0/y8ePSgj4G6PZ6g/Vr7hWhrf0TlEs83uKsNJXvOx1vVL
	 1kAqtXVcUneaB01lyqS7n2qiG8ykpKCpTMjZYEbXJzUlyqCGIqUSVXmwkVmsVW+Q17
	 8tZC1kvRRVX4Nm1MzKPQ7NEYeYDYIUkLoxfp6wvc=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Miles Chen <miles.chen@mediatek.com>,
	Joe Perches <joe@perches.com>,
	Matthew Wilcox <willy@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.9 095/107] mm/page_owner: clamp read count to PAGE_SIZE
Date: Mon, 28 Jan 2019 11:19:35 -0500
Message-Id: <20190128161947.57405-95-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190128161947.57405-1-sashal@kernel.org>
References: <20190128161947.57405-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190128161935.7W3GhEg304qX4lqX8pK9uJS8KPFUNN0UlTjLsilfcjY@z>

From: Miles Chen <miles.chen@mediatek.com>

[ Upstream commit c8f61cfc871fadfb73ad3eacd64fda457279e911 ]

The (root-only) page owner read might allocate a large size of memory with
a large read count.  Allocation fails can easily occur when doing high
order allocations.

Clamp buffer size to PAGE_SIZE to avoid arbitrary size allocation
and avoid allocation fails due to high order allocation.

[akpm@linux-foundation.org: use min_t()]
Link: http://lkml.kernel.org/r/1541091607-27402-1-git-send-email-miles.chen@mediatek.com
Signed-off-by: Miles Chen <miles.chen@mediatek.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Joe Perches <joe@perches.com>
Cc: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/page_owner.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index 60634dc53a88..f3e527d95ab6 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -334,6 +334,7 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 		.skip = 0
 	};
 
+	count = min_t(size_t, count, PAGE_SIZE);
 	kbuf = kmalloc(count, GFP_KERNEL);
 	if (!kbuf)
 		return -ENOMEM;
-- 
2.19.1

