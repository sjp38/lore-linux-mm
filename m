Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 161F7C00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 15:46:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1B9220855
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 15:46:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1B9220855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=embeddedor.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 721198E0089; Thu, 21 Feb 2019 10:46:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A7788E0090; Thu, 21 Feb 2019 10:46:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56DF38E0089; Thu, 21 Feb 2019 10:46:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B2508E0089
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 10:46:25 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id z70so793195oia.7
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 07:46:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=CrtRsUY4GurAVIpJ6gb2fqn2NI3l31wVgVHFt0a1FCI=;
        b=QEhDwwpvsFUe1IfQGYmTKrJrxhI5Yc49plBWQkrw0y6vDKmZoO0Hx9+b1SaX+blv/I
         2EdyYXQZln+FC9+556AVkgsn/0ht+mRPQclhUnIq/gttZE9AtfSJEL48Ugr5Rl+ISYb4
         qd9BNdpafzFZWJFRnlptv61qcjVcVpeo8cFj/Uhez/XW8U+/j/i1p8O2w+2P8TY4FPWe
         fHyOvc+2BaJI+O1zIxelNQSiX2lHwd9ak8wkR5xcPDQ30oLYf8RSuUpi2ImJo4l35UtA
         FGSW+6LpMGunwQECvSrg0Hw1n8WbbTuTgH971LKUcAv3TRbUBjD0WvvrPdNeTQGQKu7u
         lQtw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning gustavo@embeddedor.com does not designate 192.185.150.24 as permitted sender) smtp.mailfrom=gustavo@embeddedor.com
X-Gm-Message-State: AHQUAuYyNme0Xy8TPLQxmBbD1FO7vqWKaO+TV08jaqbK2+ajaW7OB0Qw
	91RQ9sdLEjJ/a38OtSbyXEzHXj5VMsZ4VLXVPBk1lNKEEQpfWpv4I388/MnhR6DF/Fk1DSbfDyh
	7ojV1mMJoOCHoF/v10uKHqpHMJvLoVMaIClI9ltsykIFqAMqiD3SAzYPiD5HkbR0=
X-Received: by 2002:a9d:3f34:: with SMTP id m49mr23878511otc.23.1550763985287;
        Thu, 21 Feb 2019 07:46:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY3d3uOBe3Imi5ykX+9iN6eHAW9OOk7FoCOWD2/q4npWmzbeB8JlYxjZVG7SnYQ8UjvjrM2
X-Received: by 2002:a9d:3f34:: with SMTP id m49mr23878476otc.23.1550763984535;
        Thu, 21 Feb 2019 07:46:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550763984; cv=none;
        d=google.com; s=arc-20160816;
        b=md1hPYoaR1dW2nzEfAmalnp/fKdFwJmopSgny8NSmu067zkjWm/goo6sj+4dEs47Ee
         s0mwfQgzdfCVLBYKpTTjwfGuCYjbVSLESVlt46L6CuORonTjge39kx9sIChBuGhz83kX
         BCqSQedbkhkjXHKCmayHuYnTzxQEnsTS+bSv+m3FrzJqdGckiTaTA3XtmoNqHCBjJRHV
         mHubR20igCJSQHN/fcBtDAXIwplIauj+oDreZypDFEgqrWUXqobhCnv8NVf0u1ypQwzO
         SCBH4vR6W6x/aDjxjBA5d+hSeTIrOxKJQtdBwgvNoRDPQScNyw9PRuqscKYsYyl1lml+
         /NIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=CrtRsUY4GurAVIpJ6gb2fqn2NI3l31wVgVHFt0a1FCI=;
        b=Wg3OjHByoj+/+tAiKnmCUWcYtTgzP6Kt+OQRP914F4yeKKZMjjnAYRZNigVL3eySqc
         r/LYnuPm02eC0fUZZGK5w1yduF64DZtx5e9yK8ES/GP1BcHFyrzkblKx4KR4qo08t80u
         r3fjrU+scc7LT/9KQdzl/7dD6RqBPP0GV4gJm2/T4XpDZY/FO1mStgsT+2+iMXy68QeH
         sscn0KQ88E/gNACsTSHt5yRVfLxcuPxxRcuwyA1zzF3jOVTNKBieUgiv1JvAEEQ/EgZc
         RtWu5Ro/qh/OEluFsIBVjCrPNvGlpG3FK3V8/hViPuS7TEUnzh6+YY0ZWl9ATNWLaT4P
         1R/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning gustavo@embeddedor.com does not designate 192.185.150.24 as permitted sender) smtp.mailfrom=gustavo@embeddedor.com
