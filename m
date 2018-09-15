Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 56FC88E0001
	for <linux-mm@kvack.org>; Sat, 15 Sep 2018 05:45:04 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id n17-v6so5832228pff.17
        for <linux-mm@kvack.org>; Sat, 15 Sep 2018 02:45:04 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c31-v6si8572609pgl.126.2018.09.15.02.45.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 15 Sep 2018 02:45:02 -0700 (PDT)
Date: Sat, 15 Sep 2018 02:44:54 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC v10 PATCH 2/3] mm: unmap VM_HUGETLB mappings with optimized
 path
Message-ID: <20180915094454.GB31572@bombadil.infradead.org>
References: <1536957299-43536-1-git-send-email-yang.shi@linux.alibaba.com>
 <1536957299-43536-3-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536957299-43536-3-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@kernel.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, kirill@shutemov.name, akpm@linux-foundation.org, dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Sep 15, 2018 at 04:34:58AM +0800, Yang Shi wrote:
> When unmapping VM_HUGETLB mappings, vm flags need to be updated. Since
> the vmas have been detached, so it sounds safe to update vm flags with
> read mmap_sem.
> 
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Reviewed-by: Matthew Wilcox <willy@infradead.org>
