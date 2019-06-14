Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C071DC31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 21:56:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5EE8121852
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 21:56:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="raIMRqF1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5EE8121852
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C17B26B0008; Fri, 14 Jun 2019 17:56:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA0CB6B000C; Fri, 14 Jun 2019 17:56:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A420A6B000D; Fri, 14 Jun 2019 17:56:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 687056B0008
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 17:56:34 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f1so2680296pfb.0
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 14:56:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:cc
         :subject:in-reply-to:references:message-id;
        bh=hwBde/SMLrHhHCvgxQz29KDiKeNrkZ8rDx62rDp3sHE=;
        b=O4YCcPSirnU03e1Dd8zRcUOaxXO0zLAVV15PkWIz8h+4gXDttFv5co9b3BI78jxtk0
         xJoDC+Yj242mgT6atzWfTdLqi25+eR0QAhVQEWUm4PyS5f1scpuFo1wYBivu+OQ9okNa
         Ac2+wX4cQIxVrUKkN0Co0mco8tDzed9RLJ7t0OZ6zPhklW5Zv25daFxXbUwecPaeCC6N
         qmPjD3t0zTkoLhkjk4DI+2Mo3WpKT82+r/318XhnWZQlFZofUfSJzOHF3AY2EEhmeGyF
         vuui+8i6U7C7sw0e+EsNZOeoWJcZRY4DijjGKgV/ZyoSRKJR6gEHsHrCVVz8SxdzrXwy
         lVLQ==
X-Gm-Message-State: APjAAAWInGqZLpo6qj6N8UrPa6ypTmve2P01f/Hf4PfdJSNypMKfuY4l
	Itrn6ANGzdyR0pD5Igo5nHorij9evfTZe5Tb+HSZqZhygDxZdujVa2/Yg61MniWXfXc0LdMe5bQ
	jeyQLNnuQyBweOIA6h5PfDVUF56PpB+svDOpbbg+/PjqWvx/a+rQnwjr//sF99jaGFw==
X-Received: by 2002:a17:902:8f81:: with SMTP id z1mr28906623plo.290.1560549393981;
        Fri, 14 Jun 2019 14:56:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgoPUxlk3RibZz66em3wYrsmZW7lOQ8zm9LdgSY9vG3uXkhbp/oWF2GCqFmQEdxj/FUM/s
X-Received: by 2002:a17:902:8f81:: with SMTP id z1mr28906603plo.290.1560549393397;
        Fri, 14 Jun 2019 14:56:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560549393; cv=none;
        d=google.com; s=arc-20160816;
        b=QJykQjNpBTF/+Y3Uc5nXOduc5zugK4PZZNIDd1AG15+dIsg4R0wzubSDN/EriH8rX6
         SD5Ze8Osc/XDj9Zh1HuvJfu6KgJDaOxIKpiKKYnbW6uqv2l3XB5zTWU2Dp4V/MLDuFIj
         NTeI0xy0d521tnJ/wt2QhNd0v78sYpwYXmh/MJkq/MMuq8qbASEsuBZeoe2DPGHcSCYo
         QNMvEuZ4GXhgqkXsPF1a97Bci9sQcXH1tkt/i6FUNEKnse1y5B1A9kvktaAxBf1pkvVf
         GbtEE5p191BoPcyGPXKZo3O2gLIYddh8D6h4Qp6UWBMBKHNziDue5Wbq6rmMmpFVoUKa
         v27A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:cc:to:to:to:from
         :date:dkim-signature;
        bh=hwBde/SMLrHhHCvgxQz29KDiKeNrkZ8rDx62rDp3sHE=;
        b=slM2hH2YEnRNnsHKBTutVDBnPUtDmUlPMEZKENLNL93PHCRihdkitq62VVbnxopZxu
         03nj5WPvXIPb6nBv0veTQxGXH77MoKWDUDc5rCxFLf05hf0LmqnYtIe0AIfzBtl41qrx
         q7XXfKzp1tuOw+jBgIsuJ/HX72ZXmcKUAOATtEXm7ML0MHeGRydVyJsJSE3nMT2hKaCa
         locCoxB2g+XwsJ9f1+TXC/fUeDbM4DtFMAVVBpTSIGR8ntEk0QUNCZufFWLe75YRBrEu
         GuBOMWWEVaO7vWbdPJ05aYCxTSaU6N3zIXOwwdDWlXn3eNvdBwjmWN8OLIe8umFf6t/y
         4EHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=raIMRqF1;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n26si3435592pgv.264.2019.06.14.14.56.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 14:56:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=raIMRqF1;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id BF5F721473;
	Fri, 14 Jun 2019 21:56:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560549393;
	bh=herjBvh4t8HYh0xFBwW8V/rg6wEBBupnA3gm5tZ8t8Y=;
	h=Date:From:To:To:To:Cc:Cc:Cc:Subject:In-Reply-To:References:From;
	b=raIMRqF1KeJ9NvTmq6ZTd7d0i6yYO+dPRLyBR507DZF5tpcirMtb1qBB1hXr1/wLy
	 opqDYjQWy5fsTDJZvTkPLAVUPajM8KJC4Ubjm8NU7kN/Ncg3eEOBu73ZSdTu90m1kv
	 UzxIExIklsFVwhIGYS9jwnX/JGiip5OZs0p30glw=
