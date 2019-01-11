Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A59BC43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 00:26:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C5CA206B7
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 00:26:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=synopsys.com header.i=@synopsys.com header.b="SqmSf2Nr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C5CA206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=synopsys.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E52EF8E0005; Thu, 10 Jan 2019 19:26:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E29168E0001; Thu, 10 Jan 2019 19:26:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D40908E0005; Thu, 10 Jan 2019 19:26:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9635C8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 19:26:48 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id h10so7184646plk.12
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:26:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=aYYSVpAP/XnYwzxtImxbDnmSdr8MYb+OpJ8V5+H7hRI=;
        b=TNoNwkQum9QmbHjzxNb/m2CewPd3pkX17KQh/WDrS8BT+KUZprJmxcnjoyCXY/O55R
         E7Qwsa4KopQF5tNqvddc8ALWeQ18efXj8Wu9DGLAdm+QtVW65w3xnDEq0C3fMD2boj3U
         U3asetsA5MJ10FAQeyM8rJTtVGp6MAFzFiEU07lTZYThgEBYaVOuluGUSms3yiuXs8sx
         +ZsWMSuh5WoOc6O7cQosjfsj9q5PU3msFM3IZrp/cRhacJV58siZK/s5WfMVdHhGr5XW
         Fk2W0tUwVWXiLjPBv7cF94oAAmeDvz9zGfI0kHMPjQ7z+FyuSPTNG0RzyBqGtcHjAFZW
         Z2Gg==
X-Gm-Message-State: AJcUukc+4XPbXsfZpS31xEatnqOtZSxSVkWydgExF7+hgmZadO+zZu4f
	lT5NrYjWl7XO1RB201V8VNaVxC/NvQdU7kQ9M0p6FVh5UsDn295B/NRALbL/iPTkk2i7NS2pmKs
	OKya/wX+fzePl8ct503tV5fcwIiO/mY7v26IqXSm2fRo8hiHfwQYvaJhmG+7iGyoL5g==
X-Received: by 2002:a17:902:6bc7:: with SMTP id m7mr12708036plt.106.1547166408295;
        Thu, 10 Jan 2019 16:26:48 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5ZiPdVdqNRwb+KnEGh1QAIcmm4T8uErKhFlzXHFYv2xHKYtKF+cEG77hbiE9TWpBX25+io
X-Received: by 2002:a17:902:6bc7:: with SMTP id m7mr12708011plt.106.1547166407567;
        Thu, 10 Jan 2019 16:26:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547166407; cv=none;
        d=google.com; s=arc-20160816;
        b=czP+rcXd3Gl1SY2hTz/nLN15eZDCtgchS/xgLqDjisheVB2UYAnE9DEHxTn5QBlDFg
         cEFJ0f/A2lpPaQ2CSmUCthvug8WWKoM5v5t8fPQnP4v3JKpmPgreeVWDEUqTyixfSRHO
         Jc7N9YOfuBwHs+WDxxblRaJG45XqCK5Mi6nS5OeL51X4TAR71TwSU09+rFkbqWTUkTjK
         YhwVyvF8p5f7ywsbjTv/Q3CIprkmZp46YPHX/bKWmJzd0ErpauUrL9KpAaA+7lRGQwfq
         aPnK5h0gi1jEqWVyDqFNZFl4mW+uabpgp5c10g45vO+4w3KMk3ygbbdUk9jRJ0K3JmfT
         C/ng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:dkim-signature;
        bh=aYYSVpAP/XnYwzxtImxbDnmSdr8MYb+OpJ8V5+H7hRI=;
        b=bZQ6sHsnbX2gmbGppQcKJWCsHbWb9TKKrUiESucElJ6VtfU2m+CbgC/pT09t8JRygv
         kr2TdXk2+WKC6P+38kNLWUk5jzr5cRepNMNSLb3mIltMN5qzD1I9hQ2yZdilpDi/1T6P
         pSsZDJIO6FJhSwC5+dsDjcGOT3xW8+l2SE+V0BloEwNuPw2pcmhpnZKUHKCFF6S1KhZe
         U4pUbl490/ZKew0XWYOnVKtS3DuDj9VMj/kdSD04h8aJWwjyEkTSZyH0VhqkRWNwSsWQ
         WPcpm1yIRAnDYyNcDPITSJGslvr/vRRTvTlI1rOv4LCP7C2Ix8iM3Pkqz43pxOF3V2zX
         afjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=SqmSf2Nr;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.60.111 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id v9si10761030pgo.23.2019.01.10.16.26.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 16:26:47 -0800 (PST)
