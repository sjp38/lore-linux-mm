Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9179FC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 20:46:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EC472082C
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 20:46:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Aohv65Mb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EC472082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CD996B0005; Thu, 20 Jun 2019 16:46:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 855E48E0002; Thu, 20 Jun 2019 16:46:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71D3E8E0001; Thu, 20 Jun 2019 16:46:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4CD536B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 16:46:29 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id k8so5278016qtb.12
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:46:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=v3gUffz2IC2GMolPqjySsy2Kwzf7mwg82ps+ceby41o=;
        b=m/xEnBNotB6Uf1UeBkfMvC5owEKGuR5gGTMJIT5mTTo95VcEGD7mzUjMZIvcDmNEYn
         N3383ucfN0fydOqB93nA9L94fz4nO7ZgvFTVfskhfqkIHpTtcOapUfBENBxPis/6yAPF
         hFgTG+2Ou1a8e98KtY+CBvfilckCSqnFdTq5+1oE5tA1SpQ7OktEqvr+rptOjilFE8GO
         IqV96TqOQaI69HsAM0xP+SAymlEfk0jfDewSInE0N9V21RydDfxEYS40xDLjSQYY4e+j
         Zx6kucl+msydHaw6lSMBfo+ohhm84ODUsCfPePxoXb1hhFPHGJuHY0eDhWE4H0BU/pAB
         pX9Q==
X-Gm-Message-State: APjAAAVHpEUq0ahOHEFhA736eLUOMUHVmPBHHr8snGp5mMC2yHd3Ke1o
	0DvbgvmL8cinxB0WG61cmz0hxvgsHE8ORbO9WFhNWP9q4uOhgDR23CD3zx12/hkYK0HBr04EOS9
	MPMyM3JBqnd7xkq7cPUirvbrIK542UuISUAT0k3LbtNOkhCKRw3yqwb4tGMnvEhZN0Q==
X-Received: by 2002:ac8:156:: with SMTP id f22mr94783083qtg.58.1561063588993;
        Thu, 20 Jun 2019 13:46:28 -0700 (PDT)
X-Received: by 2002:ac8:156:: with SMTP id f22mr94783015qtg.58.1561063587839;
        Thu, 20 Jun 2019 13:46:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561063587; cv=none;
        d=google.com; s=arc-20160816;
        b=AC0nKCCgiSA8uBdIhtofeaKwVnBQIR22Cxo/w8KkTtzbF33SPtgne07IN7VgdwyNCe
         73hSNHrGZDrg2kOgB2bVjb61KoAnRgl7/EOZ7yt9MoRa7L3odpMxwObT3ZTmuzSIFxsr
         GVAf4n4ARkGHFSWsyQEilj5Vx2vvHc88u2q8MI/+9SSkijJIjmQG6CzOPejoy4lyoNnB
         MMnKfNXov9z2WRGRMbFZ/yMBKO8cyP5oaxZpN0iRefKkZfx4a8pETODgMffVrVA2myUz
         R0XDdRc6kCyviSAVCSLlHG65I5SmMvIqTmiesk0E9CZM/Mpj83yiHg0SMXY0jvMfZxka
         0GVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=v3gUffz2IC2GMolPqjySsy2Kwzf7mwg82ps+ceby41o=;
        b=cHufpTb/Ypwwu/Tvvf/Tn60n2bo8rDgp8JdIC8WMF5P51DRKR5w6C5udy9PNCpYU/X
         +mUvoM0wesMSjRvQECzCwdthRb26AgrYj9ig7mwVoxN/WPIIfGpjRbYRnl80HP+UXIFq
         nqEXo8J+qf1bxB8DGT9SuuNZxvS7829ceEMJPHymJFyspjCs7jMXfZSqWCyRgge+kU7n
         2FoR9cudpiiK486uRG8fzPJuKH3D9R4HMi1/4tGAmeoZQC1fyJK2lZmsMBKhZ42OL+xX
         QE/fL+0AYzJbzKIAT3ac574zP5KrzHjRvx+sCwaYGta6dIWqcLNMqZBgavEXaoT67Bfz
         5Vhg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Aohv65Mb;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 187sor398849qkl.121.2019.06.20.13.46.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 13:46:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Aohv65Mb;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=v3gUffz2IC2GMolPqjySsy2Kwzf7mwg82ps+ceby41o=;
        b=Aohv65MbEoHXAZa6OvGoj/bIyvVXaDCncWUVf0OOF+5Ah1AG5Flc04T3N+WFtbxgUB
         LKymfgom2KGLdWKqSRSkd+OVtL9sBC9zx/4EnPMgDTQVRckRTtCZcUMJPlqKNm4UVm9v
         RRxMLde2cYzkcSwppx+gGUOA1uPikt2fuKaR917PB0RkXnQabO3Ce7Kcxi5KVmRc0zEf
         eizRWfW2UldeQmdjJnCAwQFk0KAbT9KqpyC0wcappD3UgdziroR31Al4iwPYHXyRFiVa
         2s/I7DrLsMGj/JBADXzu9V7XjYYdWnBDpq0/Y0AW1FnicdQ5hWPrY0eZ9I9Ao0MM+7BX
         2Y4w==
X-Google-Smtp-Source: APXvYqzyfrjqPqTMiYyIVosdegH1JYfwr2xtFpaCUBsRfDf1JKSqQ4KL9I9svwAdNC30pMVcDa1RSg==
X-Received: by 2002:a37:9d1:: with SMTP id 200mr58987821qkj.306.1561063587503;
        Thu, 20 Jun 2019 13:46:27 -0700 (PDT)
Received: from qcai.nay.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id f3sm468647qkb.58.2019.06.20.13.46.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 13:46:26 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: glider@google.com,
	keescook@chromium.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH -next v2] mm/page_alloc: fix a false memory corruption
Date: Thu, 20 Jun 2019 16:46:06 -0400
Message-Id: <1561063566-16335-1-git-send-email-cai@lca.pw>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The linux-next commit "mm: security: introduce init_on_alloc=1 and
init_on_free=1 boot options" [1] introduced a false positive when
init_on_free=1 and page_poison=on, due to the page_poison expects the
pattern 0xaa when allocating pages which were overwritten by
init_on_free=1 with 0.

Fix it by switching the order between kernel_init_free_pages() and
kernel_poison_pages() in free_pages_prepare().

[1] https://patchwork.kernel.org/patch/10999465/

Signed-off-by: Qian Cai <cai@lca.pw>
---

v2: After further debugging, the issue after switching order is likely a
    separate issue as clear_page() should not cause issues with future
    accesses.

 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 54dacf35d200..32bbd30c5f85 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1172,9 +1172,10 @@ static __always_inline bool free_pages_prepare(struct page *page,
 					   PAGE_SIZE << order);
 	}
 	arch_free_page(page, order);
-	kernel_poison_pages(page, 1 << order, 0);
 	if (want_init_on_free())
 		kernel_init_free_pages(page, 1 << order);
+
+	kernel_poison_pages(page, 1 << order, 0);
 	if (debug_pagealloc_enabled())
 		kernel_map_pages(page, 1 << order, 0);
 
-- 
1.8.3.1

