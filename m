Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0AF136B005A
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 22:51:46 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id s22so1746787pfh.21
        for <linux-mm@kvack.org>; Fri, 26 Jan 2018 19:51:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f63si7390057pfc.226.2018.01.26.19.51.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Jan 2018 19:51:44 -0800 (PST)
Date: Fri, 26 Jan 2018 18:25:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] CMA and larger page sizes
Message-ID: <20180126172527.GI5027@dhcp22.suse.cz>
References: <3a3d724e-4d74-9bd8-60f3-f6896cffac7a@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3a3d724e-4d74-9bd8-60f3-f6896cffac7a@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

[Ccing Joonsoo]

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
> 
> There's been some interest in other CMA topics so this might go along well.
> 
> Thanks,
> Laura
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
