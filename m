Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75E1AC282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:49:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C30D2083B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:49:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C30D2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE9528E0002; Tue, 12 Feb 2019 09:49:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C98DC8E0001; Tue, 12 Feb 2019 09:49:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B62758E0002; Tue, 12 Feb 2019 09:49:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 87A6C8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:49:05 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id h6so15708030qke.18
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 06:49:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=inkblWASuHVcsI+NcbrirSHAAQJiwD8GT1PEuZJ9AWo=;
        b=O6QaOMc6H5SWM1/nuyggdI0v+luiPcb/7XikqD8C/KGl4Xn6K/C98/tipTuzO7Z4dY
         svHwZLrjRqByybWbm/Bbx0iCmWkzDGRuubz16g5cp2slePLE7lAqTMaZjiPePa3c0R7g
         CzfS1G3fdXfCNVbBSfU/cruPYtAeUJMRAw1XkTFUIGK4Ti4MUhlesxRBeifRfNwYgFrA
         qoBbXtF+g9RnvxHQVsLP1jNGt/THzFB675q0ESfkkTNi1UY98wjsUYWfWUzFlkd82S5k
         H+z6e/cCups3OtO/LCVAhSlQ43Or2gij9vY5JzbWo1HR/TymuW7mjZYjcKxwXLK06BFu
         J9Dg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZVasOt226u+aSdBT63ofrSqeHnY+X7KzRmPMxSqrMoCJ+QkMM4
	bfvXxZ0VRLME8XKEZvSCTKWXURoSt167D4iwBXUD9KaXFBmlnP6rZMCmuDKnOMb36+5Hw5NyIBK
	no0lSRnaNDRcoaNVjTK4ttl5b5JIBavcEzxsKFBOtNTOw7ifo9m3ZKM5oJv4mednCbQ==
X-Received: by 2002:a0c:ad0d:: with SMTP id u13mr2865431qvc.231.1549982945291;
        Tue, 12 Feb 2019 06:49:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYqXI4z0CjtKKqa1Jq8UDTIkCyhu9pNiK51E+WxcsrHCRu7EA5R7BlNu49myT81cVyGeRrR
X-Received: by 2002:a0c:ad0d:: with SMTP id u13mr2865404qvc.231.1549982944706;
        Tue, 12 Feb 2019 06:49:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549982944; cv=none;
        d=google.com; s=arc-20160816;
        b=IhNui7fI0cp7c11E8KuuVW9JMEbEPxuyu4MRPJ7MPB7hmenPmDre1Q1ib22JXOpsgc
         DoMSfo+QxdA+HcEyRJOfh1oIUx1f7x9EBPVa+z12UusifNvrMkY5FJsBPuIEhzVpNyKO
         tgsW71G1QyKZqxr3pgeM14BUGE65pX80WD8ANLwHphM4oABPPu6Kpa63qbEb15gkdVIw
         dCFJT/T6S/f161Osq1wFrUK4eCO+wP2BTvtUpsO/VUMrzwmVeQ1z7mytRtZUpRsSlPXJ
         s0EP3YdGrBUe0wVxwV8fcLE3/+JJ5S0T8HTu+QZRwzE3eTk9iGdmWOlIAZE4LqJs00t+
         7TIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=inkblWASuHVcsI+NcbrirSHAAQJiwD8GT1PEuZJ9AWo=;
        b=j2qMf2MwkelBKBcQViqWI//VWQXW8xAcYKbx0pwAyoor7LqaVmPHvp8FExlDmusGNs
         uhpkVfAIWd+ExYiNS/ps/ysrRmPWEFz+sCKltoBO8eutBQC1cdfQvAYYdrTTeUVksIC3
         mqO/SvHQkpEFah6OmuhLBYpvwUvyWqgWVHRUZTqK5yB1azDckw6jhNmRWTSWotfIr9GZ
         EDyD77Ix9pkZlreWU9ygvr8RKFCgBlsdmbamm/Q8wXqQ9XYdr78F7KkrEw1I18zAIuMK
         DZ3cMAVGLC5/9TL1sb74e68NA34tUphVTrP1ATdo2RJFY1p4VkTMc1MdNQCPSH6tOXtE
         T/fQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t16si763941qtt.143.2019.02.12.06.49.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 06:49:04 -0800 (PST)
Received-SPF: pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A95675947A;
	Tue, 12 Feb 2019 14:49:03 +0000 (UTC)
Received: from firesoul.localdomain (ovpn-200-20.brq.redhat.com [10.40.200.20])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 51FC5100ACFB;
	Tue, 12 Feb 2019 14:48:59 +0000 (UTC)
Received: from [10.1.2.1] (localhost [IPv6:::1])
	by firesoul.localdomain (Postfix) with ESMTP id 3863A306665E6;
	Tue, 12 Feb 2019 15:48:58 +0100 (CET)
Subject: [net-next PATCH V2 0/3] Fix page_pool API and dma address storage
From: Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, linux-mm@kvack.org
Cc: Toke =?utf-8?q?H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>,
 Ilias Apalodimas <ilias.apalodimas@linaro.org>, willy@infradead.org,
 Saeed Mahameed <saeedm@mellanox.com>,
 Alexander Duyck <alexander.duyck@gmail.com>,
 Jesper Dangaard Brouer <brouer@redhat.com>,
 Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net,
 "David S. Miller" <davem@davemloft.net>, Tariq Toukan <tariqt@mellanox.com>
Date: Tue, 12 Feb 2019 15:48:58 +0100
Message-ID: <154998290571.8783.11827147914798438839.stgit@firesoul>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 12 Feb 2019 14:49:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

As pointed out by David Miller in [1] the current page_pool implementation
stores dma_addr_t in page->private. This won't work on 32-bit platforms with
64-bit DMA addresses since the page->private is an unsigned long and the
dma_addr_t a u64.

Since no driver is yet using the DMA mapping capabilities of the API let's
fix this by storing the information in 'struct page' and use that to store
and retrieve DMA addresses from network drivers.

As long as the addresses returned from dma_map_page() are aligned the first
bit, used by the compound pages code should not be set.

Ilias tested this on Espressobin driver mvneta, for which we have patches
for using the DMA API of page_pool.

[1]: https://lore.kernel.org/netdev/20181207.230655.1261252486319967024.davem@davemloft.net/

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Ilias Apalodimas <ilias.apalodimas@linaro.org>
---

Ilias Apalodimas (1):
      net: page_pool: don't use page->private to store dma_addr_t

Jesper Dangaard Brouer (2):
      mm: add dma_addr_t to struct page
      page_pool: use DMA_ATTR_SKIP_CPU_SYNC for DMA mappings


 include/linux/mm_types.h |    7 +++++++
 net/core/page_pool.c     |   22 ++++++++++++++--------
 2 files changed, 21 insertions(+), 8 deletions(-)

--

