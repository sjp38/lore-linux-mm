Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D265F828FF
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 03:43:43 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b65so7131120wmg.0
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 00:43:43 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id xq16si4557613wjb.123.2016.07.21.00.43.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jul 2016 00:43:41 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id i5so1508589wmg.2
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 00:43:41 -0700 (PDT)
Date: Thu, 21 Jul 2016 09:43:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-hugetlb-fix-race-when-migrate-pages.patch added to -mm tree
Message-ID: <20160721074340.GA26398@dhcp22.suse.cz>
References: <578eb28b.YbRUDGz5RloTVlrE%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <578eb28b.YbRUDGz5RloTVlrE%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: zhongjiang@huawei.com, qiuxishi@huawei.com, vbabka@suse.cz, mm-commits@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

We have further discussed the patch and I believe it is not correct. See [1].
I am proposing the following alternative.

[1] http://lkml.kernel.org/r/20160720132431.GM11249@dhcp22.suse.cz
---
