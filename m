Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id AED676B2BAA
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 15:17:35 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 191-v6so1206009pgb.23
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 12:17:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q11-v6si4799914pgl.118.2018.08.23.12.17.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 12:17:34 -0700 (PDT)
Date: Thu, 23 Aug 2018 21:17:29 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 3/3] mm/sparse: use __highest_present_section_nr as the
 boundary for pfn check
Message-ID: <20180823191729.GQ29735@dhcp22.suse.cz>
References: <20180823130732.9489-1-richard.weiyang@gmail.com>
 <20180823130732.9489-4-richard.weiyang@gmail.com>
 <20180823132526.GL29735@dhcp22.suse.cz>
 <20180823140053.GC14924@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180823140053.GC14924@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, bob.picco@hp.com

On Thu 23-08-18 16:00:53, Oscar Salvador wrote:
> On Thu, Aug 23, 2018 at 03:25:26PM +0200, Michal Hocko wrote:
> > On Thu 23-08-18 21:07:32, Wei Yang wrote:
> > > And it is known, __highest_present_section_nr is a more strict boundary
> > > than NR_MEM_SECTIONS.
> > > 
> > > This patch uses a __highest_present_section_nr to check a valid pfn.
> > 
> > But why is this an improvement? Sure when you loop over all sections
> > than __highest_present_section_nr makes a lot of sense. But all the
> > updated function perform a trivial comparision.
> 
> I think it makes some sense.
> NR_MEM_SECTIONS can be a big number, but we might not be using
> all sections, so __highest_present_section_nr ends up being a much lower
> value.

And how exactly does it help to check for the smaller vs. a larger number?
Both are O(1) operations AFAICS. __highest_present_section_nr makes
perfect sense when we iterate over all sections or similar operations
where it smaller number of iterations really makes sense.

I am not saying the patch is wrong but I just do not see this being an
improvement. You have to export an internal symbol to achieve something
that is hardly an optimization.
-- 
Michal Hocko
SUSE Labs
