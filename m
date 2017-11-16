Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CC873280277
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 09:22:22 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id x63so94510wmf.6
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 06:22:22 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t22si1129850edm.436.2017.11.16.06.22.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 Nov 2017 06:22:21 -0800 (PST)
Date: Thu, 16 Nov 2017 09:22:16 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] mm: show total hugetlb memory consumption in
 /proc/meminfo
Message-ID: <20171116142152.GA21028@cmpxchg.org>
References: <20171115231409.12131-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171115231409.12131-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Wed, Nov 15, 2017 at 11:14:09PM +0000, Roman Gushchin wrote:
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

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
