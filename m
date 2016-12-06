Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 082C66B0069
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 04:08:08 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id y16so22949879wmd.6
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 01:08:07 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id qj8si18769619wjb.165.2016.12.06.01.08.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Dec 2016 01:08:06 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB695aWR062830
	for <linux-mm@kvack.org>; Tue, 6 Dec 2016 04:08:05 -0500
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0b-001b2d01.pphosted.com with ESMTP id 275n9akm5b-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 06 Dec 2016 04:08:05 -0500
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 6 Dec 2016 02:08:04 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: make transparent hugepage size public
In-Reply-To: <alpine.LSU.2.11.1612052200290.13021@eggly.anvils>
References: <alpine.LSU.2.11.1612052200290.13021@eggly.anvils>
Date: Tue, 06 Dec 2016 14:37:54 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <877f7difx1.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org

Hugh Dickins <hughd@google.com> writes:

> Test programs want to know the size of a transparent hugepage.
> While it is commonly the same as the size of a hugetlbfs page
> (shown as Hugepagesize in /proc/meminfo), that is not always so:
> powerpc implements transparent hugepages in a different way from
> hugetlbfs pages, so it's coincidence when their sizes are the same;
> and x86 and others can support more than one hugetlbfs page size.
>
> Add /sys/kernel/mm/transparent_hugepage/hpage_pmd_size to show the
> THP size in bytes - it's the same for Anonymous and Shmem hugepages.
> Call it hpage_pmd_size (after HPAGE_PMD_SIZE) rather than hpage_size,
> in case some transparent support for pud and pgd pages is added later.

We have in /proc/meminfo

Hugepagesize:       2048 kB

Does it makes it easy for application to find THP page size also there ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
