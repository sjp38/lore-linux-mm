Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5FA6B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 05:54:44 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id j37so44051755ioo.2
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 02:54:44 -0700 (PDT)
Received: from mail-pa0-f68.google.com (mail-pa0-f68.google.com. [209.85.220.68])
        by mx.google.com with ESMTPS id q4si5191185iof.3.2016.10.12.02.54.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 02:54:43 -0700 (PDT)
Received: by mail-pa0-f68.google.com with SMTP id fn2so2173784pad.1
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 02:54:43 -0700 (PDT)
Date: Wed, 12 Oct 2016 11:54:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/1] mm/percpu.c: fix memory leakage issue when
 allocate a odd alignment area
Message-ID: <20161012095439.GI17128@dhcp22.suse.cz>
References: <bc3126cd-226d-91c7-d323-48881095accf@zoho.com>
 <20161011172228.GA30403@dhcp22.suse.cz>
 <7649b844-cfe6-abce-148e-1e2236e7d443@zoho.com>
 <20161012065332.GA9504@dhcp22.suse.cz>
 <57FDE531.7060003@zoho.com>
 <20161012082538.GC17128@dhcp22.suse.cz>
 <57FDF7EF.6070606@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57FDF7EF.6070606@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, tj@kernel.org, akpm@linux-foundation.org, cl@linux.com

On Wed 12-10-16 16:44:31, zijun_hu wrote:
> On 10/12/2016 04:25 PM, Michal Hocko wrote:
> > On Wed 12-10-16 15:24:33, zijun_hu wrote:
[...]
> >> i found the following code segments in mm/vmalloc.c
> >> static struct vmap_area *alloc_vmap_area(unsigned long size,
> >>                                 unsigned long align,
> >>                                 unsigned long vstart, unsigned long vend,
> >>                                 int node, gfp_t gfp_mask)
> >> {
> >> ...
> >>
> >>         BUG_ON(!size);
> >>         BUG_ON(offset_in_page(size));
> >>         BUG_ON(!is_power_of_2(align));
> > 
> > See a recent Linus rant about BUG_ONs. These BUG_ONs are quite old and
> > from a quick look they are even unnecessary. So rather than adding more
> > of those, I think removing those that are not needed is much more
> > preferred.
> >
> i notice that, and the above code segments is used to illustrate that
> input parameter checking is necessary sometimes

Why do you think it is necessary here?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