Date: Fri, 14 Jun 2019 21:56:31 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To:   Mike Kravetz <mike.kravetz@oracle.com>
To:     linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc:     Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>,
Cc: <stable@vger.kernel.org>
Cc: stable@vger.kernel.org
Subject: Re: [PATCH 2/3] hugetlbfs: Use i_mmap_rwsem to fix page fault/truncate race
In-Reply-To: <20181203200850.6460-3-mike.kravetz@oracle.com>
References: <20181203200850.6460-3-mike.kravetz@oracle.com>
Message-Id: <20190614215632.BF5F721473@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: ebed4bfc8da8 [PATCH] hugetlb: fix absurd HugePages_Rsvd.

The bot has tested the following trees: v5.1.9, v4.19.50, v4.14.125, v4.9.181, v4.4.181.

v4.19.50: Build OK!
v4.14.125: Build OK!
v4.9.181: Build OK!
v4.4.181: Failed to apply! Possible dependencies:
    0070e28d97e7 ("radix_tree: loop based on shift count, not height")
    00f47b581105 ("radix-tree: rewrite radix_tree_tag_clear")
    0e749e54244e ("dax: increase granularity of dax_clear_blocks() operations")
    1366c37ed84b ("radix tree test harness")
    29f3ad7d8380 ("fs: Provide function to unmap metadata for a range of blocks")
    334fd34d76f2 ("vfs: Add page_cache_seek_hole_data helper")
    339e6353046d ("radix_tree: tag all internal tree nodes as indirect pointers")
    4aae8d1c051e ("mm/hugetlbfs: unmap pages if page fault raced with hole punch")
    52db400fcd50 ("pmem, dax: clean up clear_pmem()")
    72e2936c04f7 ("mm: remove unnecessary condition in remove_inode_hugepages")
    7fc9e4722435 ("fs: Introduce filemap_range_has_page()")
    83929372f629 ("filemap: prepare find and delete operations for huge pages")
    ac401cc78242 ("dax: New fault locking")
    b2e0d1625e19 ("dax: fix lifetime of in-kernel dax mappings with dax_map_atomic()")
    d604c324524b ("radix-tree: introduce radix_tree_replace_clear_tags()")
    d72dc8a25afc ("mm: make pagevec_lookup() update index")
    e4b274915863 ("DAX: move RADIX_DAX_ definitions to dax.c")
    e61452365372 ("radix_tree: add support for multi-order entries")
    f9fe48bece3a ("dax: support dirty DAX entries in radix tree")


How should we proceed with this patch?

--
Thanks,
Sasha

