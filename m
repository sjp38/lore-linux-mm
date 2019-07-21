Return-Path: <SRS0=x6gJ=VS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA6B4C76188
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 10:46:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7AC542085A
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 10:46:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="i3cFHuGk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7AC542085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1C2E8E0009; Sun, 21 Jul 2019 06:46:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7F258E0005; Sun, 21 Jul 2019 06:46:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF98D8E0009; Sun, 21 Jul 2019 06:46:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0BD8E0005
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 06:46:22 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y22so18070188plr.20
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 03:46:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=Ziipr0dWL6Z9I9T3qKO2LfnZ/7LQ7CA8l0MSC8j92YY=;
        b=NWmIPwtkZ8cIcECrz3TawzsZ9QmqnnlDt+GO3smAUFZ7p18kd74F0G2hHpXIsImOWz
         Xo4d+fpCdGqmcBui9P2Vb8O6hZ9lA5pRxLuH58D4aWHShFpMjIANL/rMO8irLVegmhs9
         Wce3ZA7CLlWaS0Hd818jY/03Ho+eY7DkE0b1Qrc22P1vo6vS5g8SP2ZzAKoMoT8R+VUn
         SB8kQypaSom7w/QEqALX33O9eQo/OF4Rl+gKLJkEmfBc2K7i9f6qYR+LOtW+YBtsVbwY
         bolHab2ayNspwp3WiVb2Sb88n3M479ZN75Mf2YLqH2EH+I73S/4LYdBbCAEazEDSAuO1
         1TXA==
X-Gm-Message-State: APjAAAXyv0PLb9WeOBO8AGq2D2mcuO+IKcwl2yJHfPeM+05gDPpvzQLm
	XQfTvy/Di8C3fp3DYabxoAssBSaezjuHp07ND3KuYHgYD9Q6AqY91CasPoFchOEjqxgH4j96oZt
	IhDA6RJeCaG7z+iRLaqVySLjioMS+qa+B/3lixJZir0KTTKPDLDeBFPc2I3Z72dpYgQ==
X-Received: by 2002:a17:90a:ac11:: with SMTP id o17mr71680647pjq.134.1563705982167;
        Sun, 21 Jul 2019 03:46:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3oBI2zRhj3ruLOR79bgDkEtZxZwBQZWXSSd8BIxIw9+Mnr1ksdKyXMLdbQRKX3HOoVOku
X-Received: by 2002:a17:90a:ac11:: with SMTP id o17mr71680606pjq.134.1563705981438;
        Sun, 21 Jul 2019 03:46:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563705981; cv=none;
        d=google.com; s=arc-20160816;
        b=AQUwggM+Vp6rxwPUTPggKuPH+v+nzYME7acTrgA/0XPXdrEZbol7Kavh544FcJNdj+
         f7E6PSDeKyTMb0V1dyzsk3QCfjQ8XV0qYZcTioh+sWXDUDzZ+ypl450A3ywrRx7TQfo7
         TgL1pipp7QwNikJLwRwoysATXHHzotdpDvK2y/Ttwv+oLDK6OczeoEEmxSfuXIe7GTMR
         jjfwE4ZQnB/qenzyiNAH0/8mnuTlZS7HP4d8fMemQ6ki/XmJzSlBdVAl/SqntQ6ODKOV
         bBgunAMLHN8vDcZz2l6wNkozOPIZY015CqvRZTo6XJjEX15ZujzI+RwXQbVSL9UhsHsq
         9YQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=Ziipr0dWL6Z9I9T3qKO2LfnZ/7LQ7CA8l0MSC8j92YY=;
        b=VvVlGyyNy9BJbMOOC8HbR9y+8SGHUNrNtgk0PNm+D/B33EhS+1uUGmR5VKEmaz/mI8
         xdjWHaR/+taTLkbhrIzXLgqydNL2sIXL99+OjVavmH1aGYi+YxCkjL9wbslK7dxKbf9e
         gLHxeBCaHDADzZIvTr+I2sk8TKw+mrQeCuRTMJunBd6fM2tEb+MkbZblEJVAy1Jzp7mM
         cbK94H/kEP0QEA0lRwhOEkKDNAVhxGvDRgWfbkeLpPTQcv4HEDul9RPO8cJ55S7b6CFr
         CLxwfI/2B5mDROnsKAQwXaq27/RT76v1htTiFy0Gp520gu8m+yODj+o9Y4D7vQ0o7Df8
         MWXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=i3cFHuGk;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y92si5985169plb.209.2019.07.21.03.46.21
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 21 Jul 2019 03:46:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=i3cFHuGk;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Ziipr0dWL6Z9I9T3qKO2LfnZ/7LQ7CA8l0MSC8j92YY=; b=i3cFHuGk5qJeGj5Y9Ec/3K4At
	FyvGQLJ+fOyuhdILrurEVj4xBjQzfo76lBZAQ1CZYZkaFx6gTj9elGUOhFnxcs0DdwZmqWcjsN4U8
	R0KdtqLwuTvxHeVXAy0/NnRPEGm5SxCLMZEbHUduqJnaDkm5+XCEkI9GlDouFt7Kwn/douLzid6Ul
	whdCtHLBxsASclRCi5TjmiLszxRdZYbbKHt6fpwBAnqVKOlYe8Jl37/s2UYOmR9jd2ifD2hoimwUP
	0SAcqRWlEGFAr+rKnTe3tHJPajaWRooA3tQa+nW3UewI+ikRLRu3xdrXJCvh4EAMIJYvq2AxNi1p9
	P1FOpCBtw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hp9M6-0004zx-Kc; Sun, 21 Jul 2019 10:46:14 +0000
