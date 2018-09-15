Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 401168E0001
	for <linux-mm@kvack.org>; Sat, 15 Sep 2018 05:45:21 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id w11-v6so5452670plq.8
        for <linux-mm@kvack.org>; Sat, 15 Sep 2018 02:45:21 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e34-v6si10081807plb.2.2018.09.15.02.45.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 15 Sep 2018 02:45:20 -0700 (PDT)
Date: Sat, 15 Sep 2018 02:45:15 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC v10 PATCH 3/3] mm: unmap VM_PFNMAP mappings with optimized
 path
Message-ID: <20180915094515.GC31572@bombadil.infradead.org>
References: <1536957299-43536-1-git-send-email-yang.shi@linux.alibaba.com>
 <1536957299-43536-4-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536957299-43536-4-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@kernel.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, kirill@shutemov.name, akpm@linux-foundation.org, dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Sep 15, 2018 at 04:34:59AM +0800, Yang Shi wrote:
> When unmapping VM_PFNMAP mappings, vm flags need to be updated. Since
> the vmas have been detached, so it sounds safe to update vm flags with
> read mmap_sem.
> 
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Reviewed-by: Matthew Wilcox <willy@infradead.org>
