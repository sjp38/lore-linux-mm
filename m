Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id CE8C56B0009
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 00:17:14 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id t27so3071278qki.11
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 21:17:14 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id j35si1613235qtk.160.2018.03.28.21.17.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 21:17:13 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 0/1] fix regression in hugetlbfs overflow checking
Date: Wed, 28 Mar 2018 21:16:55 -0700
Message-Id: <20180329041656.19691-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Nic Losby <blurbdust@gmail.com>, Dan Rue <dan.rue@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

Commit 63489f8e8211 ("hugetlbfs: check for pgoff value overflow")
introduced a regression in 32 bit kernels.  When creating the mask
to check vm_pgoff, it incorrectly specified that the size of a loff_t
was the size of a long.  This prevents mapping hugetlbfs files at
offsets greater than 4GB on 32 bit kernels.

The above is in the commit message.  63489f8e8211 has been sent upstream
and to stable, so cc'ing stable here as well.

I would appreciate some more eyes on this code.  There have been several
fixes and we keep running into issues.

Mike Kravetz (1):
  hugetlbfs: fix bug in pgoff overflow checking

 fs/hugetlbfs/inode.c | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

-- 
2.13.6
