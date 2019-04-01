Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46296C43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 10:49:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC5492086C
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 10:49:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="PxPJXavw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC5492086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 752A36B0006; Mon,  1 Apr 2019 06:49:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7027F6B0008; Mon,  1 Apr 2019 06:49:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F1FD6B000A; Mon,  1 Apr 2019 06:49:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E4CB6B0006
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 06:49:21 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id o4so7177753pgl.6
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 03:49:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:cc
         :subject:in-reply-to:references:message-id;
        bh=11ofV3QyH73FEL6fwv7JURbjfLWONhH50BGFff0qr8o=;
        b=JSXeuZpAj9JNIDaodpKjQRCkEUveTVJcCwkF/iLhK2RrKCD8aTfhFb5zjhTFJtYsiU
         6MUyruDtPTGCEgN1pVdBfken+02TbpQRQfWodufQPb5bJ57wtkSvDgj3xhlI86mvx2u7
         5rOXErQmFUngfPdO5NvD1k+19klIK1/v6aLw8pNp1jKpmkCdVA1YYYSDX0hfOLZ4fWlT
         1Ib/9HXZUcOLa5L6np13QPk8faLIztj9biciWMDuMKucd1SjiJQcS6V9mPPMxmrkXOm1
         0Cd4OfJKSOXLMNAMh+1UHnBj4rCbF4QBrrOZnN/NVkUdBCTE5d1x6jE7hW/CODVRUFSn
         xMIA==
X-Gm-Message-State: APjAAAW3JpjHuqQyF3umZBk8rDXNYTvnPaPHfWQUXh3mt8+o5T60sqSA
	Cqbc3OssYH6hmlMbWrTAM9K2HmxWJH53cdEXAnOP2kriGbPrVYipWICOGqzfnOOFfFfAqsYUEz2
	8w4yZxSZT5ECWkyPD+RwMOK1gn35kuTN3Txhie9PHgdQ6n4UA5xpCYEFor6qK01qTCQ==
X-Received: by 2002:a63:6a42:: with SMTP id f63mr33715932pgc.207.1554115760630;
        Mon, 01 Apr 2019 03:49:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwaWBZUcEKv8XzlmSeLtRbf+oEOjx1W6iTMwqrY3R7PZFXkTZq9/fUrv4Z1Wm0xI7y1qYQV
X-Received: by 2002:a63:6a42:: with SMTP id f63mr33715891pgc.207.1554115759802;
        Mon, 01 Apr 2019 03:49:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554115759; cv=none;
        d=google.com; s=arc-20160816;
        b=f0NqwBYiCUfwO/4fWNS6ZgRwYR5MCLBol33YbnLglXZlroNg+/KJRqSp30sSGGzWM0
         TQ2qAh9b9492TG+/Gy57ayd3Zl354v4sgF5gEt5jedqeO0FrwJXcWNiijsg54cZVLsEK
         czXw84D2hvweS5jKYUfLVc8BDBq1ajv65JN53hbxO0T69+XfN8rZezFDPzkkBXYJ5Jes
         NeKtinluYJwcG5kbMo8Vbk3geCu/sHjXSGvktY/UBYglU+XE3xeldP6ozHZN6VlHhZSj
         zCbmNjMpvv4R5hzliShoEZ9naP/5HHz9F0TQtJ+z6L6p2Rq5G4CZm5svsguYmYtgIid8
         f83Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:cc:to:to:to:from
         :date:dkim-signature;
        bh=11ofV3QyH73FEL6fwv7JURbjfLWONhH50BGFff0qr8o=;
        b=0XImVpSulZ0yKs7BsAmbX5dm8qN5hZljMYaEN6QvYWkLKCcC+L0ql8fmXqSzngElrY
         RTDaEm4CVcc+OnHX4we1YNO7v+Pr7nrGv6qdetT0Qb/Ev8qAzk4gO1DKzgb00TVmpq6r
         m14lAGYc40yzJnESiwNW2TVI+KgT06v3f7lYUFNFz/BVoYKWqbrADr0YAhPVfJ7vn2oc
         8gGj25dVdTuqaXCiDLPN/nq+QvXpM8zH8NoCUtyvAk0kNc79+7142gOhEyB+0SDGkPPq
         rrGDsXYtbmoGoF1IpT6OInGSPMM943yS2uZe4jHIan5ytchl45IgOYOb0wFjWVGKifN+
         GfLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=PxPJXavw;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d6si8559196plr.246.2019.04.01.03.49.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 03:49:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=PxPJXavw;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 334CD20896;
	Mon,  1 Apr 2019 10:49:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1554115759;
	bh=vnUMit8M0DWd8jI1vC6tTgc2wMeBJ5W5Xp8odrJ7KO8=;
	h=Date:From:To:To:To:Cc:CC:Cc:Subject:In-Reply-To:References:From;
	b=PxPJXavwNRlA/74l6tmnfH+009R0rLRFKujosQKXyv7U44wCffecFYtp0IhoXYcX7
	 9wG79lsWcUwv7Q0VfYile9CywWCSLAncjAktdJhTeeXDMaMTflFSIb/y7Oqr5J+fcH
	 8EbSaIVeV85LM2lGebNauYxOFL0/j2oMq9vA2Wug=
