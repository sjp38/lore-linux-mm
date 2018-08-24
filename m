Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7FDE66B2E72
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 03:31:11 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n4-v6so3291440edr.5
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 00:31:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s6-v6si3476647edj.407.2018.08.24.00.31.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 00:31:10 -0700 (PDT)
Date: Fri, 24 Aug 2018 09:31:08 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 1/3] mm/sparse: add likely to mem_section[root] check in
 sparse_index_init()
Message-ID: <20180824073108.GX29735@dhcp22.suse.cz>
References: <20180823130732.9489-1-richard.weiyang@gmail.com>
 <20180823130732.9489-2-richard.weiyang@gmail.com>
 <20180823131339.GJ29735@dhcp22.suse.cz>
 <20180823225742.bsmci4gxv3dho2ke@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180823225742.bsmci4gxv3dho2ke@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, bob.picco@hp.com

On Thu 23-08-18 22:57:42, Wei Yang wrote:
> On Thu, Aug 23, 2018 at 03:13:39PM +0200, Michal Hocko wrote:
> >On Thu 23-08-18 21:07:30, Wei Yang wrote:
> >> Each time SECTIONS_PER_ROOT number of mem_section is allocated when
> >> mem_section[root] is null. This means only (1 / SECTIONS_PER_ROOT) chance
> >> of the mem_section[root] check is false.
> >> 
> >> This patch adds likely to the if check to optimize this a little.
> >
> >Could you evaluate how much does this help if any? Does this have any
> >impact on the initialization path at all?
> 
> Let me test on my 4G machine with this patch :-)

Well, this should have been done before posting the patch. In general,
though, you should have some convincing numbers in order to add new
likely/unlikely annotations. They are rarely helpful and they tend to
rot over time. Steven Rostedt has made some test few years back and
found out that a vast majority of those annotation were simply wrong.
-- 
Michal Hocko
SUSE Labs
