Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 57A2A6B0038
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 04:41:51 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 9so763524ion.22
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 01:41:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 16sor2248536itj.6.2017.11.17.01.41.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 Nov 2017 01:41:48 -0800 (PST)
Date: Fri, 17 Nov 2017 01:41:46 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm: show total hugetlb memory consumption in
 /proc/meminfo
In-Reply-To: <20171115231409.12131-1-guro@fb.com>
Message-ID: <alpine.DEB.2.10.1711170141260.98384@chino.kir.corp.google.com>
References: <20171115231409.12131-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Wed, 15 Nov 2017, Roman Gushchin wrote:

> Currently we display some hugepage statistics (total, free, etc)
> in /proc/meminfo, but only for default hugepage size (e.g. 2Mb).
> 
> If hugepages of different sizes are used (like 2Mb and 1Gb on x86-64),
> /proc/meminfo output can be confusing, as non-default sized hugepages
> are not reflected at all, and there are no signs that they are
> existing and consuming system memory.
> 
> To solve this problem, let's display the total amount of memory,
> consumed by hugetlb pages of all sized (both free and used).
> Let's call it "Hugetlb", and display size in kB to match generic
> /proc/meminfo style.
> 
> For example, (1024 2Mb pages and 2 1Gb pages are pre-allocated):
>   $ cat /proc/meminfo
>   MemTotal:        8168984 kB
>   MemFree:         3789276 kB
>   <...>
>   CmaFree:               0 kB
>   HugePages_Total:    1024
>   HugePages_Free:     1024
>   HugePages_Rsvd:        0
>   HugePages_Surp:        0
>   Hugepagesize:       2048 kB
>   Hugetlb:         4194304 kB
>   DirectMap4k:       32632 kB
>   DirectMap2M:     4161536 kB
>   DirectMap1G:     6291456 kB
> 
> Also, this patch updates corresponding docs to reflect
> Hugetlb entry meaning and difference between Hugetlb and
> HugePages_Total * Hugepagesize.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: kernel-team@fb.com
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org

Acked-by: David Rientjes <rientjes@google.com>

Nice!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
