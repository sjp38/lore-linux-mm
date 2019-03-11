Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 788A9C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:56:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D587214D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:56:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="iO2fRpAp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D587214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC8DA8E0005; Mon, 11 Mar 2019 15:56:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B78578E0002; Mon, 11 Mar 2019 15:56:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1C438E0005; Mon, 11 Mar 2019 15:56:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5F1878E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 15:56:50 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id m10so260320pfj.4
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 12:56:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=l/P3uwIGZTrKrtESwA7Y9TnIfyUzco2Rdtm+nJslLTM=;
        b=l6C+FTglECMeHa7vm2KLwSjliKkEQgSEpg4nVUOWKvQyZe+6WWZDVRrjYQ1r9P1lhQ
         Io67BZrINeiUE77GiV2fVtMUStPHqra6+Hx1N0wn8KPlR7a1Luo59JSwD32Df0C6tANn
         qnRB8Vq0pj2v3svuftZ2jpDztv7tSfqlOViZb8FXJ3BkIqqdcPNZdLqPfIegytL551tR
         wf+uydOTQppzw2Cu6n/mh5EGBbHA/8J+OXoEDnjwXXE63k7EIQz60KJhEb32di9Ljvsy
         B1sH4RHdPYflOVhIYJ1WKIGPC5nMpZHF5eVTBUUIb0t3QeVUqwbWF51oIcLVX60FBVck
         b1KQ==
X-Gm-Message-State: APjAAAWlLrOT8mCQKzRQbttakHdeCLdlvwOVJfOK3UUK6z8rSzzNMpP1
	1Xu+RK1jJzgUJKNR+Y0spa2cZF7AeBNDH3LDVzR2T7PWYWIdvOJqMgFws9aeYokzxXSbfETh9eG
	m8wo6uzTbLn++c/0KWs6n0YVSxGN9CXn3IfJ71YMS8lzoVIGObkA0pbAbFq7mtJUcqQ==
X-Received: by 2002:a17:902:8217:: with SMTP id x23mr36267251pln.332.1552334210051;
        Mon, 11 Mar 2019 12:56:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztcuZA65lkQ3TzAdLUMS1n44EbhHp/Va8jk6mcikfrM9Jyeptjsl4RV7N2zOTj8SWQFbkS
X-Received: by 2002:a17:902:8217:: with SMTP id x23mr36267208pln.332.1552334209301;
        Mon, 11 Mar 2019 12:56:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552334209; cv=none;
        d=google.com; s=arc-20160816;
        b=Iw+1i9pX+ZXm1ZVRQXNeUriz8bAbbNfWnsZGK3GylqEMFZrdM1YtRfmOf1NhkQ8k1n
         XiDWC2iCdtmCYOWpYPDN/prwa3/jhDcS5iPr1XdzRuagks6GI9ry4kj7bFjYiqGGx2Wn
         N2cYHPFW8mNMHOsQoZIrvCCKJXqm2FtCNOTLgmcm8mWr1SCM52hPOeQlnEgzH1pLyB/V
         65Jk387L/xM2zeX/Lw8Mi6SO3V69xmxRDYORM5wcy5Kk9kr+X4G0wpm0kRQlhLak0XOX
         QeV/NR7ZSV1jLRfnVsis7CUuQCJE0TTsiwC18ICJr49hUgbQ5ZLdt+ZM4wozW1w9exNs
         OMZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=l/P3uwIGZTrKrtESwA7Y9TnIfyUzco2Rdtm+nJslLTM=;
        b=DKefIFczFOf103HgkSzc5lI5z7A0kXRfm+vanWTMX23Jq0wkjP03qGLU+iNoU22GcA
         lVp3dKZIFkbzz4YuGRvw91hgzSAbRq3MgsZ7sGYfcH0Dqvrf7qCRmj4OK8H3+iW+jdL/
         ENNX/uegjkj4fIvxEKRtmlwDC0sS3Pq4zXGy+fdHFAMcFsK3iTpvDaExqn6tj7OSLQi7
         J1pI48m06rrdwJGJJm8ecFARkJo7a87YKMqrs5mszRgudzJOYO9sOfmPCpHo8oXPrasq
         BP1NkDnPp21BGAo7pJkplroqs/05IgHdLU39K4EuTh9y7IkIWPen+EJQr9erHn7h3xeU
         KjrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=iO2fRpAp;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h5si5593385pgv.48.2019.03.11.12.56.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 12:56:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=iO2fRpAp;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 43C882087C;
	Mon, 11 Mar 2019 19:56:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552334209;
	bh=1DsG5DJld3CeOgcits+DYPeHq5/rZWGjmJM/YX0B/5M=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=iO2fRpAp91Fv6TJWuWXjVucBlBhJMxoQD9sogd+9N8aIf+nqe5kL0S46rnRw48rUC
	 eg1hItDJNg0RU0f3N3u/mbq+dd0TXkOJ8WSS0Zo/Dzkw0Gqk9a1v7hDdASvkfulGDC
	 vQsYVJGDC8nmq7F7vWhEnuGAy2A3679zbLzhHqRw=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Jann Horn <jannh@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.20 46/52] mm: page_alloc: fix ref bias in page_frag_alloc() for 1-byte allocs
