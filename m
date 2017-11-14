Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE6EE6B0253
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 16:07:17 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id o88so11470468wrb.18
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 13:07:17 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p9si2215017edh.44.2017.11.14.13.07.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 Nov 2017 13:07:16 -0800 (PST)
Date: Tue, 14 Nov 2017 16:07:07 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: show total hugetlb memory consumption in
 /proc/meminfo
Message-ID: <20171114210707.GA31184@cmpxchg.org>
References: <20171114125026.7055-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171114125026.7055-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Tue, Nov 14, 2017 at 12:50:26PM +0000, Roman Gushchin wrote:
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
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: kernel-team@fb.com
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
