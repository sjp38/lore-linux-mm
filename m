Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C43FA8E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 07:15:18 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id f17so25531387edm.20
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 04:15:18 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g51si716879edg.7.2018.12.28.04.15.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Dec 2018 04:15:16 -0800 (PST)
Date: Fri, 28 Dec 2018 13:15:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Message-ID: <20181228121515.GS16738@dhcp22.suse.cz>
References: <20181226131446.330864849@intel.com>
 <20181227203158.GO16738@dhcp22.suse.cz>
 <20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com>
 <20181228084105.GQ16738@dhcp22.suse.cz>
 <20181228094208.7lgxhha34zpqu4db@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181228094208.7lgxhha34zpqu4db@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Fri 28-12-18 17:42:08, Wu Fengguang wrote:
[...]
> Those look unnecessary complexities for this post. This v2 patchset
> mainly fulfills our first milestone goal: a minimal viable solution
> that's relatively clean to backport. Even when preparing for new
> upstreamable versions, it may be good to keep it simple for the
> initial upstream inclusion.

On the other hand this is creating a new NUMA semantic and I would like
to have something long term thatn let's throw something in now and care
about long term later. So I would really prefer to talk about long term
plans first and only care about implementation details later.

> > I haven't looked at the implementation yet but if you are proposing a
> > special cased zone lists then this is something CDM (Coherent Device
> > Memory) was trying to do two years ago and there was quite some
> > skepticism in the approach.
> 
> It looks we are pretty different than CDM. :)
> We creating new NUMA nodes rather than CDM's new ZONE.
> The zonelists modification is just to make PMEM nodes more separated.

Yes, this is exactly what CDM was after. Have a zone which is not
reachable without explicit request AFAIR. So no, I do not think you are
too different, you just use a different terminology ;)

-- 
Michal Hocko
SUSE Labs
