Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 267066B0007
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 07:59:41 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id y16-v6so4374425pgv.23
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 04:59:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w18-v6si10289895pfi.88.2018.08.10.04.59.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Aug 2018 04:59:40 -0700 (PDT)
Date: Fri, 10 Aug 2018 13:59:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v7 PATCH 4/4] mm: unmap special vmas with regular
 do_munmap()
Message-ID: <20180810115937.GB1644@dhcp22.suse.cz>
References: <1533857763-43527-1-git-send-email-yang.shi@linux.alibaba.com>
 <1533857763-43527-5-git-send-email-yang.shi@linux.alibaba.com>
 <521a7d54-efdb-2401-c677-3f5fcbad557b@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <521a7d54-efdb-2401-c677-3f5fcbad557b@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 10-08-18 11:51:54, Vlastimil Babka wrote:
> On 08/10/2018 01:36 AM, Yang Shi wrote:
> > Unmapping vmas, which have VM_HUGETLB | VM_PFNMAP flag set or
> > have uprobes set, need get done with write mmap_sem held since
> > they may update vm_flags.
> > 
> > So, it might be not safe enough to deal with these kind of special
> > mappings with read mmap_sem. Deal with such mappings with regular
> > do_munmap() call.
> > 
> > Michal suggested to make this as a separate patch for safer and more
> > bisectable sake.
> 
> Hm I believe Michal meant the opposite "evolution" though. Patch 2/4
> should be done in a way that special mappings keep using the regular
> path, and this patch would convert them to the new path. Possibly even
> each special case separately.

yes, that is what I meant. Each of the special case should have its own
patch and changelog explaining why it is safe.
-- 
Michal Hocko
SUSE Labs
