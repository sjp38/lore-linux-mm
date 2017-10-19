Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AAD216B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 03:28:12 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id y83so3013022wmc.8
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 00:28:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n14si621854wmg.239.2017.10.19.00.28.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 00:28:11 -0700 (PDT)
Date: Thu, 19 Oct 2017 09:28:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm: oom: show unreclaimable slab info when
 unreclaimable slabs > user memory
Message-ID: <20171019072809.xykifzpsiabdjv6m@dhcp22.suse.cz>
References: <1507656303-103845-1-git-send-email-yang.s@alibaba-inc.com>
 <1507656303-103845-4-git-send-email-yang.s@alibaba-inc.com>
 <alpine.DEB.2.10.1710161709460.140151@chino.kir.corp.google.com>
 <20171017074448.qupoajpjbcfdpz5z@dhcp22.suse.cz>
 <alpine.DEB.2.10.1710171357260.100885@chino.kir.corp.google.com>
 <7ac4f9f6-3c3d-c1df-e60f-a519650cd330@alibaba-inc.com>
 <alpine.DEB.2.10.1710171449000.100885@chino.kir.corp.google.com>
 <a324af3f-f5c4-8c26-400e-ca3a590db37d@alibaba-inc.com>
 <alpine.DEB.2.10.1710171537170.141832@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1710171537170.141832@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Yang Shi <yang.s@alibaba-inc.com>, cl@linux.com, penberg@kernel.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 17-10-17 15:39:08, David Rientjes wrote:
> On Wed, 18 Oct 2017, Yang Shi wrote:
> 
> > > Yes, this should catch occurrences of "huge unreclaimable slabs", right?
> > 
> > Yes, it sounds so. Although single "huge" unreclaimable slab might not result
> > in excessive slabs use in a whole, but this would help to filter out "small"
> > unreclaimable slab.
> > 
> 
> Keep in mind this is regardless of SLAB_RECLAIM_ACCOUNT: your patch has 
> value beyond only unreclaimable slab, it can also be used to show 
> instances where the oom killer was invoked without properly reclaiming 
> slab.  If the total footprint of a slab cache exceeds 5%, I think a line 
> should be emitted unconditionally to the kernel log.

agreed. I am not sure 5% is the greatest fit but we can tune that later.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
