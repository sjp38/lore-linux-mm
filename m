Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id E3F1C6B02FD
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 12:27:00 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 20so67916846qtq.2
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 09:27:00 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id w55si399344qtc.102.2017.06.13.09.26.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 09:27:00 -0700 (PDT)
Subject: Re: [PATCH] mm/hugetlb: Warn the user when issues arise on boot due
 to hugepages
References: <20170605045725.GA9248@dhcp22.suse.cz>
 <20170605151541.avidrotxpoiekoy5@oracle.com>
 <20170606054917.GA1189@dhcp22.suse.cz> <20170606060147.GB1189@dhcp22.suse.cz>
 <20170612172829.bzjfmm7navnobh4t@oracle.com>
 <20170612174911.GA23493@dhcp22.suse.cz>
 <20170612183717.qgcusdfvdfcj7zr7@oracle.com>
 <20170612185208.GC23493@dhcp22.suse.cz>
 <20170613013516.7fcmvmoltwhxmtmp@oracle.com>
 <20170613054204.GB5363@dhcp22.suse.cz>
 <20170613152501.w27r2q2agy4sue5x@oracle.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <a855a155-c952-ac6b-04b9-aa7869403c52@oracle.com>
Date: Tue, 13 Jun 2017 09:26:15 -0700
MIME-Version: 1.0
In-Reply-To: <20170613152501.w27r2q2agy4sue5x@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liam R. Howlett" <Liam.Howlett@oracle.com>, Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, zhongjiang@huawei.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com

A thought somewhat related to this discussion:

I noticed that huge pages specified on the kernel command line are allocated
via 'subsys_initcall'.  This is before 'fs_initcall', even though these huge
pages are only used by hugetlbfs.  Was just thinking that it might be better
to move huge page allocations to later in the init process.  At least make
them part of fs_initcall if not late_initcall?

Only reason for doing this is because huge page allocations are fairly
tolerant of allocation failure.

Of course, I could be missing some init dependency.
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