Received: from gateway30.websitewelcome.com (gateway30.websitewelcome.com. [192.185.150.24])
        by mx.google.com with ESMTPS id n7si9311699oif.113.2019.02.21.07.46.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 07:46:24 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning gustavo@embeddedor.com does not designate 192.185.150.24 as permitted sender) client-ip=192.185.150.24;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning gustavo@embeddedor.com does not designate 192.185.150.24 as permitted sender) smtp.mailfrom=gustavo@embeddedor.com
Received: from cm17.websitewelcome.com (cm17.websitewelcome.com [100.42.49.20])
	by gateway30.websitewelcome.com (Postfix) with ESMTP id 06B2B3242E
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 09:46:24 -0600 (CST)
Received: from gator4166.hostgator.com ([108.167.133.22])
	by cmsmtp with SMTP
	id wqYJg4FK290onwqYJgPvga; Thu, 21 Feb 2019 09:46:24 -0600
X-Authority-Reason: nr=8
Received: from [189.250.119.20] (port=37372 helo=embeddedor)
	by gator4166.hostgator.com with esmtpa (Exim 4.91)
	(envelope-from <gustavo@embeddedor.com>)
	id 1gwqYJ-000atD-5u; Thu, 21 Feb 2019 09:46:23 -0600
Date: Thu, 21 Feb 2019 09:46:22 -0600
From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	"Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: [PATCH] mm/swapfile.c: use struct_size() in kvzalloc()
Message-ID: <20190221154622.GA19599@embeddedor>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.9.4 (2018-02-28)
X-AntiAbuse: This header was added to track abuse, please include it with any abuse report
X-AntiAbuse: Primary Hostname - gator4166.hostgator.com
X-AntiAbuse: Original Domain - kvack.org
X-AntiAbuse: Originator/Caller UID/GID - [47 12] / [47 12]
X-AntiAbuse: Sender Address Domain - embeddedor.com
X-BWhitelist: no
X-Source-IP: 189.250.119.20
X-Source-L: No
X-Exim-ID: 1gwqYJ-000atD-5u
X-Source: 
X-Source-Args: 
X-Source-Dir: 
X-Source-Sender: (embeddedor) [189.250.119.20]:37372
X-Source-Auth: gustavo@embeddedor.com
X-Email-Count: 19
X-Source-Cap: Z3V6aWRpbmU7Z3V6aWRpbmU7Z2F0b3I0MTY2Lmhvc3RnYXRvci5jb20=
X-Local-Domain: yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

One of the more common cases of allocation size calculations is finding
the size of a structure that has a zero-sized array at the end, along
with memory for some number of elements for that array. For example:

struct foo {
    int stuff;
    struct boo entry[];
};

size = sizeof(struct foo) + count * sizeof(struct boo);
instance = kvzalloc(size, GFP_KERNEL);

Instead of leaving these open-coded and prone to type mistakes, we can
now use the new struct_size() helper:

instance = kvzalloc(struct_size(instance, entry, count), GFP_KERNEL);

Notice that, in this case, variable size is not necessary, hence
it is removed.

This code was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
---
 mm/swapfile.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index cca8420b12db..fd9b0025ad00 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2713,9 +2713,8 @@ static struct swap_info_struct *alloc_swap_info(void)
 	struct swap_info_struct *p;
 	unsigned int type;
 	int i;
-	unsigned int size = sizeof(*p) + nr_node_ids * sizeof(struct plist_node);
 
-	p = kvzalloc(size, GFP_KERNEL);
+	p = kvzalloc(struct_size(p, avail_lists, nr_node_ids), GFP_KERNEL);
 	if (!p)
 		return ERR_PTR(-ENOMEM);
 
-- 
2.20.1

