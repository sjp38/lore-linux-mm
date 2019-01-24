Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3918E0089
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 09:30:11 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id z10so2382283edz.15
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 06:30:11 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d25-v6si565635ejr.13.2019.01.24.06.30.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 06:30:09 -0800 (PST)
Date: Thu, 24 Jan 2019 15:30:08 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, page_alloc: cleanup usemap_size() when SPARSEMEM is
 not set
Message-ID: <20190124143008.GO4087@dhcp22.suse.cz>
References: <20190118234905.27597-1-richard.weiyang@gmail.com>
 <20190122085524.GE4087@dhcp22.suse.cz>
 <20190122150717.llf4owk6soejibov@master>
 <20190122151628.GI4087@dhcp22.suse.cz>
 <20190122155628.eu4sxocyjb5lrcla@master>
 <20190123095503.GR4087@dhcp22.suse.cz>
 <20190124141341.au6a7jpwccez5vc7@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190124141341.au6a7jpwccez5vc7@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Thu 24-01-19 14:13:41, Wei Yang wrote:
> On Wed, Jan 23, 2019 at 10:55:03AM +0100, Michal Hocko wrote:
> >On Tue 22-01-19 15:56:28, Wei Yang wrote:
> >> 
> >> I think the answer is yes.
> >> 
> >>   * it reduce the code from 6 lines to 3 lines, 50% off
> >>   * by reducing calculation back and forth, it would be easier for
> >>     audience to catch what it tries to do
> >
> >To be honest, I really do not see this sufficient to justify touching
> >the code unless the resulting _generated_ code is better/more efficient.
> 
> Tried objdump to compare two version.
> 
>                Base       Patched      Reduced
> Code Size(B)   48         39           18.7%
> Instructions   12         10           16.6%

How have you compiled the code? (compiler version, any specific configs).
Because I do not see any difference.

CONFIG_CC_OPTIMIZE_FOR_SIZE:
   text    data     bss     dec     hex filename
  47087    2085      72   49244    c05c mm/page_alloc.o
  47087    2085      72   49244    c05c mm/page_alloc.o.prev

CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE:
   text    data     bss     dec     hex filename
  55046    2085      72   57203    df73 mm/page_alloc.o
  55046    2085      72   57203    df73 mm/page_alloc.o.prev

And that would actually match my expectations because I am pretty sure
the compiler can figure out what to do with those operations even
without any help.

Really, is this really worth touching and spending a non-trivial time to
discuss? I do not see the benefit.
-- 
Michal Hocko
SUSE Labs
