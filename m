Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BA2AC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 14:00:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EAAC2147C
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 14:00:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="V1UKI0D3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EAAC2147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0C186B0006; Wed, 27 Mar 2019 10:00:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BAAF6B0007; Wed, 27 Mar 2019 10:00:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A9E26B0008; Wed, 27 Mar 2019 10:00:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5191D6B0006
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 10:00:53 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i14so9963108pfd.10
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 07:00:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:cc
         :subject:in-reply-to:references:message-id;
        bh=/3VFie/mtRYVN4o0Scd17ZzKe/cQqeI51+5QDoxhZTA=;
        b=dHsSHiR2qoE/081AYCQPYZcGoyKub0FyGla/aaBWx5uN4YEPqxdt8LiIen06rTv+3D
         fiL2oiLfijOvLqg0tAyYbOt01Tfkb3+CQFiqHULZyHy19uKBMF7JAepUGbIO8ivTTU7C
         Ol8pgps5NAnKyv4jugcgNud//FsegGXK+2RupQG4h7ODHUHa4rXB1grFAThflN4WIIfn
         EyeemD9uKunNshxVBHZJrYKP/KQml5BQST+mYF4UWrdrTtb/hE/Hq7CE7MWqQJOwYgBr
         VIAWZg6RJKuy+odljtS1d356pLS1vEjkcXt/7lyR26/XyLB5637rQTEV8iHDMAyDSje4
         Ib8A==
X-Gm-Message-State: APjAAAXwxI5ZxpEJiQp4xIdSe9dgEDwKtQhZgTiMK2Jj3EgL6flfgcpY
	6XJj+FLnTOmWMekZFvwv4bCyaZsRSIYyHtneSMnkTrPx8Cu3gZcqYnDUASC48HjCB9MlQo2QdN0
	TTXoXCCK6HLL3XLfiiG8o7oC5kyW/F2pFBDjGKGxnm5msWrRjrN43v8gccXhxHOEKNg==
X-Received: by 2002:a62:b418:: with SMTP id h24mr27022727pfn.145.1553695252893;
        Wed, 27 Mar 2019 07:00:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwyXc2nHvlCkJ5zxHHzQkbuySngfZwU4ikFjbo+xYdmYRIM2KMpf3vCnXL/HYFZw6pCvqD7
X-Received: by 2002:a62:b418:: with SMTP id h24mr27022667pfn.145.1553695252126;
        Wed, 27 Mar 2019 07:00:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553695252; cv=none;
        d=google.com; s=arc-20160816;
        b=mvRvAG5xxAceqDewHsYIhMjoYePbQrOFRJnW85pHCJHtxJQk7SwmjAycuUT558a49m
         fYtYFIBZh7JPoppBOxBoFm007AExk3UuZiOQ7p1FqGL5b5n/pGlPNq8jDhd/C19Cw2gD
         mIqKOQ6DB9owv7eaqy38wp7Ft9hV5lhCF6FLJb1US1IzGsTQSsVqasoa/TVv7QGtIQiw
         maSWq8kuVshAsHFBK0CYsFWPyTDY2m6AOaYpHumR5tZNBDGsceBhIGFDMRt/md+lvkkW
         sllwnWXV+ex5A4HsNuLMBdRMv7tSbvLJ1TJTishNvlF+ZspEI1Sp/7jLWIriItF5vyr5
         A1lA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:cc:to:to:to:from
         :date:dkim-signature;
        bh=/3VFie/mtRYVN4o0Scd17ZzKe/cQqeI51+5QDoxhZTA=;
        b=SMjfLWNHwmG/yGLCMEcTRrDPckbpjjGp0JQHTJULdu/fuyiiqJHKontPfqkL2n5TmN
         ahkcf+Pa/uhhornHezR7/ez1AFqN6fIPZC+yyWn6x9JN2vbJr+uXwyrqE/SaJGLjBXwI
         mfoqcGRogkE6otsWj/HP+B0jlchtGUUTtubePQ8DHe6SpJB/viW9l3O1GQ+X+ajngqYT
         d9KoImLYbfDNQRUt29wtNBiMSb9XSkp9KKEC4i2MkKlP4mHiYkc8iETVcQV16ftMid+J
         vh7eRN6LoHUlBJ3u1OpwpfwPqJz3XNzIIZwYxjYMJmPIbZPePETr91ls/s4Go4HetPvM
         aicg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=V1UKI0D3;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g74si18816014pfd.221.2019.03.27.07.00.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 07:00:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=V1UKI0D3;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7092C2087C;
	Wed, 27 Mar 2019 14:00:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553695251;
	bh=QiW0wjdXbtsw72g+6GWEmJJEiqlDXnbWFBpfmfEnOII=;
	h=Date:From:To:To:To:Cc:Cc:Cc:Subject:In-Reply-To:References:From;
	b=V1UKI0D3LnE4vzKqFkk0a3S2kXVjH2Mp77JplE7MmFcMzS0ufXK4NZHpEVwhpNdbN
	 ZRo08sV23NMHqxIqFwfFCCQw5sgN6mQGeiR3yDQND2W2oucgJqZS9cAjnDlDXw86Dt
	 /TiFR42pmtdqPfCYt4UvGG3ZqCYWvK6cIgejJ6c4=
