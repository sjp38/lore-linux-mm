Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1002C6B2A75
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 10:00:57 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id v21-v6so4974310wrc.2
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 07:00:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y66-v6sor1236573wmg.39.2018.08.23.07.00.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Aug 2018 07:00:55 -0700 (PDT)
Date: Thu, 23 Aug 2018 16:00:53 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH 3/3] mm/sparse: use __highest_present_section_nr as the
 boundary for pfn check
Message-ID: <20180823140053.GC14924@techadventures.net>
References: <20180823130732.9489-1-richard.weiyang@gmail.com>
 <20180823130732.9489-4-richard.weiyang@gmail.com>
 <20180823132526.GL29735@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180823132526.GL29735@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, bob.picco@hp.com

On Thu, Aug 23, 2018 at 03:25:26PM +0200, Michal Hocko wrote:
> On Thu 23-08-18 21:07:32, Wei Yang wrote:
> > And it is known, __highest_present_section_nr is a more strict boundary
> > than NR_MEM_SECTIONS.
> > 
> > This patch uses a __highest_present_section_nr to check a valid pfn.
> 
> But why is this an improvement? Sure when you loop over all sections
> than __highest_present_section_nr makes a lot of sense. But all the
> updated function perform a trivial comparision.

I think it makes some sense.
NR_MEM_SECTIONS can be a big number, but we might not be using
all sections, so __highest_present_section_nr ends up being a much lower
value.

I think that we want to compare the pfn's section_nr with our current limit
of present sections.
Sections over that do not really exist for us, so it is no use to look for
them in __nr_to_section/valid_section.

It might not be a big improvement, but I think that given the nature of
pfn_valid/pfn_present, comparing to __highest_present_section_nr suits better.

-- 
Oscar Salvador
SUSE L3
