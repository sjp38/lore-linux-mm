Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C98A1280842
	for <linux-mm@kvack.org>; Wed, 10 May 2017 03:45:21 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id o52so5777154wrb.10
        for <linux-mm@kvack.org>; Wed, 10 May 2017 00:45:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p184si2658659wmg.123.2017.05.10.00.45.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 May 2017 00:45:20 -0700 (PDT)
Date: Wed, 10 May 2017 09:45:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: RFC v2: post-init-read-only protection for data allocated
 dynamically
Message-ID: <20170510074518.GE31466@dhcp22.suse.cz>
References: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
 <20170504112159.GC31540@dhcp22.suse.cz>
 <83d4556c-b21c-7ae5-6e83-4621a74f9fd5@huawei.com>
 <20170504131131.GI31540@dhcp22.suse.cz>
 <df1b34fb-f90b-da9e-6723-49e8f1cb1757@huawei.com>
 <20170504140126.GJ31540@dhcp22.suse.cz>
 <3e798c43-1726-ee7d-add5-762c7e17cb88@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3e798c43-1726-ee7d-add5-762c7e17cb88@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>

On Fri 05-05-17 15:19:19, Igor Stoppa wrote:
> 
> 
> On 04/05/17 17:01, Michal Hocko wrote:
> > On Thu 04-05-17 16:37:55, Igor Stoppa wrote:
> 
> [...]
> 
> >> The disadvantage is that anything can happen, undetected, while the seal
> >> is lifted.
> > 
> > Yes and I think this makes it basically pointless
> 
> ok, this goes a bit beyond what I had in mind initially, but I see your
> point
> 
> [...]
> 
> > Just to make my proposal more clear. I suggest the following workflow
> > 
> > cache = kmem_cache_create(foo, object_size, ..., SLAB_SEAL);
> >
> > obj = kmem_cache_alloc(cache, gfp_mask);
> > init_obj(obj)
> > [more allocations]
> > kmem_cache_seal(cache);
> 
> In case one doesn't want the feature, at which point would it be disabled?
> 
> * not creating the slab
> * not sealing it
> * something else?

If the sealing would be disabled then sealing would be a noop.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
