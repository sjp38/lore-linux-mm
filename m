Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03B1DC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:44:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B2C41222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:44:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZIjTmsvr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B2C41222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3968A8E0007; Fri, 15 Feb 2019 17:44:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 346A88E0001; Fri, 15 Feb 2019 17:44:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2360C8E0007; Fri, 15 Feb 2019 17:44:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id D8E818E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:44:20 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id f125so7780554pgc.20
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:44:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=arIO7gLw9RNNWVmh9ZBQTlhTkHHBOY3pzYGT4D5o+8I=;
        b=O29QIKrqa5UBljVAneSkLMoAFFWRctiTFYFjsQzN6jTdHZ9NmnzXKnIPBQwiTn16jP
         4h487s4CgAku1IyfspfeZ6ghDIVLXl/oY6j2Aq5sVMOejx42AGXRNiUSLpwOaUtdrevE
         lA1WFpXUXppaE+9QcQaC3wcwi7LzERf6i+IeV6SOIn+peT4QUYB2bpvMUdr8iVNwciZW
         lZ25mSyEwi1a2hVkalT4AR/JIVxfZZJcM2aTt+NWHZi5Rue0M8lzuR4h7HWS1DDlSTdC
         ghxeh/thNr3waNupROLGPbNJ+ktnJXNfMCE+gxB4cSqV/+w6X9CyGO7u+CYbJ3z3nEG0
         0Hww==
X-Gm-Message-State: AHQUAuZkjYzycoeJNTj186yUiZd2AkOW8izFRQWZbPY2Vfgji3FwC4ew
	vzDqwQfgjz3aFIMfYXn/C0lP+Z5rRVcBa7CG3eTRqOixALR3iSpkXFQljwuY0xZxubHrbbwtoOf
	gYdndKWao1ZELkqNZgxzpMht1HnkE4eb4HQ67IkH0d3RpcCyEwZetBhhHNnKbJHOzikDmhbQmsC
	BTX6lRDm1ErG7Ttbp5wzIWlOgfwh8hxD1s6j3I4XS8MyobFGmD+ydMX8axPYbDsOw/s73dGMp3K
	vsT6YZQCxHf3QxsmrwCm64KKggwbaVBIl251Cv1ThPe9ky4EpepOqLReN+lqVC3+lG30HIlmME2
	0SZoasAD+lb93fmeLkA37U0iA7ksu4NQ2Ul3FUkOYFlksoh3qi4Xmk56qNT9C0RmTScHV201pZ0
	o
X-Received: by 2002:a17:902:b082:: with SMTP id p2mr9715760plr.299.1550270660569;
        Fri, 15 Feb 2019 14:44:20 -0800 (PST)
