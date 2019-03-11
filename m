Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 542D1C10F06
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:59:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 167AD214D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:59:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="PgCnYcZw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 167AD214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2C108E0003; Mon, 11 Mar 2019 15:59:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B02F08E0002; Mon, 11 Mar 2019 15:59:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97BF08E0003; Mon, 11 Mar 2019 15:59:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 52A408E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 15:59:29 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id u19so277884pfn.1
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 12:59:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Y+aYsYA/rmt92iKx2S3DYhoWsWH3IB5eLBe9cF4U/Z8=;
        b=Eo2A5tmjz1nIuIyID05JIavgIZYiMEN1w/IR6DFq+i+tvVg/orVHbsi+bj+Hag0xjq
         jHa+5cAOLK5Ph2gm1l3FZUOwPQnPgXbzhVFivl+Q8N9KL2R5TtsgHvn95yEt19jv+xoZ
         z8wgRi/17UsV+RNZq05uP/22gzGEOITU/gkNN7BlPVS1h9/Gx+iAI7lW0ybvmyK3leXa
         LH0BnvF0e6aQ2d4VyJFkxvP7jGoIFQxqbaB5Hanh0zESDV+xaUjasDzP8bL2jne6+M1v
         SGi4e8616CIzUPeTe/OB5umChgLLrKJjHQylHSruTcDWocRJ+QcBvzy87rGGLRKdPeGK
         cmzA==
X-Gm-Message-State: APjAAAVKIwPJ389bG3R0s6ATmu4lqHqbYPLSlI5RY6wo0JM5Mfoxxe7u
	BEzGOmjZumxWhuvJ2y4oJd2C/1R6c+qufJpyW8DJ+B6GkubYTWWCJWAyGS1uliUBzkM5M3b3+Wx
	6lGI/bHnpxRcX0rKeIxfo6V+BYXC6ZFKmSXLXNhnFbq37cfnZZX3SCTYUc2JwAgApFg==
X-Received: by 2002:a62:3001:: with SMTP id w1mr34842954pfw.59.1552334369013;
        Mon, 11 Mar 2019 12:59:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2ojIAAwNDlq+ONfPRls13fZ82r+mBD+PST7OVwk/KObzrKesnWbhobVIzviXi4M1vXXn7
X-Received: by 2002:a62:3001:: with SMTP id w1mr34842925pfw.59.1552334368453;
        Mon, 11 Mar 2019 12:59:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552334368; cv=none;
        d=google.com; s=arc-20160816;
        b=0PwBy7D2VtBIWRO94SAXbCI4dWD7dfb+J7w+M1ZaecPb4KGQ7PQrqjH0/uSKgB7NgJ
         h/oKVka9jNXJSlv6MQlwclwjH+XeVGI1pzNzr7pFWAdXCYl+/8gtMn5OK8qHX9bobzDN
         DmY6xX0Lxc9tSYo/yG7tlQv3p4pmFW3hWoHADAM/G24fCX284Q/vgui4u4XEi+XztipA
         ChWbYXvw2iFWusQkdebe3anhMp17Z8n5w48nCNfMDxPjIva9WCMEwEIiJ4/0M4+uYfmq
         uQxqCjHEqf3zB2EzijOsPcO7RFGJ9UWGm85NyxHL3DU7gzqUmQBj4TAgDxGQIDCCrqa+
         Tdcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Y+aYsYA/rmt92iKx2S3DYhoWsWH3IB5eLBe9cF4U/Z8=;
        b=LF24zZrnTzyUiAqLLY6WU1zF93kdt2ae1tGwovFt1CPBI7lzfRa2lI9N7p4NhXKQak
         ZFPUo9aKPWQWB82+vnLnzELpFGH2IW5kMaYXyfPqBj/eVBBZLnKQVr9pKC4dhxm2Gf7s
         IKbCw+O0sZbYs+GeGXjlXzOsXhNR/8YHeyWEiaLJEH0MedXFZ96AEBmRk5nKHGXg7IgA
         7SvnpI9wrlktyBO9paUqSQJ4zZFlmZGxaCyrXmSxi5PH1plrnL6bn5M4YUYnZlaHJxDQ
         AnUo85hvFENa6RMRCxbT+/uXIbN121v5hoKcu4/4K3zSp1ZW82RLbWtfadEULjZEB3l9
         0sHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=PgCnYcZw;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u10si5355208pgr.112.2019.03.11.12.59.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 12:59:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=PgCnYcZw;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 76CA32064A;
	Mon, 11 Mar 2019 19:59:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552334368;
	bh=TmGZnr4+jLJDEyOfdQGOrRjkexziPy3Hbymy/C/gRNw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=PgCnYcZwwQWDsPxR7YsssMNdwU/4U4ETCwOt3+mZBp7bjjQb5D+Q3AXJkA95MyTai
	 2R1Or3A8jJBmn4fbjv+kka58WdOamZXWdvF3LsQtmfOAbQ1TXGwEJtt1r54ogJPfob
	 feCT3qlQ9sVYpYhkpn+FRm1jpd+fe4gMIsQJ0Pzs=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Yu Zhao <yuzhao@google.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Huang Ying <ying.huang@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Keith Busch <keith.busch@intel.com>,
	"Michael S . Tsirkin" <mst@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.9 08/12] mm/gup: fix gup_pmd_range() for dax
Date: Mon, 11 Mar 2019 15:59:08 -0400
Message-Id: <20190311195912.139410-8-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190311195912.139410-1-sashal@kernel.org>
References: <20190311195912.139410-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yu Zhao <yuzhao@google.com>

[ Upstream commit 414fd080d125408cb15d04ff4907e1dd8145c8c7 ]

For dax pmd, pmd_trans_huge() returns false but pmd_huge() returns true
on x86.  So the function works as long as hugetlb is configured.
However, dax doesn't depend on hugetlb.

Link: http://lkml.kernel.org/r/20190111034033.601-1-yuzhao@google.com
Signed-off-by: Yu Zhao <yuzhao@google.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Keith Busch <keith.busch@intel.com>
Cc: "Michael S . Tsirkin" <mst@redhat.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/gup.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/gup.c b/mm/gup.c
index d71da7216c6e..99c2f10188c0 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1423,7 +1423,8 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		if (pmd_none(pmd))
 			return 0;
 
-		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd))) {
+		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd) ||
+			     pmd_devmap(pmd))) {
 			/*
 			 * NUMA hinting faults need to be handled in the GUP
 			 * slowpath for accounting purposes and so that they
-- 
2.19.1

