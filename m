Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B37FC6B0003
	for <linux-mm@kvack.org>; Wed,  9 May 2018 16:56:12 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a127-v6so160659wmh.6
        for <linux-mm@kvack.org>; Wed, 09 May 2018 13:56:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y5-v6si4922359edp.247.2018.05.09.13.56.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 13:56:11 -0700 (PDT)
Date: Wed, 9 May 2018 22:56:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [External] [RFC PATCH v1 3/6] mm, zone_type: create ZONE_NVM and
 fill into GFP_ZONE_TABLE
Message-ID: <20180509205609.GV32366@dhcp22.suse.cz>
References: <1525746628-114136-1-git-send-email-yehs1@lenovo.com>
 <1525746628-114136-4-git-send-email-yehs1@lenovo.com>
 <HK2PR03MB1684653383FFEDAE9B41A548929A0@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <ce3a6f37-3b13-0c35-6895-35156c7a290c@infradead.org>
 <HK2PR03MB16847B78265A033C7310DDCB92990@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180509114712.GP32366@dhcp22.suse.cz>
 <HK2PR03MB168425F6D00C30918169C77C92990@HK2PR03MB1684.apcprd03.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <HK2PR03MB168425F6D00C30918169C77C92990@HK2PR03MB1684.apcprd03.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huaisheng HS1 Ye <yehs1@lenovo.com>
Cc: Randy Dunlap <rdunlap@infradead.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "willy@infradead.org" <willy@infradead.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "penguin-kernel@I-love.SAKURA.ne.jp" <penguin-kernel@I-love.SAKURA.ne.jp>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, Ocean HY1 He <hehy1@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Wed 09-05-18 14:04:21, Huaisheng HS1 Ye wrote:
> > From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On Behalf Of Michal Hocko
> > 
> > On Wed 09-05-18 04:22:10, Huaisheng HS1 Ye wrote:
[...]
> > > Current mm treats all memory regions equally, it divides zones just by size, like
> > 16M for DMA, 4G for DMA32, and others above for Normal.
> > > The spanned range of all zones couldn't be overlapped.
> > 
> > No, this is not correct. Zones can overlap.
> 
> Hi Michal,
> 
> Thanks for pointing it out.
> But function zone_sizes_init decides
> arch_zone_lowest/highest_possible_pfn's size by max_low_pfn, then
> free_area_init_nodes/node are responsible for calculating the spanned
> size of zones from memblock memory regions.  So, ZONE_DMA and
> ZONE_DMA32 and ZONE_NORMAL have separate address scope. How can they
> be overlapped with each other?

Sorry, I could have been a bit more specific. DMA, DMA32 and Normal
zones are exclusive. They are mapped to a specific physical range of
memory so they cannot overlap. I was referring to a general property
that zones might interleave. Especially zone Normal, Movable and Device.

-- 
Michal Hocko
SUSE Labs
