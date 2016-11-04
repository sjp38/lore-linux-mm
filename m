Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 64DDA6B0271
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 21:59:21 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 17so16717702pfy.2
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 18:59:21 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00083.outbound.protection.outlook.com. [40.107.0.83])
        by mx.google.com with ESMTPS id c5si10778370paw.70.2016.11.03.18.59.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 03 Nov 2016 18:59:20 -0700 (PDT)
Date: Fri, 4 Nov 2016 09:59:10 +0800
From: Huang Shijie <shijie.huang@arm.com>
Subject: Re: [PATCH 0/2] mm: fix the "counter.sh" failure for libhugetlbfs
Message-ID: <20161104015909.GB19470@sha-win-210.asiapac.arm.com>
References: <1478141499-13825-1-git-send-email-shijie.huang@arm.com>
 <0a660010-5083-476a-b2c5-88d822089000@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <0a660010-5083-476a-b2c5-88d822089000@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On Thu, Nov 03, 2016 at 10:22:39AM -0700, Randy Dunlap wrote:
> On 11/02/16 19:51, Huang Shijie wrote:
> > 
> > (2) The bug   
> >    After I tested the libhugetlbfs, I found the test case "counter.sh"
> >    will fail with the gigantic page (32M page in arm64 board).
> > 
> >    This patch set adds support for gigantic surplus hugetlb pages,
> >    allowing the counter.sh unit test to pass.   
> 
> Hi,
> Where is the counter.sh test? Where can I find it?
You can get the libhugetlbfs from:
   https://github.com/libhugetlbfs/libhugetlbfs.git

Use the "make func" to test it, but the default libhugetlbfs can not run
for the 32M page hugetlbfs, there are several bugs in it. I have an
extra patch set to fix the libhugetlbfs bugs. Maybe I can send them out
later.

But for the 2M page size, you can test the "counter.sh" with "make
func".

thanks
Huang Shijie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
