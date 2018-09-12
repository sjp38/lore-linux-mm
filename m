Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C75BF8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 05:11:10 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z56-v6so593335edz.10
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 02:11:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q57-v6si832929edq.188.2018.09.12.02.11.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 02:11:09 -0700 (PDT)
Date: Wed, 12 Sep 2018 11:11:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v9 PATCH 2/4] mm: mmap: zap pages with read mmap_sem in
 munmap
Message-ID: <20180912091105.GB10951@dhcp22.suse.cz>
References: <1536699493-69195-1-git-send-email-yang.shi@linux.alibaba.com>
 <1536699493-69195-3-git-send-email-yang.shi@linux.alibaba.com>
 <20180911211645.GA12159@bombadil.infradead.org>
 <b69d3f7d-e9ba-b95c-45cd-44489950751b@linux.alibaba.com>
 <20180912022921.GA20056@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180912022921.GA20056@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 11-09-18 19:29:21, Matthew Wilcox wrote:
> On Tue, Sep 11, 2018 at 04:35:03PM -0700, Yang Shi wrote:
[...]

I didn't get to read the patch yet.

> > And, Michal prefers have VM_HUGETLB and VM_PFNMAP handled separately for
> > safe and bisectable sake, which needs call the regular do_munmap().
> 
> That can be introduced and then taken out ... indeed, you can split this into
> many patches, starting with this:
> 
> +		if (tmp->vm_file)
> +			downgrade = false;
> 
> to only allow this optimisation for anonymous mappings at first.

or add a helper function to check for special cases and make the
downgrade behavior conditional on it.
-- 
Michal Hocko
SUSE Labs
