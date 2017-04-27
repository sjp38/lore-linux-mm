Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id BB1706B02E1
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 09:35:27 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y106so3099342wrb.14
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 06:35:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w81si10368726wmd.42.2017.04.27.06.35.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Apr 2017 06:35:26 -0700 (PDT)
Date: Thu, 27 Apr 2017 15:35:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Question on ___GFP_NOLOCKDEP - Was: Re: [PATCH 1/1] Remove
 hardcoding of ___GFP_xxx bitmasks
Message-ID: <20170427133523.GG4706@dhcp22.suse.cz>
References: <20170426133549.22603-1-igor.stoppa@huawei.com>
 <20170426133549.22603-2-igor.stoppa@huawei.com>
 <20170426144750.GH12504@dhcp22.suse.cz>
 <e3fe4d80-10a8-2008-1798-af3893fe418a@huawei.com>
 <9929419e-c22e-2a9f-a8a6-ad98d5a9da06@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9929419e-c22e-2a9f-a8a6-ad98d5a9da06@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 27-04-17 15:16:47, Igor Stoppa wrote:
> On 26/04/17 18:29, Igor Stoppa wrote:
> 
> > On 26/04/17 17:47, Michal Hocko wrote:
> 
> [...]
> 
> >> Also the current mm tree has ___GFP_NOLOCKDEP which is not addressed
> >> here so I suspect you have based your change on the Linus tree.
> 
> > I used your tree from kernel.org
> 
> I found it, I was using master, instead of auto-latest (is it correct?)

yes

> But now I see something that I do not understand (apologies if I'm
> asking something obvious).
> 
> First there is:
> 
> [...]
> #define ___GFP_WRITE		0x800000u
> #define ___GFP_KSWAPD_RECLAIM	0x1000000u
> #ifdef CONFIG_LOCKDEP
> #define ___GFP_NOLOCKDEP	0x4000000u
> #else
> #define ___GFP_NOLOCKDEP	0
> #endif
> 
> Then:
> 
> /* Room for N __GFP_FOO bits */
> #define __GFP_BITS_SHIFT (25 + IS_ENABLED(CONFIG_LOCKDEP))
> 
> 
> 
> Shouldn't it be either:
> ___GFP_NOLOCKDEP	0x2000000u

Yes it should. At the time when this patch was written this value was
used. Later I've removed __GFP_OTHER by 41b6167e8f74 ("mm: get rid of
__GFP_OTHER_NODE") and forgot to refresh this one. Thanks for noticing
this.

Andrew, could you fold the following in please?
---
