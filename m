Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1B8FC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 15:48:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C4342192D
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 15:48:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="l4O8Pn2G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C4342192D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E43A8E0002; Fri, 15 Feb 2019 10:48:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 394228E0001; Fri, 15 Feb 2019 10:48:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 282C28E0002; Fri, 15 Feb 2019 10:48:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D53638E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 10:48:43 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id p20so7074464plr.22
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 07:48:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:cc
         :subject:in-reply-to:references:message-id;
        bh=eoDF//MAOx0SYGCby4nSIyVisNwGzr4z2uZZnM4yBds=;
        b=pTafBpmUYdTKe9Q9AjCIBtEVYCIG1IzJJAGioUJP0NG7iyTOGShfiUnQKpmc7c8iAR
         XhMpdMZpuWmuT0lwNMQRpFUvwbml+EPEfsKCfcumn71EdnbuS6Dt2gL/g6OP8gwVVX46
         +V+FkrIH60RBddFbnEu+YrQVWJvXaalSDqROra2FALEdN567vMoB+cjIJie/MxzLGy2D
         OW72j48/2aolXo7Ou1GLDfwkIDBt/Vmtcn4Tnj/4/kp7mu4LVmz5VDKSr8OE+9y8weme
         897meCSIp0US6TXHwc1mNAzQHlrPnfNcC6TyFkG7NCS8ftY5NPyb+PNz9MBiWrMayw+i
         0Dzg==
X-Gm-Message-State: AHQUAuZm4nCJEMhSXwSudpr3DZgGRK1GkMFMc8puvFK91bDLeHZLBrXz
	BfZafQpmDatKJxjSQ58yRWMXdadC+uyekZ6BA7eBcELhJjdZ8yM3Wg66TtYDd+9hRe6Y0ihf1Pr
	7AhiNmjt4ufklSj08XugWQQkXgZTIn/vTaUwvxPrwYMffld1PgfsXopa9I8bBnGGq8g==
X-Received: by 2002:a63:454a:: with SMTP id u10mr9575487pgk.224.1550245723258;
        Fri, 15 Feb 2019 07:48:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYTQne+eEC0ubLmr11kweCqUatgMYc61DCdkCeUyxDtG7tv/X/548K03qitYDhrzL56M6/U
X-Received: by 2002:a63:454a:: with SMTP id u10mr9575410pgk.224.1550245722425;
        Fri, 15 Feb 2019 07:48:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550245722; cv=none;
        d=google.com; s=arc-20160816;
        b=h86XDujspwpD3VwQV97JZy1kl/iJqBv1CbWJhh/2PrVbn+HkEowzs1Nx6ACkjl4+u1
         eHv+sFR69V2z1wHGNtoym8opxS9mz6GeZapKMXZWcB5FYUgBotbbMm2Cwayv30sYwVJO
         7jne53vANsoArSXWXUKTX93zwqSxM/z5POQrf9R6OMtqPsPupar5ZLvUpoNWG3B2t7kG
         jJbPejETk1FroIil8HjWbvPn3Q1Cje+YppeibMES6VxflhH4XjIi9TCSzmP/JClfQs/G
         fkotRP2sm90ZKt5XfOkP5cUH+qxOu5tutSbzzrLGOvsa/ClJ5fl7GyjzfuowySwVk7UC
         0gsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:cc:to:to:to:from
         :date:dkim-signature;
        bh=eoDF//MAOx0SYGCby4nSIyVisNwGzr4z2uZZnM4yBds=;
        b=nzMTmkIoHDAThFAoO6Pxp9L4ZOWEall2C7w8qk22nlOZfgSl3ZK5AglqibtG7NoUBv
         P1mHRJb3JLtTGTpxQ0sDOEPjVW3cilciaw5x2puwS8UWzwspnDCIjE7AyjSy4uLylTS+
         lrsufBaelGylnAFmcurc5LgKK/wWtFX3HVsmm5azKC3IjQE/rLVjI7MRwpZohIRJJpXI
         oRfLSw1NhxLWG4Hqx1MuQj2yMVGeQk5eMCs6N15mXScXhVxG8p6XBOCZZ6vcvH3HldBn
         0YXN+SNdCgGo8c4u+GBFp0+Wr90GJSn93Pvw9Qwv9dXT6qt6F7UZWPwFeIDhpEHoFQzh
         JMWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=l4O8Pn2G;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q17si470578pfi.248.2019.02.15.07.48.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 07:48:42 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=l4O8Pn2G;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D66E22192D;
	Fri, 15 Feb 2019 15:48:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550245722;
	bh=jErfl/TWNCyPZbjdyaVAUeYNsbEH/3N3G2dJ1zXexg4=;
	h=Date:From:To:To:To:Cc:Cc:Cc:Subject:In-Reply-To:References:From;
	b=l4O8Pn2GxfPw03ZAQsq0ceTJa6OcOC5/050IfoFkdC741YOokC6uP93x6PrQGPK70
	 IawJhsTsqHFixcmgcYm8YTGnphpRzfmVe+eXbPYnkq7emakEe5rmwe0+pvlzJvCwWN
	 Vf2adiK/Y5m+u14K8K+vxM8Ihvs5Q3lBRfk27g9I=
