Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 822CBC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 01:55:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47BD1222C1
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 01:55:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47BD1222C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B44798E0003; Tue, 12 Feb 2019 20:55:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B25BC8E0002; Tue, 12 Feb 2019 20:55:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A30358E0002; Tue, 12 Feb 2019 20:55:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 788BC8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 20:55:45 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id i18so756932qtm.21
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 17:55:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=KI4BlPEi7uboQdDXJsU+31t/0aaPma3ptIpyrXEsq+g=;
        b=L+nuTOkSHEpbftSWbIPpteW1v2oe8Iv6IEsDIZqt7u1TBguFDYcvwolfDJ/11YiUCV
         AA5t0lsJapR5qaDmTJxd3U2zH8i6pYoEN8DoScoay975cKidujBSbOyls2VVDpY9MrxA
         VZ/liNu2xzYfIXkclFkihZFaVApkdV8e/exiMsavM81H4rp1I/HqDnGNxlkF9AYon7m/
         G20FAFTDwLiYkX1gzDM9Rfpnd0sVI0XKRJbHy/50MVY3tqdsUDZHYyWTX2KVKRp7EFa6
         hIFpICeXQrpqyli7D36pMH94II/hIYdQr4LiblBrboiQwrGi1/pQ1+MY7mFUj4MEGqVh
         75wg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubYFmJOkJ/FE/lnm5vv/gDDAzUeEG5lnyaLek9vNRtgTYDbQgue
	DU5EB3d1T3wLPuMKMKa8aUrT2ozrVyVqhhQiaIkYuvg0YTi8RzK7/8VSLRrHt7F6iW82Uak+83F
	nfuKp5tXXXTPqQc47hzHNGHNdfgb08ehoANCPxuIm+xqAJJBwvIneNHINa8NIfHKeOA==
X-Received: by 2002:ae9:c119:: with SMTP id z25mr4795522qki.222.1550022945250;
        Tue, 12 Feb 2019 17:55:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYNvA1ccUgPRVCkpbSfMjv816NvhseuXc6VwF0t29afoaUiV5tax8MQrT2VqWwu43yKKkyA
X-Received: by 2002:ae9:c119:: with SMTP id z25mr4795506qki.222.1550022944718;
        Tue, 12 Feb 2019 17:55:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550022944; cv=none;
        d=google.com; s=arc-20160816;
        b=oivy7RAh6OhkCr1q38liF6SeBJtYI9zmOF5nscDy8nfVSaHx3Xl2/n4MQTcckq6rgj
         zcNh+S/B0cGW29bZIWb0x8INbM1vaHNgrlNqbX+lO+25MxweFuNQsGy8FuxR8dogqE65
         TQSQkYGl/rLRhfsFGG3gmX9h4F6BfFw6PBqikJDrkWgGT1Vjp83GU2Q/ret1Fkw9w36A
         LW65ObB/9OgxK6xp3JygJ8lW7hM4MJIFUHaUQg7MczOxPE/O3mw/3OQuO3LpP9pXtAwr
         6eo7GzVUVHDZ79PgkXz4aHgKZDBARqaVnX5RFRBKv7FUyIiCWWR8/6R1H9j34Dks2hWF
         qXkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=KI4BlPEi7uboQdDXJsU+31t/0aaPma3ptIpyrXEsq+g=;
        b=tPMo3JZ3qClxVn5ClT9cPhtIB9qaQYKy9aSbFueAPKkzrGBDpBdKnRrsGN7fGoHG27
         BAu5TsvJCsVFxAX24IeTBS4PjaJkuWq0SVvezb6UZh8ML8CVrl4ktOSNKDxky08BRS/J
         xG+EJ4p3hB4tML+O1DqJU/P3pQekFzr5/qEwbue/VTorwPGKLPFTlJIdjc1V6st45Q7D
         KLJyOJP69RY3Bg6OJonqUnWxS2SRC3I6Ep6dPfIOdn7hVkFSkK1+z0i5RxOQogqSeiwv
         z4JdplTLNKCix0q8HpItrsSoSRClKktbL0m4/lGscHHWBncQQo3oWC2Vuwxcx7KXeg84
         Rdcg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c45si773941qte.8.2019.02.12.17.55.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 17:55:44 -0800 (PST)
Received-SPF: pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C6097E6A98;
	Wed, 13 Feb 2019 01:55:43 +0000 (UTC)
Received: from firesoul.localdomain (ovpn-200-20.brq.redhat.com [10.40.200.20])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 502535C21F;
	Wed, 13 Feb 2019 01:55:36 +0000 (UTC)
Received: from [10.1.2.1] (localhost [IPv6:::1])
	by firesoul.localdomain (Postfix) with ESMTP id 10D20306665E6;
	Wed, 13 Feb 2019 02:55:35 +0100 (CET)
Subject: [net-next PATCH V3 0/3] Fix page_pool API and dma address storage
From: Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, linux-mm@kvack.org
Cc: Toke =?utf-8?q?H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>,
 Ilias Apalodimas <ilias.apalodimas@linaro.org>, willy@infradead.org,
 Saeed Mahameed <saeedm@mellanox.com>,
 Alexander Duyck <alexander.duyck@gmail.com>,
 Jesper Dangaard Brouer <brouer@redhat.com>,
 Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net,
 "David S. Miller" <davem@davemloft.net>, Tariq Toukan <tariqt@mellanox.com>
Date: Wed, 13 Feb 2019 02:55:34 +0100
Message-ID: <155002290134.5597.6544755780651689517.stgit@firesoul>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Wed, 13 Feb 2019 01:55:43 +0000 (UTC)
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

Ilias tested the first two patches on Espressobin driver mvneta, for which
we have patches for using the DMA API of page_pool.

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

