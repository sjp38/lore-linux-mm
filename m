Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F481C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 15:54:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F229920989
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 15:54:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="pXoMh7mW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F229920989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7035D8E0007; Mon, 28 Jan 2019 10:54:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B3268E0001; Mon, 28 Jan 2019 10:54:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C9838E0007; Mon, 28 Jan 2019 10:54:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6098E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 10:54:16 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 82so14351153pfs.20
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 07:54:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TBgzcU+QM8oQkU+TUSLXH1qqIRWFo/d97fxNJnnwyPY=;
        b=nlDlTU2eSj4NdTazrVrGyyKZLC0/Yx76xMlzqMKwYTnrptyffPHqHu56S6KDv+gYGK
         lkRyuybUpNRSf+n/p5LTnK7YcgDLpUYeCh2JTfCQP6wNPYrAapVyQeO8f5d2TdXimT2i
         NjkulNjIIqczxk9ZMe+YzbX2EPR8CwFMtbZDBFm5yrh5JPa2o0rn2HHMlqS0yZKy5TjH
         esB9PWZ4jV/tmMA1or/VT2VEUY8emK2C5shSO9GQsf1c5RVcpKjp6eMJ0lbK731S1Uzz
         GxfLYcUl3NZv7as8bknb/+LBcqxTBve4xIw8f8FueAMErA5A15aMgS/HaY6apVW1hfTA
         Wf5A==
X-Gm-Message-State: AJcUukdiM/fxxZm/GIBuTq3Rfsy1rL3dG9hJp1gw4oe+bs2CHqYAMC3r
	ubj4i38OD2xnNMNpyOIKZfsCFST/MrDxD9iRs4KV9SoBzbpmOVSxDQ0L6jiiHve4IFXHfa/nv8G
	NlhOsvz19KWTLjkGf8/HUsDmFlQGLVdcwoNZ3I830yeiQiBYQpAIslf/FhKQmyVF9hQ==
X-Received: by 2002:a17:902:5a5:: with SMTP id f34mr22359648plf.161.1548690855659;
        Mon, 28 Jan 2019 07:54:15 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7Vs0ethcdcicE9MAUggfKHog8wSpCy4cLJmeeYwHI8Uce+gx30VQgnZkoOnN6PsQUle1g+
X-Received: by 2002:a17:902:5a5:: with SMTP id f34mr22359630plf.161.1548690855044;
        Mon, 28 Jan 2019 07:54:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548690855; cv=none;
        d=google.com; s=arc-20160816;
        b=WOwPQ+DW5GSItT100Lp5pATEH3FwRYC16e0Ee+KjbpRoUhpYIpN/W+oZPtSXHuzD10
         zxeHx5B/YyATiX8d0yjnBnui6meZwbB8U0nWmRQDaSlO3TpbOYutPQ3RSwv/fKZXEwX+
         A2NIbKfgymtiU3prUU7+pSmMap63RuNNHlYYf1vpR0dcU1epA0BwHJVHzUcxfXFerDMd
         HNnxmo0hdccdTxinCl6vtywyodyFNSWYAKtmhzsSrnxF9IcXFZ4eNquF0Gh1WYfZbKKW
         9k7RAW1rRuRh/SazgCn8Zvgqh0aNYEHdtXowOhOzB/ZVEZ5Vxm/VdobRNcVS4ZcAZhV5
         IGRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=TBgzcU+QM8oQkU+TUSLXH1qqIRWFo/d97fxNJnnwyPY=;
        b=qcmIvgYHAoYtfE+mitZ/yG2xiE7OEq3GXCL9rnskO7JcJJ47Qlxir1LPfJby2d+Som
         NjKessOjINP1tURipD25tH+bgzmxSS+RzX76oy4Wl+J6qMGgeLGvXqRZ8LWgkQtaaWv6
         m/ZuZaA/Jq9C/YuC9u8e2aPznOPYj3pnUnqz1R9+9DFiOEm+EyFOr7LTmjnpYOfeUBMI
         iz1LCzPXJT0QaP4QdYp+gO1GnOeBf7q1M0gVVhFC8bnTwwZ6ornOqssZrT6niX4XwIba
         DlDFrHEAlmMor2s6Wk4AV21SENwMwJyHSGwFv2vFVEL+CnNKwjaLUCzkfGD9H2VIHN/X
         aN+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=pXoMh7mW;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 2si16135342pgj.104.2019.01.28.07.54.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 07:54:15 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=pXoMh7mW;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 85E062147A;
	Mon, 28 Jan 2019 15:54:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548690854;
	bh=Cl1eTko4iUGK2WU8wbodBAejJ2Crw/a+kDLMWX2LUgA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=pXoMh7mWN5UIFf1PVRRUS8fdX7QBhnwVWNF85LmyV7TKd/4QOxphj1r3Sm52/KsOe
	 01VcbjdoQ8NYNV/doj/vHpIM92ErBlwD6p41GUa1mZlRbcG3705M5BEEeAf/EvZKxY
	 fUXey8CamPiP4zwq08rq9yrQl7NLFDGlBl52zJls=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Dennis Zhou <dennis@kernel.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.20 214/304] percpu: convert spin_lock_irq to spin_lock_irqsave.
Date: Mon, 28 Jan 2019 10:42:11 -0500
Message-Id: <20190128154341.47195-214-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190128154341.47195-1-sashal@kernel.org>
References: <20190128154341.47195-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190128154211.fyI8KW5Q8rlpBfadb_MDmcPSF3D4RkhhlMZt7z04-GA@z>

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

