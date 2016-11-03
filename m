Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD88F6B02D7
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 13:22:42 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ro13so25351162pac.7
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 10:22:42 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id x18si10672554pfi.296.2016.11.03.10.22.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 10:22:41 -0700 (PDT)
Subject: Re: [PATCH 0/2] mm: fix the "counter.sh" failure for libhugetlbfs
References: <1478141499-13825-1-git-send-email-shijie.huang@arm.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <0a660010-5083-476a-b2c5-88d822089000@infradead.org>
Date: Thu, 3 Nov 2016 10:22:39 -0700
MIME-Version: 1.0
In-Reply-To: <1478141499-13825-1-git-send-email-shijie.huang@arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <shijie.huang@arm.com>, akpm@linux-foundation.org, catalin.marinas@arm.com
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On 11/02/16 19:51, Huang Shijie wrote:
> 
> (2) The bug   
>    After I tested the libhugetlbfs, I found the test case "counter.sh"
>    will fail with the gigantic page (32M page in arm64 board).
> 
>    This patch set adds support for gigantic surplus hugetlb pages,
>    allowing the counter.sh unit test to pass.   

Hi,
Where is the counter.sh test? Where can I find it?

thanks.
-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
