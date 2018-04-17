Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id DC03C6B0007
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:36:58 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v11so16116799wri.13
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 04:36:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e17si1488695ede.310.2018.04.17.04.36.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 04:36:57 -0700 (PDT)
Date: Tue, 17 Apr 2018 13:36:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] CMA and larger page sizes
Message-ID: <20180417113656.GA16083@dhcp22.suse.cz>
References: <3a3d724e-4d74-9bd8-60f3-f6896cffac7a@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3a3d724e-4d74-9bd8-60f3-f6896cffac7a@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Fri 26-01-18 02:08:14, Laura Abbott wrote:
> CMA as it's currently designed requires alignment to the pageblock size c.f.
> 
>         /*
>          * Sanitise input arguments.
>          * Pages both ends in CMA area could be merged into adjacent unmovable
>          * migratetype page by page allocator's buddy algorithm. In the case,
>          * you couldn't get a contiguous memory, which is not what we want.
>          */
>         alignment = max(alignment,  (phys_addr_t)PAGE_SIZE <<
>                           max_t(unsigned long, MAX_ORDER - 1, pageblock_order));
> 
> 
> On arm64 with 64K page size and transparent huge page, this gives an alignment
> of 512MB. This is quite restrictive and can eat up significant portions of
> memory on smaller memory targets. Adjusting the configuration options really
> isn't ideal for distributions that aim to have a single image which runs on
> all targets.
> 
> Approaches I've thought about:
> - Making CMA alignment less restrictive (and dealing with the fallout from
> the comment above)
> - Command line option to force a reasonable alignment

Laura, are you still interested discussing this or other CMA related
topic?

-- 
Michal Hocko
SUSE Labs