Date: Wed, 27 Mar 2019 14:00:50 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To:   Dan Williams <dan.j.williams@intel.com>
To:     akpm@linux-foundation.org
Cc:     stable@vger.kernel.org, linux-mm@kvack.org,
Cc: <stable@vger.kernel.org>
Cc: stable@vger.kernel.org
Subject: Re: [PATCH v5 09/10] libnvdimm/pfn: Fix fsdax-mode namespace info-block zero-fields
In-Reply-To: <155327392164.225273.1248065676074470935.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155327392164.225273.1248065676074470935.stgit@dwillia2-desk3.amr.corp.intel.com>
Message-Id: <20190327140051.7092C2087C@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: 32ab0a3f5170 libnvdimm, pmem: 'struct page' for pmem.

The bot has tested the following trees: v5.0.4, v4.19.31, v4.14.108, v4.9.165, v4.4.177.

v5.0.4: Build OK!
v4.19.31: Failed to apply! Possible dependencies:
    48af2f7e52f4 ("libnvdimm, pfn: during init, clear errors in the metadata area")

v4.14.108: Failed to apply! Possible dependencies:
    48af2f7e52f4 ("libnvdimm, pfn: during init, clear errors in the metadata area")

v4.9.165: Failed to apply! Possible dependencies:
    48af2f7e52f4 ("libnvdimm, pfn: during init, clear errors in the metadata area")

v4.4.177: Failed to apply! Possible dependencies:
    0731de0dd95b ("libnvdimm, pfn: move 'memory mode' indication to sysfs")
    0bfb8dd3edd6 ("libnvdimm: cleanup nvdimm_namespace_common_probe(), kill 'host'")
    0caeef63e6d2 ("libnvdimm: Add a poison list and export badblocks")
    0e749e54244e ("dax: increase granularity of dax_clear_blocks() operations")
    2dc43331e34f ("libnvdimm, pfn: fix pfn seed creation")
    315c562536c4 ("libnvdimm, pfn: add 'align' attribute, default to HPAGE_SIZE")
    34c0fd540e79 ("mm, dax, pmem: introduce pfn_t")
    4b94ffdc4163 ("x86, mm: introduce vmem_altmap to augment vmemmap_populate()")
    52db400fcd50 ("pmem, dax: clean up clear_pmem()")
    87ba05dff351 ("libnvdimm: don't fail init for full badblocks list")
    9476df7d80df ("mm: introduce find_dev_pagemap()")
    9c41242817f4 ("libnvdimm: fix mode determination for e820 devices")
    ad9a8bde2cb1 ("libnvdimm, pmem: move definition of nvdimm_namespace_add_poison to nd.h")
    b2e0d1625e19 ("dax: fix lifetime of in-kernel dax mappings with dax_map_atomic()")
    b95f5f4391fa ("libnvdimm: convert to statically allocated badblocks")
    bd032943b5b2 ("libnvdimm, pfn, convert nd_pfn_probe() to devm")
    c5ed9268643c ("libnvdimm, dax: autodetect support")
    cd03412a51ac ("libnvdimm, dax: introduce device-dax infrastructure")
    cfe30b872058 ("libnvdimm, pmem: adjust for section collisions with 'System RAM'")
    d2c0f041e1bb ("libnvdimm, pfn, pmem: allocate memmap array in persistent memory")
    d9cbe09d39aa ("libnvdimm, pmem: fix 'pfn' support for section-misaligned namespaces")
    f6ed58c70d14 ("libnvdimm, pfn: 'resource'-address and 'size' attributes for pfn devices")
    f7c6ab80fa5f ("libnvdimm, pfn: clean up pfn create parameters")


How should we proceed with this patch?

--
Thanks,
Sasha

