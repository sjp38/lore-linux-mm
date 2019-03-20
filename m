Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2FA3C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:35:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E4672184D
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:35:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E4672184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8CD06B0003; Wed, 20 Mar 2019 03:35:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3C7A6B0006; Wed, 20 Mar 2019 03:35:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A2A526B0007; Wed, 20 Mar 2019 03:35:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 888D16B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:35:56 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id y64so12390583qka.3
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 00:35:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=tuB9PNNGBdrtgxjPzbnq4e1RMAH2qhJJfR1+/49znvY=;
        b=M/u0GM0gbAntpgadqaY9fa+nDAgkCphpAzk/wp3ZSmTfSw8mlDwWrxcWsK/9zhyTTx
         9huhufV4VEgV/omL343FWUSTFVKzwv2GiDKwUdVWEXPSUqAZmnHfh2aCU8qen5nY6rEB
         UDaxV41DI+lm/0/a2CxYX/Y6KnqkaCYzW1DjLGyHJpbaPz984UhO3i2/hf8EHNyKLT7K
         TqX+aVDvSiIO1xxDegFjrZtNLROP2Orj95nYEjLnuMCraaIEFl/qwenQBllVlwyar6Px
         LpJMclbNW12pXhcDH28jnrmfk1UpJb0ZRHh/U6qNi+XFKCE+x1fgesUdZygtOSnJVT2i
         T/TA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW5xuDstOTJGuzJ1JYui70/V3BTmWcaAnEs6fLrjbEwsx4GFBCb
	qqVQe2LipddxDjPZsVLzPqxSizjHxgPjPWO7e5HrGMrzR3/SMGh6iWNsc9IUKrw5zDXpICa9QU1
	bwDU1fQhrRonZ/w1ogiEpP2cYsFzmI9/o69ox9jH4bMe81qwRYWo6Ezz3QganA8xZvg==
X-Received: by 2002:ac8:2f6f:: with SMTP id k44mr5539313qta.230.1553067356238;
        Wed, 20 Mar 2019 00:35:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhtDhr/7Yk1HoLYUhVjM3pjonHo5MqO1ixvJNReGM7ebpyM+gmbdKcpod+IRnLeWLz6rDg
X-Received: by 2002:ac8:2f6f:: with SMTP id k44mr5539274qta.230.1553067355232;
        Wed, 20 Mar 2019 00:35:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553067355; cv=none;
        d=google.com; s=arc-20160816;
        b=F0uNXbtZIZ4nymhlF9WJX9Zpf0yXrO2zl36o0dpyOyVVfQY5luf0kpR3Fxh3pazQlU
         VttgRaEpA0lKmlZrHntC1dTt0OFLdQzR/xj3TF98aS1T0UsP4+08AlFkiNj3dU7iotO8
         tdLTIPXqP8CBXO0BScyr9thK+gz+8WOI+kj0n0x3dWh9c1fTPbIVu3V1XJXkdZCg5K75
         zGRo+GznLiWIp6Js6kHXY7lS1RfmuJJMUjDoE1FNEYB6DySB1iF2cH9rjA8vvnSD76Iq
         MoIjcDCedLVmXkOUGHwS2nJlLoONbkZA14FJLKFCMEdfcW6DGEcDmIhG38nL3npRDUzv
         N5xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=tuB9PNNGBdrtgxjPzbnq4e1RMAH2qhJJfR1+/49znvY=;
        b=GJ2lJWQ9N06UF66bJaaegU33afLu8xXax9jdTrG0/jsiimLjQZHzXtniP4joKZEaT4
         6xN7WPGPMACXdPEyzM1HHDXG6wl2TaO2y19rLn3BTdifJHydoP7P0pxfUCAgwZ8rh3n0
         wLlVgaz071lge2vnAahDvZkH0cURXa47P3sL3m0UBM576BF3+iQved8aSNAocn2WvOiw
         c2VnFRWeRDEv9FZf6qan8HGjEOpI9E4PCrYXZ7wPFM6q9XKSgjS5Z8NOcoCffvNN6tpd
         0tCk88kXCIE1YeMFiq/iyEt5I7sjUJuflcnqNjp+gTywPNpPPo+GCsJjIyk96lFxZKk6
         sHuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 60si768341qtb.367.2019.03.20.00.35.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 00:35:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4948F58E45;
	Wed, 20 Mar 2019 07:35:54 +0000 (UTC)
Received: from MiWiFi-R3L-srv.redhat.com (ovpn-12-38.pek2.redhat.com [10.72.12.38])
	by smtp.corp.redhat.com (Postfix) with ESMTP id AD6D96B499;
	Wed, 20 Mar 2019 07:35:47 +0000 (UTC)
From: Baoquan He <bhe@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org,
	pasha.tatashin@oracle.com,
	mhocko@suse.com,
	rppt@linux.vnet.ibm.com,
	richard.weiyang@gmail.com,
	linux-mm@kvack.org,
	Baoquan He <bhe@redhat.com>
Subject: [PATCH 1/3] mm/sparse: Clean up the obsolete code comment
Date: Wed, 20 Mar 2019 15:35:38 +0800
Message-Id: <20190320073540.12866-1-bhe@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Wed, 20 Mar 2019 07:35:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The code comment above sparse_add_one_section() is obsolete and
incorrect, clean it up and write new one.

Signed-off-by: Baoquan He <bhe@redhat.com>
---
 mm/sparse.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 77a0554fa5bd..0a0f82c5d969 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -674,9 +674,12 @@ static void free_map_bootmem(struct page *memmap)
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
 /*
- * returns the number of sections whose mem_maps were properly
- * set.  If this is <=0, then that means that the passed-in
- * map was not consumed and must be freed.
+ * sparse_add_one_section - add a memory section
+ * @nid:	The node to add section on
+ * @start_pfn:	start pfn of the memory range
+ * @altmap:	device page map
+ *
+ * Return 0 on success and an appropriate error code otherwise.
  */
 int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 				     struct vmem_altmap *altmap)
-- 
2.17.2

