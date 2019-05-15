Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10DBDC04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:41:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C615B2082E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:41:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="C1Gdt9q6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C615B2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63FE06B0010; Wed, 15 May 2019 04:41:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CC156B0269; Wed, 15 May 2019 04:41:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F5346B026A; Wed, 15 May 2019 04:41:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id CF9446B0010
	for <linux-mm@kvack.org>; Wed, 15 May 2019 04:41:24 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id e11so429247lfn.19
        for <linux-mm@kvack.org>; Wed, 15 May 2019 01:41:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=8cD7osAd7wj30fMNGC0J8IUxkft7sVoc3Ldv03Ms9+A=;
        b=scsdRM/Y9FiKE2JQeYBZ+GuEmFYAlY+HQ6TZmNvvNhmjodnR+7oy2SHLxo4DgbeFOB
         K8VVzVCy3k/7To1YpiNY6C5UfdB+uqMiXkwsp6kr4aTn8arhrBkxzCvqo2jXQjcX+Ak9
         mDmN13Ytali0W4XJIhC+VTVNQ05/OQ9E2RBTdjydfq6yxJVoeW4YK6KtFpw/f2bIgOKB
         1JBOsjrvUMllasoiVjoZEh+Nn7uHDtkfqVDq4J6/uj9T6EGky35PwOBXZpHxTf6e1Nco
         me1+mnPrKkK8H9oRVSI0MV2WH5msgHotmp3ceD2NXQTvBX3xK626HFUrz6PV+G9piYSM
         8kCA==
X-Gm-Message-State: APjAAAWKRL4Oi/UzGkEr8eVEVREd/jyTFQB+TY5ituOgrCWYPepzhiYP
	iqAePSJ+HkRmRjX82aAwpX4QmE2e9CYdMkWUz1s5SiA8srS7wRuUtydhicbzNnB1KSZ9+M8hsUM
	fa4hQkyplLxdI4gW9tdx1PQsEJD9CLuXrhVJPNTq788jP1nEisOnuMacYC/rMHuTazw==
X-Received: by 2002:a2e:81d0:: with SMTP id s16mr19412506ljg.145.1557909684311;
        Wed, 15 May 2019 01:41:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwV8eB280JuE68VZOHDUxRSe2SGCINz9ipF6pZNECnyno88M77vu2OAae/qsa6Wg7zoOSk7
X-Received: by 2002:a2e:81d0:: with SMTP id s16mr19412470ljg.145.1557909683427;
        Wed, 15 May 2019 01:41:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557909683; cv=none;
        d=google.com; s=arc-20160816;
        b=M034JK6RSJCMUSQwg+Bb0b2oFsRSJj1vZyhoPF+wLncO12UGUSqEzHnbTd6PHluevK
         e0rnxeXWZryTMJelDLZr33Ou4TD9qnCI6STLzj1ZJFg58yOiY5OLpSW8x5cIFN7gJm13
         OQqIOF0DbgjmaaxuI5wxfut1q+40xeNPLb+2paSh3tLEEBLku6FbY1CCTFuNwqJOXJX6
         /CDLFVV5QnZEbZZtWbjlBoy+ThvFsSiIyjas1aavn3YUVt/TJnLjRKhhoo774ogq3F01
         dh6DQ32A6tmGR4tJwdQ7hb/n2covW2lLIZUG34n2jZVkaOxrhjf+IbAuz8x4vmUpOiz+
         +NCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=8cD7osAd7wj30fMNGC0J8IUxkft7sVoc3Ldv03Ms9+A=;
        b=ZEmbz9zCQpy82pHEEQ28FVq8UvyDaB1ojNUZ9xkNsPMAz4sYWCoOv5V3xw0CY94fYg
         uz+JCITFzVLtVXRGqEfQurxpVCfUA8ZxrFfm2AWqGLzYV8IIAOwFzjFurhM+TXjX/7E4
         +d81SLwCLDYxjVcQzCwvQjK+SCqppMq9Su0VO/kLKaprIh/98p8eupFVeiT8PVa5gl1I
         QCtrD04j4H95w+rXvQqVa44mMXDFG1lZVbkKNBF6cqv4Mkexev0p1vOS1HAf09y+r8gr
         vhW4g6YeJAbOl/RuqQD6QLdD4E0G1f3mGuhLNywE5/ilY7xBLLWWD/m6CoPpRdTuW0do
         0krg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=C1Gdt9q6;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 77.88.29.217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1p.mail.yandex.net (forwardcorp1p.mail.yandex.net. [77.88.29.217])
        by mx.google.com with ESMTP id u26si1153536lfd.24.2019.05.15.01.41.20
        for <linux-mm@kvack.org>;
        Wed, 15 May 2019 01:41:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 77.88.29.217 as permitted sender) client-ip=77.88.29.217;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=C1Gdt9q6;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 77.88.29.217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1g.mail.yandex.net (mxbackcorp1g.mail.yandex.net [IPv6:2a02:6b8:0:1402::301])
	by forwardcorp1p.mail.yandex.net (Yandex) with ESMTP id 6C13C2E1471;
	Wed, 15 May 2019 11:41:20 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp1g.mail.yandex.net (nwsmtp/Yandex) with ESMTP id BfmpUuiCqw-fJsqIJcU;
	Wed, 15 May 2019 11:41:20 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1557909680; bh=8cD7osAd7wj30fMNGC0J8IUxkft7sVoc3Ldv03Ms9+A=;
	h=In-Reply-To:Message-ID:References:Date:To:From:Subject:Cc;
	b=C1Gdt9q6DvCWb8OHGL64+FSDhO+5tEwZKryiXKS18mzixvKGghDJYSKH81UNviwME
	 /A8Dn06dQrccwq2bJFh3nZ73zV9z8LI08I/MXXklUY/i+rbKyZhgGvpGXVLvHuXr+7
	 LIqC9GlgTCkLXk02BEAVj9Z0aXmjiJCTOfL0nNVM=
Authentication-Results: mxbackcorp1g.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:ed19:3833:7ce1:2324])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id ImDQZhn1h5-fJ84Bnif;
	Wed, 15 May 2019 11:41:19 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH 3/5] proc: use down_read_killable for /proc/pid/pagemap
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Kirill Tkhai <ktkhai@virtuozzo.com>,
 Al Viro <viro@zeniv.linux.org.uk>
Date: Wed, 15 May 2019 11:41:19 +0300
Message-ID: <155790967960.1319.6040190052682812218.stgit@buzz>
In-Reply-To: <155790967258.1319.11531787078240675602.stgit@buzz>
References: <155790967258.1319.11531787078240675602.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Ditto.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 fs/proc/task_mmu.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 781879a91e3b..78bed6adc62d 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1547,7 +1547,9 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 		/* overflow ? */
 		if (end < start_vaddr || end > end_vaddr)
 			end = end_vaddr;
-		down_read(&mm->mmap_sem);
+		ret = down_read_killable(&mm->mmap_sem);
+		if (ret)
+			goto out_free;
 		ret = walk_page_range(start_vaddr, end, &pagemap_walk);
 		up_read(&mm->mmap_sem);
 		start_vaddr = end;