Date: Mon, 11 Mar 2019 15:55:10 -0400
Message-Id: <20190311195516.137772-46-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190311195516.137772-1-sashal@kernel.org>
References: <20190311195516.137772-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jann Horn <jannh@google.com>

[ Upstream commit 2c2ade81741c66082f8211f0b96cf509cc4c0218 ]

The basic idea behind ->pagecnt_bias is: If we pre-allocate the maximum
number of references that we might need to create in the fastpath later,
the bump-allocation fastpath only has to modify the non-atomic bias value
that tracks the number of extra references we hold instead of the atomic
refcount. The maximum number of allocations we can serve (under the
assumption that no allocation is made with size 0) is nc->size, so that's
the bias used.

However, even when all memory in the allocation has been given away, a
reference to the page is still held; and in the `offset < 0` slowpath, the
page may be reused if everyone else has dropped their references.
This means that the necessary number of references is actually
`nc->size+1`.

Luckily, from a quick grep, it looks like the only path that can call
page_frag_alloc(fragsz=1) is TAP with the IFF_NAPI_FRAGS flag, which
requires CAP_NET_ADMIN in the init namespace and is only intended to be
used for kernel testing and fuzzing.

To test for this issue, put a `WARN_ON(page_ref_count(page) == 0)` in the
`offset < 0` path, below the virt_to_page() call, and then repeatedly call
writev() on a TAP device with IFF_TAP|IFF_NO_PI|IFF_NAPI_FRAGS|IFF_NAPI,
with a vector consisting of 15 elements containing 1 byte each.

Signed-off-by: Jann Horn <jannh@google.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/page_alloc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a29043ea9212..870b2906281b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4537,11 +4537,11 @@ void *page_frag_alloc(struct page_frag_cache *nc,
 		/* Even if we own the page, we do not use atomic_set().
 		 * This would break get_page_unless_zero() users.
 		 */
-		page_ref_add(page, size - 1);
+		page_ref_add(page, size);
 
 		/* reset page count bias and offset to start of new frag */
 		nc->pfmemalloc = page_is_pfmemalloc(page);
-		nc->pagecnt_bias = size;
+		nc->pagecnt_bias = size + 1;
 		nc->offset = size;
 	}
 
@@ -4557,10 +4557,10 @@ void *page_frag_alloc(struct page_frag_cache *nc,
 		size = nc->size;
 #endif
 		/* OK, page count is 0, we can safely set it */
-		set_page_count(page, size);
+		set_page_count(page, size + 1);
 
 		/* reset page count bias and offset to start of new frag */
-		nc->pagecnt_bias = size;
+		nc->pagecnt_bias = size + 1;
 		offset = size - fragsz;
 	}
 
-- 
2.19.1

