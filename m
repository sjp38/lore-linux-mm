Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 169996B0679
	for <linux-mm@kvack.org>; Fri, 11 May 2018 14:15:59 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id o23-v6so3538083pll.12
        for <linux-mm@kvack.org>; Fri, 11 May 2018 11:15:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f3-v6si3696797pld.513.2018.05.11.11.15.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 11 May 2018 11:15:57 -0700 (PDT)
Date: Fri, 11 May 2018 11:15:46 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] mm: Change return type to vm_fault_t
Message-ID: <20180511181546.GA25613@bombadil.infradead.org>
References: <20180511180639.GA1792@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180511180639.GA1792@jordon-HP-15-Notebook-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, hughd@google.com, dan.j.williams@intel.com, rientjes@google.com, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, May 11, 2018 at 11:36:39PM +0530, Souptick Joarder wrote:
>  mm/hugetlb.c | 2 +-
>  mm/mmap.c    | 4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)

Don't we also need to convert include/linux/mm_types.h:

@@ -621,7 +621,7 @@ struct vm_special_mapping {
         * If non-NULL, then this is called to resolve page faults
         * on the special mapping.  If used, .pages is not checked.
         */
-       int (*fault)(const struct vm_special_mapping *sm,
+       vm_fault_t (*fault)(const struct vm_special_mapping *sm,
                     struct vm_area_struct *vma,
                     struct vm_fault *vmf);
 
or are you leaving that for a later patch?
