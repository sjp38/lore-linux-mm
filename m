Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8E8586B0A8A
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 12:04:10 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id v4so9987978edm.18
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 09:04:10 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z11-v6si1873682ejb.245.2018.11.16.09.04.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 09:04:09 -0800 (PST)
Date: Fri, 16 Nov 2018 18:04:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] slab: fix 'dubious: x & !y' warning from Sparse
Message-ID: <20181116170406.GM14706@dhcp22.suse.cz>
References: <1542346829-31063-1-git-send-email-yamada.masahiro@socionext.com>
 <010001671cca4b8b-2333373d-6b28-44e1-bca3-24570b8e0d2b-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <010001671cca4b8b-2333373d-6b28-44e1-bca3-24570b8e0d2b-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 16-11-18 13:51:19, Cristopher Lameter wrote:
> On Fri, 16 Nov 2018, Masahiro Yamada wrote:
> 
> > diff --git a/include/linux/slab.h b/include/linux/slab.h
> > index 918f374..d395c73 100644
> > --- a/include/linux/slab.h
> > +++ b/include/linux/slab.h
> > @@ -329,7 +329,7 @@ static __always_inline enum kmalloc_cache_type kmalloc_type(gfp_t flags)
> >  	 * If an allocation is both __GFP_DMA and __GFP_RECLAIMABLE, return
> >  	 * KMALLOC_DMA and effectively ignore __GFP_RECLAIMABLE
> >  	 */
> > -	return type_dma + (is_reclaimable & !is_dma) * KMALLOC_RECLAIM;
> > +	return type_dma + (is_reclaimable && !is_dma) * KMALLOC_RECLAIM;
> >  }
> 
> Ok then lets revert the initial patch whose point was to avoid a branch.
> && causes a branch again.

I believe Vlastimil managed to get rid of the branch http://lkml.kernel.org/r/aa5975b6-58ed-5a3e-7de1-4b1384f88457@suse.cz

-- 
Michal Hocko
SUSE Labs