Date: Fri, 15 Feb 2019 15:48:41 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To:   Mike Kravetz <mike.kravetz@oracle.com>
To:     linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc:     Michal Hocko <mhocko@kernel.org>,
Cc: <stable@vger.kernel.org>
Cc: stable@vger.kernel.org
Subject: Re: [PATCH] huegtlbfs: fix races and page leaks during migration
In-Reply-To: <20190212221400.3512-1-mike.kravetz@oracle.com>
References: <20190212221400.3512-1-mike.kravetz@oracle.com>
Message-Id: <20190215154841.D66E22192D@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: bcc54222309c mm: hugetlb: introduce page_huge_active.

The bot has tested the following trees: v4.20.8, v4.19.21, v4.14.99, v4.9.156, v4.4.174, v3.18.134.

v4.20.8: Build OK!
v4.19.21: Build OK!
v4.14.99: Failed to apply! Possible dependencies:
    5b7a1d406062 ("mm, hugetlbfs: rename address to haddr in hugetlb_cow()")

v4.9.156: Failed to apply! Possible dependencies:
    2916ecc0f9d4 ("mm/migrate: new migrate mode MIGRATE_SYNC_NO_COPY")
    369cd2121be4 ("userfaultfd: hugetlbfs: userfaultfd_huge_must_wait for hugepmd ranges")
    5b7a1d406062 ("mm, hugetlbfs: rename address to haddr in hugetlb_cow()")
    7868a2087ec1 ("mm/hugetlb: add size parameter to huge_pte_offset()")
    82b0f8c39a38 ("mm: join struct fault_env and vm_fault")
    8fb5debc5fcd ("userfaultfd: hugetlbfs: add hugetlb_mcopy_atomic_pte for userfaultfd support")
    953c66c2b22a ("mm: THP page cache support for ppc64")
    fd60775aea80 ("mm, thp: avoid unlikely branches for split_huge_pmd")

v4.4.174: Failed to apply! Possible dependencies:
    09cbfeaf1a5a ("mm, fs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros")
    0e749e54244e ("dax: increase granularity of dax_clear_blocks() operations")
    2916ecc0f9d4 ("mm/migrate: new migrate mode MIGRATE_SYNC_NO_COPY")
    2a28900be206 ("udf: Export superblock magic to userspace")
    4420cfd3f51c ("staging: lustre: format properly all comment blocks for LNet core")
    48b4800a1c6a ("zsmalloc: page migration support")
    5057dcd0f1aa ("virtio_balloon: export 'available' memory to balloon statistics")
    52db400fcd50 ("pmem, dax: clean up clear_pmem()")
    5b7a487cf32d ("f2fs: add customized migrate_page callback")
    5fd88337d209 ("staging: lustre: fix all conditional comparison to zero in LNet layer")
    a188222b6ed2 ("net: Rename NETIF_F_ALL_CSUM to NETIF_F_CSUM_MASK")
    b1123ea6d3b3 ("mm: balloon: use general non-lru movable page feature")
    b2e0d1625e19 ("dax: fix lifetime of in-kernel dax mappings with dax_map_atomic()")
    bda807d44454 ("mm: migrate: support non-lru movable page migration")
    c8b8e32d700f ("direct-io: eliminate the offset argument to ->direct_IO")
    d1a5f2b4d8a1 ("block: use DAX for partition table reads")
    e10624f8c097 ("pmem: fail io-requests to known bad blocks")

v3.18.134: Failed to apply! Possible dependencies:
    0722b1011a5f ("f2fs: set page private for inmemory pages for truncation")
    1601839e9e5b ("f2fs: fix to release count of meta page in ->invalidatepage")
    2916ecc0f9d4 ("mm/migrate: new migrate mode MIGRATE_SYNC_NO_COPY")
    31a3268839c1 ("f2fs: cleanup if-statement of phase in gc_data_segment")
    34ba94bac938 ("f2fs: do not make dirty any inmemory pages")
    34d67debe02b ("f2fs: add infra struct and helper for inline dir")
    4634d71ed190 ("f2fs: fix missing kmem_cache_free")
    487261f39bcd ("f2fs: merge {invalidate,release}page for meta/node/data pages")
    5b7a487cf32d ("f2fs: add customized migrate_page callback")
    67298804f344 ("f2fs: introduce struct inode_management to wrap inner fields")
    769ec6e5b7d4 ("f2fs: call radix_tree_preload before radix_tree_insert")
    7dda2af83b2b ("f2fs: more fast lookup for gc_inode list")
    8b26ef98da33 ("f2fs: use rw_semaphore for nat entry lock")
    8c402946f074 ("f2fs: introduce the number of inode entries")
    9be32d72becc ("f2fs: do retry operations with cond_resched")
    9e4ded3f309e ("f2fs: activate f2fs_trace_pid")
    d5053a34a9cc ("f2fs: introduce -o fastboot for reducing booting time only")
    e5e7ea3c86e5 ("f2fs: control the memory footprint used by ino entries")
    f68daeebba5a ("f2fs: keep PagePrivate during releasepage")


How should we proceed with this patch?

--
Thanks,
Sasha

