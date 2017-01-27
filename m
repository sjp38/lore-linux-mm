Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B5916B0033
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 11:19:11 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id d140so53328952wmd.4
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 08:19:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o43si6474214wrc.37.2017.01.27.08.19.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Jan 2017 08:19:10 -0800 (PST)
Date: Fri, 27 Jan 2017 17:19:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm: alloc_contig_range: allow to specify GFP mask
Message-ID: <20170127161904.GA6357@dhcp22.suse.cz>
References: <20170119170707.31741-1-l.stach@pengutronix.de>
 <81849c0d-b7aa-faf2-484c-66b0ea0a7e95@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <81849c0d-b7aa-faf2-484c-66b0ea0a7e95@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Lucas Stach <l.stach@pengutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alexander Graf <agraf@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linux-xtensa@linux-xtensa.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, kernel@pengutronix.de, patchwork-lst@pengutronix.de

On Fri 20-01-17 13:35:40, Vlastimil Babka wrote:
> On 01/19/2017 06:07 PM, Lucas Stach wrote:
[...]
> > @@ -7255,7 +7256,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
> >  		.zone = page_zone(pfn_to_page(start)),
> >  		.mode = MIGRATE_SYNC,
> >  		.ignore_skip_hint = true,
> > -		.gfp_mask = GFP_KERNEL,
> > +		.gfp_mask = gfp_mask,
> 
> I think you should apply memalloc_noio_flags() here (and Michal should
> then convert it to the new name in his scoped gfp_nofs series). Note
> that then it's technically a functional change, but it's needed.
> Otherwise looks good.

yes, with that added, feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>

> 
> >  	};
> >  	INIT_LIST_HEAD(&cc.migratepages);
> >  
> > 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