Received-SPF: pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.60.111 as permitted sender) client-ip=198.182.60.111;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=SqmSf2Nr;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.60.111 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from mailhost.synopsys.com (mailhost3.synopsys.com [10.12.238.238])
	by smtprelay.synopsys.com (Postfix) with ESMTP id E8EB710C0D59;
	Thu, 10 Jan 2019 16:26:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=synopsys.com; s=mail;
	t=1547166407; bh=eKBup9uhbGbyAPqlLa4zZa3Jtqj2PAt9eLGZkA1RvN4=;
	h=From:To:CC:Subject:Date:In-Reply-To:References:From;
	b=SqmSf2NrQugccT38I5aHfN4WFd6vJlQdry2qm8IJGUX2JbU0uKPyw1epBo6W8oxK2
	 utBjd2Pz0AtwCcCTULpwDz1bmiYsRJJvVNjtgphq/lkDy1crFKgXDb8aFavfTFBcq3
	 9Mr5smW2c5dHkYkYJfu7Xb6WOCJFCdPCqBfa1M98RQUA79zl+UxfTURhlRZIH4y6Wq
	 8mN5jOgB5BhMWbZgbz0uwSOG/AueWakpTA2WPe4RvFM6ZTMlAvbnqPCz+VNOEPHpap
	 pQwVZedlhtdi1U0DfuqTUVaMBcwRDiTy67Vl9EosS43I/HKR1jKhuSd+yFiLU/5toX
	 f7kMbiWCbTZbA==
Received: from US01WEHTC2.internal.synopsys.com (us01wehtc2-vip.internal.synopsys.com [10.12.239.238])
	by mailhost.synopsys.com (Postfix) with ESMTP id BCA10344D;
	Thu, 10 Jan 2019 16:26:46 -0800 (PST)
Received: from IN01WEHTCA.internal.synopsys.com (10.144.199.104) by
 US01WEHTC2.internal.synopsys.com (10.12.239.237) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Thu, 10 Jan 2019 16:26:46 -0800
Received: from IN01WEHTCB.internal.synopsys.com (10.144.199.105) by
 IN01WEHTCA.internal.synopsys.com (10.144.199.103) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Fri, 11 Jan 2019 05:56:45 +0530
Received: from vineetg-Latitude-E7450.internal.synopsys.com (10.10.161.70) by
 IN01WEHTCB.internal.synopsys.com (10.144.199.243) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Fri, 11 Jan 2019 05:56:46 +0530
From: Vineet Gupta <vineet.gupta1@synopsys.com>
To: <linux-kernel@vger.kernel.org>
CC: <linux-snps-arc@lists.infradead.org>, <linux-mm@kvack.org>,
	<peterz@infradead.org>, Vineet Gupta <vineet.gupta1@synopsys.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>, <linux-fsdevel@vger.kernel.org>
Subject: [PATCH 2/3] fs: inode_set_flags() replace opencoded set_mask_bits()
Date: Thu, 10 Jan 2019 16:26:26 -0800
Message-ID: <1547166387-19785-3-git-send-email-vgupta@synopsys.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1547166387-19785-1-git-send-email-vgupta@synopsys.com>
References: <1547166387-19785-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Originating-IP: [10.10.161.70]
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111002626.LBoOWuEcr5UM6FKbBQ_sM_5rmPh0i_5fciRhOSowSkw@z>

It seems that 5f16f3225b0624 and 00a1a053ebe5, both with same commitlog
("ext4: atomically set inode->i_flags in ext4_set_inode_flags()")
introduced the set_mask_bits API, but somehow missed not using it in
ext4 in the end

Also, set_mask_bits is used in fs quite a bit and we can possibly come up
with a generic llsc based implementation (w/o the cmpxchg loop)

Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Theodore Ts'o <tytso@mit.edu>
Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 fs/inode.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 0cd47fe0dbe5..799b0c4beda8 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -2096,14 +2096,8 @@ EXPORT_SYMBOL(inode_dio_wait);
 void inode_set_flags(struct inode *inode, unsigned int flags,
 		     unsigned int mask)
 {
-	unsigned int old_flags, new_flags;
-
 	WARN_ON_ONCE(flags & ~mask);
-	do {
-		old_flags = READ_ONCE(inode->i_flags);
-		new_flags = (old_flags & ~mask) | flags;
-	} while (unlikely(cmpxchg(&inode->i_flags, old_flags,
-				  new_flags) != old_flags));
+	set_mask_bits(&inode->i_flags, mask, flags);
 }
 EXPORT_SYMBOL(inode_set_flags);
 
-- 
2.7.4