From: Matthew Wilcox <willy@infradead.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH v2 0/3] Make working with compound pages easier
Date: Sun, 21 Jul 2019 03:46:09 -0700
Message-Id: <20190721104612.19120-1-willy@infradead.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

These three patches add three helpers and convert the appropriate
places to use them.

v2:
 - Add page_shift() and compound_nr()
 - Remove unsigned long cast from PAGE_SIZE as it is already unsigned long
 - Update to current Linus tree

Matthew Wilcox (Oracle) (3):
  mm: Introduce page_size()
  mm: Introduce page_shift()
  mm: Introduce compound_nr()

 arch/arm/include/asm/xen/page-coherent.h      |  3 +--
 arch/arm/mm/flush.c                           |  7 +++----
 arch/arm64/include/asm/xen/page-coherent.h    |  3 +--
 arch/arm64/mm/flush.c                         |  3 +--
 arch/ia64/mm/init.c                           |  2 +-
 arch/powerpc/mm/book3s64/iommu_api.c          |  7 ++-----
 arch/powerpc/mm/hugetlbpage.c                 |  2 +-
 drivers/crypto/chelsio/chtls/chtls_io.c       |  5 ++---
 drivers/staging/android/ion/ion_system_heap.c |  4 ++--
 drivers/target/tcm_fc/tfc_io.c                |  3 +--
 drivers/vfio/vfio_iommu_spapr_tce.c           |  2 +-
 fs/io_uring.c                                 |  2 +-
 fs/proc/task_mmu.c                            |  2 +-
 include/linux/hugetlb.h                       |  2 +-
 include/linux/mm.h                            | 18 ++++++++++++++++++
 lib/iov_iter.c                                |  2 +-
 mm/compaction.c                               |  2 +-
 mm/filemap.c                                  |  2 +-
 mm/gup.c                                      |  2 +-
 mm/hugetlb_cgroup.c                           |  2 +-
 mm/kasan/common.c                             | 10 ++++------
 mm/memcontrol.c                               |  4 ++--
 mm/memory_hotplug.c                           |  4 ++--
 mm/migrate.c                                  |  2 +-
 mm/nommu.c                                    |  2 +-
 mm/page_alloc.c                               |  2 +-
 mm/page_vma_mapped.c                          |  3 +--
 mm/rmap.c                                     |  9 +++------
 mm/shmem.c                                    |  8 ++++----
 mm/slob.c                                     |  2 +-
 mm/slub.c                                     | 18 +++++++++---------
 mm/swap_state.c                               |  2 +-
 mm/util.c                                     |  2 +-
 mm/vmscan.c                                   |  4 ++--
 net/xdp/xsk.c                                 |  2 +-
 35 files changed, 76 insertions(+), 73 deletions(-)

-- 
2.20.1