Date: Mon, 01 Apr 2019 10:49:18 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To:   "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To:     dan.j.williams@intel.com, akpm@linux-foundation.org,
Cc:     linux-nvdimm@lists.01.org, linux-mm@kvack.org,
CC: stable@vger.kernel.org
Cc: stable@vger.kernel.org
Subject: Re: [PATCH] mm: Fix modifying of page protection by insert_pfn_pmd()
In-Reply-To: <20190330054121.27831-1-aneesh.kumar@linux.ibm.com>
References: <20190330054121.27831-1-aneesh.kumar@linux.ibm.com>
Message-Id: <20190401104919.334CD20896@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a -stable tag.
The stable tag indicates that it's relevant for the following trees: all

The bot has tested the following trees: v5.0.5, v4.19.32, v4.14.109, v4.9.166, v4.4.177, v3.18.137.

v5.0.5: Build OK!
v4.19.32: Build OK!
v4.14.109: Build OK!
v4.9.166: Failed to apply! Possible dependencies:
    82b0f8c39a38 ("mm: join struct fault_env and vm_fault")
    953c66c2b22a ("mm: THP page cache support for ppc64")
    a00cc7d9dd93 ("mm, x86: add support for PUD-sized transparent hugepages")
    b5bc66b71310 ("mm: update mmu_gather range correctly")
    fd60775aea80 ("mm, thp: avoid unlikely branches for split_huge_pmd")

v4.4.177: Failed to apply! Possible dependencies:
    01871e59af5c ("mm, dax: fix livelock, allow dax pmd mappings to become writeable")
    01c8f1c44b83 ("mm, dax, gpu: convert vm_insert_mixed to pfn_t")
    0e749e54244e ("dax: increase granularity of dax_clear_blocks() operations")
    34c0fd540e79 ("mm, dax, pmem: introduce pfn_t")
    52db400fcd50 ("pmem, dax: clean up clear_pmem()")
    6077776b5908 ("bpf: split HAVE_BPF_JIT into cBPF and eBPF variant")
    a00cc7d9dd93 ("mm, x86: add support for PUD-sized transparent hugepages")
    b2e0d1625e19 ("dax: fix lifetime of in-kernel dax mappings with dax_map_atomic()")
    b329f95d70f3 ("ARM: 8479/2: add implementation for arm-smccc")
    e37e43a497d5 ("x86/mm/64: Enable vmapped stacks (CONFIG_HAVE_ARCH_VMAP_STACK=y)")
    f25748e3c34e ("mm, dax: convert vmf_insert_pfn_pmd() to pfn_t")

v3.18.137: Failed to apply! Possible dependencies:
    047fc8a1f9a6 ("libnvdimm, nfit, nd_blk: driver for BLK-mode access persistent memory")
    2a3746984c98 ("x86: Use new cache mode type in track_pfn_remap() and track_pfn_insert()")
    34c0fd540e79 ("mm, dax, pmem: introduce pfn_t")
    4c1eaa2344fb ("drivers/block/pmem: Fix 32-bit build warning in pmem_alloc()")
    5cad465d7fa6 ("mm: add vmf_insert_pfn_pmd()")
    61031952f4c8 ("arch, x86: pmem api for ensuring durability of persistent memory updates")
    62232e45f4a2 ("libnvdimm: control (ioctl) messages for nvdimm_bus and nvdimm devices")
    777783e0abae ("staging: android: binder: move to the "real" part of the kernel")
    957e3facd147 ("gcov: enable GCOV_PROFILE_ALL from ARCH Kconfigs")
    9e853f2313e5 ("drivers/block/pmem: Add a driver for persistent memory")
    9f53f9fa4ad1 ("libnvdimm, pmem: add libnvdimm support to the pmem driver")
    b94d5230d06e ("libnvdimm, nfit: initial libnvdimm infrastructure and NFIT support")
    cb389b9c0e00 ("dax: drop size parameter to ->direct_access()")
    dd22f551ac0a ("block: Change direct_access calling convention")
    e2e05394e4a3 ("pmem, dax: have direct_access use __pmem annotation")
    ec776ef6bbe1 ("x86/mm: Add support for the non-standard protected e820 type")
    f0dc089ce217 ("libnvdimm: enable iostat")
    f25748e3c34e ("mm, dax: convert vmf_insert_pfn_pmd() to pfn_t")


How should we proceed with this patch?

--
Thanks,
Sasha

