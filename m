Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 962976B6F03
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 08:54:57 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id p4so8971819pgj.21
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 05:54:57 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u6si18832691pfb.92.2018.12.04.05.54.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 05:54:56 -0800 (PST)
Date: Tue, 04 Dec 2018 13:54:55 +0000
From: Sasha Levin <sashal@kernel.org>
Subject: Re: [PATCH 2/3] hugetlbfs: Use i_mmap_rwsem to fix page fault/truncate race
In-Reply-To: <20181203200850.6460-3-mike.kravetz@oracle.com>
References: <20181203200850.6460-3-mike.kravetz@oracle.com>
Message-Id: <20181204135456.056B22082D@mail.kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sashal@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, stable@vger.kernel.orgstable@vger.kernel.org

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: ebed4bfc8da8 [PATCH] hugetlb: fix absurd HugePages_Rsvd.

The bot has tested the following trees: v4.19.6, v4.14.85, v4.9.142, v4.4.166, v3.18.128.

v4.19.6: Build OK!
v4.14.85: Build OK!
v4.9.142: Build OK!
v4.4.166: Failed to apply! Possible dependencies:
    Unable to calculate

v3.18.128: Failed to apply! Possible dependencies:
    1bfad99ab425 ("hugetlbfs: hugetlb_vmtruncate_list() needs to take a range to delete")
    1c5ecae3a93f ("hugetlbfs: add minimum size accounting to subpools")
    1dd308a7b49d ("mm/hugetlb: document the reserve map/region tracking routines")
    5e9113731a3c ("mm/hugetlb: add cache of descriptors to resv_map for region_add")
    83cde9e8ba95 ("mm: use new helper functions around the i_mmap_mutex")
    b5cec28d36f5 ("hugetlbfs: truncate_hugepages() takes a range of pages")
    c672c7f29f2f ("mm/hugetlb: expose hugetlb fault mutex for use by fallocate")
    cf3ad20bfead ("mm/hugetlb: compute/return the number of regions added by region_add()")
    feba16e25a57 ("mm/hugetlb: add region_del() to delete a specific range of entries")


How should we proceed with this patch?

--
Thanks,
Sasha
