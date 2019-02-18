Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46EB6C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 21:14:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06DD521900
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 21:14:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="pFLKKDiO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06DD521900
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 936B88E0003; Mon, 18 Feb 2019 16:14:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E3A78E0002; Mon, 18 Feb 2019 16:14:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D36E8E0003; Mon, 18 Feb 2019 16:14:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 39C8A8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 16:14:38 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id y2so13366718plr.8
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:14:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:cc
         :subject:in-reply-to:references:message-id;
        bh=eoDF//MAOx0SYGCby4nSIyVisNwGzr4z2uZZnM4yBds=;
        b=AzzBSzbwWaDUG8M/beIzr5CGQim2qEukRHx4BO3s1hE2hbWK42VN7YSN6UJSKoxj+q
         9CHMB0cZZ8Xuclp2CKuuoYtAOTqM5mgoP8+coy1CCaWtcyxMDEbeQyLhUcDZG3GYTOjm
         gVBTJ3CU7iNIUFpDjc6SLfoNozSIPy4itagVO7vn0qUPtiACE+z1ycS8L00HbA2LnYeH
         sqz+2cEXXQHw4/spbrs+2qHon/43ZN2sAkUUCAStlNrkQznurw7griw5saMj0DFEyTA9
         kuWENwvDqsGZkzu69QPqnDnktXQ5AvMKsJp6gcAZZD8RiDS62mYkdNxL9+ptbBZMl3eo
         im8A==
X-Gm-Message-State: AHQUAuZhXErs4+Sfsjt1XukUdWWZII33+4sHN6AQHxyIFpLNRv+xdoOb
	VFiXjfPpuHvKgcXSvX/PLj1UdvwgSlxRTEkUc3rvCzWWRkUwDoCSxAKWqAbEZVcHNpCX/ka7AOf
	Jz5WlaBw5H39YhN0WOIKG9GSyo9XDhsgMML4jVtv+xscjG/k1kmYpHIs4o3gHze/m5A==
X-Received: by 2002:a62:2a4b:: with SMTP id q72mr25885775pfq.61.1550524477798;
        Mon, 18 Feb 2019 13:14:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZP0ueRqP4lf8nuXzv0eW+1eZJr/Pbz8LQ3Ju+0elJSA+cxCoNGcCqNPaD+xWdvX0oCZCVi
X-Received: by 2002:a62:2a4b:: with SMTP id q72mr25885716pfq.61.1550524476887;
        Mon, 18 Feb 2019 13:14:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550524476; cv=none;
        d=google.com; s=arc-20160816;
        b=XhhD6BnEWe4JMYnRkEyHSi2ImmKMPJz/Sn4sJwFY2szEPSEutxKmUsu8rkqbglJcuk
         ohLpPI2KYT73hJdCn7LMUSepTddZPbWKZU//4eYoVo1YQZWMdw/F67nziTZDMLb/jGEy
         FE11R3uNJIkKd/xGKiSg4ji4uvd1ja7rduiggf5SadKX4xVppnAG6CQuiIF2U+xG8W6D
         gge2cJ69rzDZg7iU8MNA+M1xeNC48PRFznTyhSQxTmxNkOxKsXPk8z6ftBjNvhp/31S7
         Dzryr/3GP7UQBrSQ2aEGlsOWwC9hA/K1VHYQSSQEUs5o5m9dGN3txkaIAl36CH99Gzw4
         uv3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:cc:to:to:to:from
         :date:dkim-signature;
        bh=eoDF//MAOx0SYGCby4nSIyVisNwGzr4z2uZZnM4yBds=;
        b=gOPKNykOM6rkgLnBhB3qx7nhqp2DUTjuU9r33ZOVzFpYeT7q331UuDCiRvejc3EgOI
         qIpSmdrhaji2BeQ+W83cdaaEKw3AyBP+rzXxnjLcZS9Ts7AwSdTx1lhAkA7+AqrtFCpE
         smUEd03MLE2mns07rtSMX8koe7+QtVXsuavJBzujrXMTWts9tZ/IZIGzbTkAQdpgCQTJ
         WakyQ2TyS+c0hsAfoMlgHWaeUq5weJgmDn0r9REjYl1pQ6P1/F0lxYgxDtAccrlVCk03
         T6FJLbx9RogxM0BK7h0lJyCmNuWZCWiJ5bJfbl5+8uZF+d5qPUbc8OIOyJUZEO6JYAul
         mIIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=pFLKKDiO;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q6si13994266pgq.442.2019.02.18.13.14.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 13:14:36 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=pFLKKDiO;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5656021900;
	Mon, 18 Feb 2019 21:14:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550524476;
	bh=jErfl/TWNCyPZbjdyaVAUeYNsbEH/3N3G2dJ1zXexg4=;
	h=Date:From:To:To:To:Cc:Cc:Cc:Subject:In-Reply-To:References:From;
	b=pFLKKDiOI/fJAPBuierQ29dDh4mveF07V1E+X2pEd6f4KDwiGa33IQ+l6R1DDAl1T
	 pssAWgKxKVsgrTr+QVEcOnOS7bwP36aICMNdtTYrDsljolhXVkck21AVWo+cc2wjn9
	 GWwGkCIBHHhT0c4Hr3xPre/Py94FukX0mmUBaSCI=
Date: Mon, 18 Feb 2019 21:14:35 +0000
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
Message-Id: <20190218211436.5656021900@mail.kernel.org>
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

