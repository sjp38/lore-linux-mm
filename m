Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id CC85B6B0038
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 16:32:09 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id i14so2858898qke.6
        for <linux-mm@kvack.org>; Fri, 22 Sep 2017 13:32:09 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d55si586826qtd.113.2017.09.22.13.32.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Sep 2017 13:32:08 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8MKVqxx081770
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 16:32:07 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2d5614hjtq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 16:32:07 -0400
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Fri, 22 Sep 2017 16:32:06 -0400
Date: Fri, 22 Sep 2017 15:31:57 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/device-public-memory: Enable move_pages() to stat
 device memory
References: <1506111236-28975-1-git-send-email-arbab@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <1506111236-28975-1-git-send-email-arbab@linux.vnet.ibm.com>
Message-Id: <20170922203157.4txavkwmvyh2ufmd@arbab-laptop.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Dave Jiang <dave.jiang@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Huang Ying <ying.huang@intel.com>, Ingo Molnar <mingo@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, James Morse <james.morse@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 22, 2017 at 08:13:56PM +0000, Reza Arbab wrote:
>The move_pages() syscall can be used to find the numa node where a page
>currently resides. This is not working for device public memory pages,
>which erroneously report -EFAULT (unmapped or zero page).

Argh. Please disregard this patch.

My test setup has a chunk of system memory carved out as pretend device 
public memory, to experiment with. Of course the real thing has no numa 
node!

Apologies all, it's been a long day.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
