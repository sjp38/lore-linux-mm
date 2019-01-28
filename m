Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9965C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:07:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 978EC2171F
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:07:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="qzdgx7D4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 978EC2171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B58D8E0007; Mon, 28 Jan 2019 11:07:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23D148E0001; Mon, 28 Jan 2019 11:07:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10F748E0007; Mon, 28 Jan 2019 11:07:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C1EF38E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 11:07:51 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id a10so12113155plp.14
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 08:07:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TBgzcU+QM8oQkU+TUSLXH1qqIRWFo/d97fxNJnnwyPY=;
        b=eqYvZSG3dYCIYt59pkQ7L1mqHB64DuRppTGo1V5/P//dP2ODWlieFoEB7cNTs1ppsm
         7pwJXKfoEFCj5axd9LfT7UgpAKyP+a8o8hN2YfdVyY0YrE8EEFCPxhKOXK/wE8iXUHBh
         2S+B6u/Drq4q8oJSTl3Ns9nI7BottxnAJ5AN1baM41v3yrVCt5Q9ajsbc1PDpP0vztfV
         NuOV74aQPw/dgjKXUws+5f3hEb356SccnxFVJfmPegz85UszQRljaT5IsMS8zCNzqDX3
         nU9rB3qHkgppHGwvuToWXt48SP4t9brvsLakFnfxqzqKIsvZt2w2zTVIMTWeqXTxOVYJ
         soEA==
X-Gm-Message-State: AJcUukdpHVyx+RDio598I2I3jqrXc5vUf/2QXYUra+uRj9B92iH89nSH
	5+jXkY1qKCTmZpZjmdXwNjSLBP3OI5pqoV/G3v126bC4ueLARDWlVjGkz7KIuZQnXM66yoqYOms
	G3AitiOu91cNb76sKquBb+RbFh5Qidy7Spw0cRPF5Uo3KIwlUojiZtS7U1cKZH52WHA==
X-Received: by 2002:a63:9b11:: with SMTP id r17mr20499645pgd.416.1548691671465;
        Mon, 28 Jan 2019 08:07:51 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7v188OdCc8oUuuD6+1GIZ97/aY4b8GFa2Bg+1+SjybufnwWR4DbqkQ1avWY3uH88PSeXor
X-Received: by 2002:a63:9b11:: with SMTP id r17mr20499603pgd.416.1548691670809;
        Mon, 28 Jan 2019 08:07:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548691670; cv=none;
        d=google.com; s=arc-20160816;
        b=jLcAQrv7EsYH/5Wv5j97E8fHBjSbrR/F2Eg/FBFm9HnIVPVeFDsZ/aM3F8eprNrUq+
         0uQCZd78rzM1iWZZAZz05Nu6m7cA4ZQbv8PHqGa6iFfhSxtpJtfNSq0xfXWsF6ak4FS6
         TCKGeK4B+Os0NylWoBD4b15gRpqohzoWN1xxUSjBfpXWnupjwrkykYweAGn8lT3emws+
         DnWiOYMXp0Tnzou2LRYuwQJ7yxD3sKDEnfhhQnwSpm6PMLzBP6A7b/ck9bA/0A6Am1Od
         1i71pd3/6Yigjf9cURSXhsUm0SMsy+d7+JwVsNs750fgZnf8L0qyu70IitLkbxDaAwpi
         ObHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=TBgzcU+QM8oQkU+TUSLXH1qqIRWFo/d97fxNJnnwyPY=;
        b=FmekPy0oniWhn4dbsU4X2APsHVKdEK3+aqV1RpboFmDLtS4Rd/vD8yv6JGx3tZ0AzK
         m3SsDf0VJ6Vj/zs6wD6Jj3VydU5zrNcEVayeDDmR0DiAUsofnMCs7KldTfGvGx8qlYrp
         4GoXW/qgncp6YDHA4HzaXUWsEok3GhM/10EmfdsTj5BUDVORHLa3gBOE3nUrObriISwl
         IIucze0BstXr1/1VC7XMJhdGW5Joxh6mUg1N6jT57kc64Kl3FtX/R1b8mgnxb1jsvwzK
         r6ahJl8426mDa9utPFfZ9e6nUu1cpzi+I/9p/Jh0EPwjPUP6LH0+p8/oEReDukrDHkRv
         iOug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=qzdgx7D4;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d3si31690122pll.161.2019.01.28.08.07.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 08:07:50 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=qzdgx7D4;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1B4B820989;
	Mon, 28 Jan 2019 16:07:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548691670;
	bh=Cl1eTko4iUGK2WU8wbodBAejJ2Crw/a+kDLMWX2LUgA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=qzdgx7D4pVEDjkybXiQ7iTrAWqZpSoh4fm30/m+uuC9/hTuRr9/LCQk63b+y+sD4/
	 VQiACvV+13nUPEwTjrt5nmxnRxyXvbIePsgS9fAdIt7M+JiJrguqEGgIivp+f4oL+q
	 7dljUd4yr+IUwHwGURySH7pSU6cZPm9RX+pj5Fik=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Dennis Zhou <dennis@kernel.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 180/258] percpu: convert spin_lock_irq to spin_lock_irqsave.
Date: Mon, 28 Jan 2019 10:58:06 -0500
Message-Id: <20190128155924.51521-180-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190128155924.51521-1-sashal@kernel.org>
References: <20190128155924.51521-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190128155806.xMQfabSW3QD_VPQb4ScTi2k8zMGrFmcuHo1eYjv85sc@z>

From: Dennis Zhou <dennis@kernel.org>

[ Upstream commit 6ab7d47bcbf0144a8cb81536c2cead4cde18acfe ]

From Michael Cree:
  "Bisection lead to commit b38d08f3181c ("percpu: restructure
   locking") as being the cause of lockups at initial boot on
   the kernel built for generic Alpha.

   On a suggestion by Tejun Heo that:

   So, the only thing I can think of is that it's calling
   spin_unlock_irq() while irq handling isn't set up yet.
   Can you please try the followings?

   1. Convert all spin_[un]lock_irq() to
      spin_lock_irqsave/unlock_irqrestore()."

Fixes: b38d08f3181c ("percpu: restructure locking")
Reported-and-tested-by: Michael Cree <mcree@orcon.net.nz>
Acked-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Dennis Zhou <dennis@kernel.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/percpu-km.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/percpu-km.c b/mm/percpu-km.c
index 38de70ab1a0d..0f643dc2dc65 100644
--- a/mm/percpu-km.c
+++ b/mm/percpu-km.c
@@ -50,6 +50,7 @@ static struct pcpu_chunk *pcpu_create_chunk(gfp_t gfp)
 	const int nr_pages = pcpu_group_sizes[0] >> PAGE_SHIFT;
 	struct pcpu_chunk *chunk;
 	struct page *pages;
+	unsigned long flags;
 	int i;
 
 	chunk = pcpu_alloc_chunk(gfp);
@@ -68,9 +69,9 @@ static struct pcpu_chunk *pcpu_create_chunk(gfp_t gfp)
 	chunk->data = pages;
 	chunk->base_addr = page_address(pages) - pcpu_group_offsets[0];
 
-	spin_lock_irq(&pcpu_lock);
+	spin_lock_irqsave(&pcpu_lock, flags);
 	pcpu_chunk_populated(chunk, 0, nr_pages, false);
-	spin_unlock_irq(&pcpu_lock);
+	spin_unlock_irqrestore(&pcpu_lock, flags);
 
 	pcpu_stats_chunk_alloc();
 	trace_percpu_create_chunk(chunk->base_addr);
-- 
2.19.1

