Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF8C6B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 03:27:29 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g46so5249278wrd.3
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 00:27:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m32si114450wrm.214.2017.06.14.00.27.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 00:27:27 -0700 (PDT)
Date: Wed, 14 Jun 2017 09:27:25 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/hugetlb: Warn the user when issues arise on boot due
 to hugepages
Message-ID: <20170614072725.GH6045@dhcp22.suse.cz>
References: <20170606054917.GA1189@dhcp22.suse.cz>
 <20170606060147.GB1189@dhcp22.suse.cz>
 <20170612172829.bzjfmm7navnobh4t@oracle.com>
 <20170612174911.GA23493@dhcp22.suse.cz>
 <20170612183717.qgcusdfvdfcj7zr7@oracle.com>
 <20170612185208.GC23493@dhcp22.suse.cz>
 <20170613013516.7fcmvmoltwhxmtmp@oracle.com>
 <20170613054204.GB5363@dhcp22.suse.cz>
 <20170613152501.w27r2q2agy4sue5x@oracle.com>
 <a855a155-c952-ac6b-04b9-aa7869403c52@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a855a155-c952-ac6b-04b9-aa7869403c52@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "Liam R. Howlett" <Liam.Howlett@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, zhongjiang@huawei.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com

On Tue 13-06-17 09:26:15, Mike Kravetz wrote:
> A thought somewhat related to this discussion:
> 
> I noticed that huge pages specified on the kernel command line are allocated
> via 'subsys_initcall'.  This is before 'fs_initcall', even though these huge
> pages are only used by hugetlbfs.  Was just thinking that it might be better
> to move huge page allocations to later in the init process.  At least make
> them part of fs_initcall if not late_initcall?
> 
> Only reason for doing this is because huge page allocations are fairly
> tolerant of allocation failure.

I am not really familiar with the initcall hierarchy to be honest. I
even do not understand what relattion does fs_initcall have to
allocation failures. Could you be more specific?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
