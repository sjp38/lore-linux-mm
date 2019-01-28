Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14570C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:18:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C74082148E
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:18:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="GhmAErRD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C74082148E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 542D78E0009; Mon, 28 Jan 2019 11:18:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F3E78E0001; Mon, 28 Jan 2019 11:18:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 394C68E0009; Mon, 28 Jan 2019 11:18:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id EACB98E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 11:18:47 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id i3so14450340pfj.4
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 08:18:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bq1sRvtLk1v32nBFQQNuIJuamhmFxw+bZzT679es4WU=;
        b=OPfjKJTPT1OIs8pKulU4Lgizz1mORqMVwAJp3o+erP16WgT9YdJfuQ8jQNkt5oUmjT
         XbqMOL9OZ0ys3hzawzx7Q40mY+tRLj1l9rcdY/bOjtLrR1fyV25yiSh6leKRyqcg4+Qv
         aYGIpt8W6nWCGJqqv6gHx/4zD7UFgQ/Qy2ewc71WKeMXRu6SPMtXgzmKrmI8LNJMSOo5
         3T2S2QoIbg2OGsaT+NmgtFOcjcZPlns+8i8iA/u/fV9cag8ISMCW9/GhJIeSMSv4XR5p
         /ENPsOyB8yYNvbEcQtpSwuVSxAjmCjpmbIkdqdzcWrrF4/x8n3vmRGfkRHNvTpmGpJbL
         dX0w==
X-Gm-Message-State: AJcUukevEGdc34YY3Xg9a2asde6SXr3jK4n7k3rIB0kuaBe7NVIcUjqv
	38y1PIETqwHs+lsLqzNli/nLdrUKtEqNc2VyYqDC7CP4dS53AKp4xcYKHVgp7hfWi/mtlJUsD01
	D7HBYKVGcoUREqexgsQ5HOA3FMOU1qwwvAWqHmqEmGA45g91dpLVt+ya7v9cJiIGOAA==
X-Received: by 2002:a63:2d2:: with SMTP id 201mr20347147pgc.14.1548692327562;
        Mon, 28 Jan 2019 08:18:47 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5uxBx+EixnkeXScijMLMa4cYbHyYyBNT31c0IsMktRpt7B85gOmZYQ1O1RvoDsxLTH2eE3
X-Received: by 2002:a63:2d2:: with SMTP id 201mr20347115pgc.14.1548692326954;
        Mon, 28 Jan 2019 08:18:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548692326; cv=none;
        d=google.com; s=arc-20160816;
        b=Mf59+meNnw3pUvLOm9w6SMTQK3k8BqpMOW+wfdTXHWPdytIzvfOhE2SBu4sBmAu4Ux
         Lq7puv01vN/Sl2XenqFrdS1RZRq0CLRLIhxFvL1aGMtUPtkrVBa4Izz65aDv7BJ5onus
         XmhphOWjoonQbVhRPh7KCBXySWMcZMOUNuAKqjnOtCEuWwj6LAnZ6RJR0iysrM3dYP5H
         wV0uBZDBA76w5JBnauM5fk65jqypcsWypMxkGKhV5danq39H02T69k9OrtEG7tmAMUJ0
         qfv0S7viP/tXDgWYEj5Kgj4XbGmxLhRM3zBISYA8pzsI1NSLLh+qz1HzU6aVymH4Zn8/
         FcuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=bq1sRvtLk1v32nBFQQNuIJuamhmFxw+bZzT679es4WU=;
        b=xmOhLWLqaCImqihHIfJHRzN7CZmPDzOlZcPG8HbzFN+fck4EvsmxOUfVuXESVsH2Uy
         8Ah9m5bYx6ekzqSO7+CiIdtTLYrB7xKJQjg0sz7TotvVK7hjj88HVcwCapTczgAGTyPn
         h7k4hdXEp5jjvvCq3iJtriDz/9Ol1mbBHbw5CiFIGj+UxEkr7vEJIeJqOukvvPOhvOyC
         NELSGK5ALCHufS+U55m8qGwHjtQK2prYoZ0e3cFlBbBkiSIDZhyoerxcX6Wgc8NfVVGm
         hPaHCEdlGLLqxx9Cc1ymFO6A9HgbNAUz2MTS1xeXyvVUD6efzA2/Bp2mH811rXgo9nTe
         LRWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=GhmAErRD;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d189si35328804pfa.70.2019.01.28.08.18.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 08:18:46 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=GhmAErRD;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 34DF42175B;
	Mon, 28 Jan 2019 16:18:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548692326;
	bh=S57QohYHsGAIlZI93+42YFU/Aqip7Ade/8Mz+dbvEyk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=GhmAErRDdisYJPKL+zcxdtx6IGjIzrolCWZfVOPzbh5GJ8TiDZwZxTmwxCyt/yE6s
	 WD4a/A48IYCQoxIJOavaaqUpVaKV+PD1x+euPTaj0cYDpdsVuM5+lFZ3MpQAwl2i9A
	 tyiNNP7ZmS2JShYvipZ3Hb6WZ/lHjIAWFwC4ypE8=
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
Subject: [PATCH AUTOSEL 4.14 153/170] mm/page_owner: clamp read count to PAGE_SIZE
Date: Mon, 28 Jan 2019 11:11:43 -0500
Message-Id: <20190128161200.55107-153-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190128161200.55107-1-sashal@kernel.org>
References: <20190128161200.55107-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190128161143.hTvA37PvAr9gsiK4O2RZaoNMvUMFvrZlir75lOTsUtw@z>

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
index a71fe4c623ef..7232c6e24234 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -351,6 +351,7 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 		.skip = 0
 	};
 
+	count = min_t(size_t, count, PAGE_SIZE);
 	kbuf = kmalloc(count, GFP_KERNEL);
 	if (!kbuf)
 		return -ENOMEM;
-- 
2.19.1

