Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FB97C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:16:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EB6320879
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:16:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="DD6u3WsI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EB6320879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD4DE8E0007; Mon, 28 Jan 2019 11:16:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B5CDD8E0001; Mon, 28 Jan 2019 11:16:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D5DB8E0007; Mon, 28 Jan 2019 11:16:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 576688E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 11:16:52 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id g188so11778706pgc.22
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 08:16:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QK9ouipMXiJwB+afVwhCk/IXgFOSJ7lZmFgHmUi3RZY=;
        b=r+wk0FF5NHuKerMdSY+4U2T/eh2G8Hhg6qFNXekIcfAAmOwU0/wuViXc1u5y/OylyV
         A/oLUr4shdY0SNRKDunhbLvwTpBpwHUJAMGtN1TAhnP3J2Sp9x/8LN4q2ZIolFbNTOep
         6pyArZphHH7FO8piKpJL3io1P5zfkojmF1S5tV+QyUocO6CQnWOHfgE1pG/92rWBkDJi
         lN0jLigte1D+tKaPAxXqnTUBZXABrMzefZAp7F/MB33rcAAKWKDRTFW+FFgFG6BqNsZd
         sJf9iu2ua6EebWtZU3HYM346gZGg+NEOucb0/bTEftMsU83yo3eUGFgzcR5sRADncINB
         nicA==
X-Gm-Message-State: AJcUukfRuhkCFpruq6+onJMLfRht06hJYGnXZPOIMBHKGZVmpD4ju/85
	rESUod+zBb6RWGq4hppZvhc6h2+PUHkh2tO/Oub/tqMpXpXxeQVOCEqV4iL3dyfOiRIL23B9U9I
	5TDcIqfymsexsFEBXQXKogxrRWwMn4a43GqafP6BmPi5FdczurI2TbLQJFmRC7lUOrg==
X-Received: by 2002:a63:e545:: with SMTP id z5mr20392386pgj.195.1548692212015;
        Mon, 28 Jan 2019 08:16:52 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4hquMi8sHTzxewHhawkVszlr8/l+rdq0FMxfkxCf7bLVtwcSMTFlJ7NjV1iSYBAf9vX8WD
X-Received: by 2002:a63:e545:: with SMTP id z5mr20392347pgj.195.1548692211401;
        Mon, 28 Jan 2019 08:16:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548692211; cv=none;
        d=google.com; s=arc-20160816;
        b=bYi7ho3pbKBqmNz3finok4parMwPaLAAQJM272vZmF8qopNktkgwf1ffUBbnd5haPL
         4bvr1x8iRrfaxrb0CTeI4a1/BVosuwkwKI270o5Xox5W5lHqi8tFTUuVaCmXt+cFLYW2
         tUCX2y9uJiq+7ijGzk4qaEVs0mOMhjPFtV9UO1uMcM5yidA/X/zLEgAiU/t3sd1AZ6b5
         dzaaaAZBrGzVL4gpetOsj0sEibA8jLXa0B/YhaZMnHjch9tt5qPxolf1tgaucIm73QAt
         U9YixFfNjvuLJAIBgdJxHhnOZ9JN49XkAkhAoB/WMamLh99PxtEZpb2vEVaLpB/Q+l2z
         RRdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=QK9ouipMXiJwB+afVwhCk/IXgFOSJ7lZmFgHmUi3RZY=;
        b=PTV5CqJ4oYYQBZ/+NvtvzJNs+G2+SQL3Mz8sBZoKoaeKJ0xEzCE9+sLt0eebC1EZxf
         +Cl5QdBHb9dDinLEX8Ywf+pQpknMDsxmx9gsDG7CM9Devos3RP2AT7aDhGP+DUCwYfG4
         zXE5TxphWyBh11yh2BO3SqVQWRELLdIDJj1sBIBAlKqSynWaBFv+VZnnuBrCYMfac4lS
         lfSE98EQrLda6Z41/2sq3qbDk/glMj17HSK/ea3jwEfq4recx4tOssGs13T2u/ziv93L
         tuDSz95iL72OzLcDau64ehg8jKVA5QUDdwiZKpIXoZHRodhjP8jsyGUEHpolU+fTEQ3Q
         GJ5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=DD6u3WsI;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q3si11666985plb.209.2019.01.28.08.16.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 08:16:51 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=DD6u3WsI;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E5F8E2147A;
	Mon, 28 Jan 2019 16:16:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548692211;
	bh=W0QWpv4BDgJW9fxr6J15E4gpGpoSj9616cMXTiK1M78=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=DD6u3WsI+BwxdJICVybz1r+KRruw8Pz1+yeoqkd/kEV+DTROF1kCaz5wavebg4hC8
	 lydAJTNCYZFFlslEDub3+XWeBdYsbgOmUEbdz8q+lSIEC1CHiAwnfTw7tKafdPuiMI
	 zRDLiPQoJMgcNVD7yC39kiR6XYZr4RedyAPSRvQM=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Dennis Zhou <dennis@kernel.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 112/170] percpu: convert spin_lock_irq to spin_lock_irqsave.
Date: Mon, 28 Jan 2019 11:11:02 -0500
Message-Id: <20190128161200.55107-112-sashal@kernel.org>
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
Message-ID: <20190128161102.K3T_P7G15AkAWXhu6Z0zX8sH6NdJAKcdBdsNIfuGuOc@z>

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
index 0d88d7bd5706..c22d959105b6 100644
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