X-Received: by 2002:a17:902:b082:: with SMTP id p2mr9715708plr.299.1550270659654;
        Fri, 15 Feb 2019 14:44:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550270659; cv=none;
        d=google.com; s=arc-20160816;
        b=jCiw1MS2XuiYv/t6xGXvBp7NtxC189JMTOMfeiwF0QNMPM01kSQi7L1oIC0/1Nmdlb
         dxkO6Ni3sBYmatHBB3kpWyiRDLAK5MwukCsQyWTPpitNjSQTrkFmcU6xenlx9jjj2uSf
         2ACvw8ZD49RHXOitL5T6LwFDJX9x3aQPnDg7+F0EY7nFr4UUhKr0oGxV7Ki3NT3bPTcR
         mB1n+iyWS4rW9jhACbfgV41qn/4frwV35Oh4sbUHUbfRelyG6pRWlKSFgV1fX03iZQ7M
         8dWa4bs/zNR/2HtXLVuE6HpJqfsDX6aoHnA8n8xnQkpZVqbR/gXHyGfTtE13KwQAyfSd
         tVAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=arIO7gLw9RNNWVmh9ZBQTlhTkHHBOY3pzYGT4D5o+8I=;
        b=rmeEWoJBz76RH9zCO1hggQnfvrv4aDz+WC0TYmchBpetG/BgLZ/l0ltyE55PQja/9w
         s6I4HrWhQMrJVmaxJQ2G3aq4kMWOQuNe6rNWue9tBb8oU+B81AraUR2FAavS3Aw1J2iV
         IVojgJeKCPC4gU+SOw+2fu+UaS0ZMkpb5Sy8wQ/7G4WV7WBwrQl2DRcdWJm//T+rmd1k
         /iC12qvIjAZrDebo9qj7aFB/mW+9ZqdaHmUvDcdG6jrrtVvddGPX6+Iuc/+i++/glkSt
         wEuFsD6BfoH5KQHkH3jdNjvw5tR9PYppBHVh8OKhnjBDS2xxEtNgWRCIiRpcqA66siWU
         Y2tw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZIjTmsvr;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 73sor6389683ple.60.2019.02.15.14.44.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Feb 2019 14:44:19 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZIjTmsvr;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=arIO7gLw9RNNWVmh9ZBQTlhTkHHBOY3pzYGT4D5o+8I=;
        b=ZIjTmsvrt5YtKJrEdwLrMAsf8mEpOCRVG4XnZE8f7/hixv5N7BRMfMLC4D3pJAZU5e
         zDX1nfa2aClf0rW49OWbWzCHEAuT7rgox8H2VqyAQOj8LBNSKMNivmSfgzQfNEgj9ZXS
         dL0b/FNTt9g9fffYzkj+FWPlK3q4HnjUqrTIZKpWUip7e2WEWqOfKXI/313nSJteQ5aS
         jEZSX5dHjTyTNrzcpAk9guHcEJV8tL/mUGxHX6rBEVL08EVwZUqqgmXn8y9z65H/RXoD
         c3whsxGpq3rOX2XENIYxBED5hmv9EcsgBSL3oIs9w1+/7s1H38keMlCVVDkdZrN3Z/bh
         8wEA==
X-Google-Smtp-Source: AHgI3IZk++qbJ+Aw0T8SCVNVtUqt7mSJ6jHdTi9IXyXzVQ9vrAXgtGDbDZi10JSxCZ04o03LLc1tdA==
X-Received: by 2002:a17:902:4124:: with SMTP id e33mr12577981pld.236.1550270659310;
        Fri, 15 Feb 2019 14:44:19 -0800 (PST)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id s16sm16887803pfk.166.2019.02.15.14.44.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:44:18 -0800 (PST)
Subject: [net PATCH 2/2] net: Do not allocate page fragments that are not
 skb aligned
From: Alexander Duyck <alexander.duyck@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jannh@google.com
Date: Fri, 15 Feb 2019 14:44:18 -0800
Message-ID: <20190215224418.16881.69031.stgit@localhost.localdomain>
In-Reply-To: <20190215223741.16881.84864.stgit@localhost.localdomain>
References: <20190215223741.16881.84864.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

This patch addresses the fact that there are drivers, specifically tun,
that will call into the network page fragment allocators with buffer sizes
that are not cache aligned. Doing this could result in data alignment
and DMA performance issues as these fragment pools are also shared with the
skb allocator and any other devices that will use napi_alloc_frags or
netdev_alloc_frags.

Fixes: ffde7328a36d ("net: Split netdev_alloc_frag into __alloc_page_frag and add __napi_alloc_frag")
Reported-by: Jann Horn <jannh@google.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 net/core/skbuff.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 26d848484912..2415d9cb9b89 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -356,6 +356,8 @@ static void *__netdev_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
  */
 void *netdev_alloc_frag(unsigned int fragsz)
 {
+	fragsz = SKB_DATA_ALIGN(fragsz);
+
 	return __netdev_alloc_frag(fragsz, GFP_ATOMIC);
 }
 EXPORT_SYMBOL(netdev_alloc_frag);
@@ -369,6 +371,8 @@ static void *__napi_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
 
 void *napi_alloc_frag(unsigned int fragsz)
 {
+	fragsz = SKB_DATA_ALIGN(fragsz);
+
 	return __napi_alloc_frag(fragsz, GFP_ATOMIC);
 }
 EXPORT_SYMBOL(napi_alloc_frag);

