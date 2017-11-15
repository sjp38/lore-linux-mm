Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 05A416B0033
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 06:42:26 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v88so12557348wrb.22
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 03:42:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c35si538585ede.367.2017.11.15.03.42.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Nov 2017 03:42:24 -0800 (PST)
Date: Wed, 15 Nov 2017 12:42:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: hugetlbfs basic usage accounting
Message-ID: <20171115114223.ykyfrnxvvzhiglfd@dhcp22.suse.cz>
References: <20171114172429.8916-1-guro@fb.com>
 <20171115083504.nwczf5xq6posy3bw@dhcp22.suse.cz>
 <20171115111803.GA28352@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171115111803.GA28352@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Dave Hansen <dave.hansen@intel.com>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 15-11-17 11:18:13, Roman Gushchin wrote:
> On Wed, Nov 15, 2017 at 09:35:04AM +0100, Michal Hocko wrote:
[...]
> > So my primary question is, why don't you simply allow hugetlb controller
> > rather than tweak stats for memcg? Is there any fundamental reason why
> > hugetlb controller is not v2 compatible?
> 
> I really don't know if the hugetlb controller has enough users to deserve
> full support in v2 interface: adding knobs like memory.hugetlb.current,
> memory.hugetlb.min, memory.hugetlb.high, memory.hugetlb.max, etc.
> 
> I'd be rather conservative here and avoid adding a lot to the interface
> without clear demand. Also, hugetlb pages are really special, and it's
> at least not obvious how, say, memory.high should work for it.

But you clearly want the hugetlb accoutning and that is what hugetlb
controller is for. You might not be interested in the limit enforcement
but that is not strictly required. So my question remains. Why don't we
reuse an existing infrastructure and add a new which might confuse users
in an extreme case?

Please note that I am not saying your patch is wrong, I just do not see
why we should handle hugetlb pages 2 different ways to achieve a common
infrastructure.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
