Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AB8F36B71DD
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 03:08:07 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c16-v6so2192111edc.21
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 00:08:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h2-v6si1202385eda.150.2018.09.05.00.08.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 00:08:06 -0700 (PDT)
Date: Wed, 5 Sep 2018 09:08:03 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
Message-ID: <20180905070803.GZ14951@dhcp22.suse.cz>
References: <39BE14E6-D0FB-428A-B062-8B5AEDC06E61@cs.rutgers.edu>
 <20180829162528.GD10223@dhcp22.suse.cz>
 <20180829192451.GG10223@dhcp22.suse.cz>
 <E97C9342-9BA0-48DD-A580-738ACEE49B41@cs.rutgers.edu>
 <20180830070021.GB2656@dhcp22.suse.cz>
 <4AFDF557-46E3-4C62-8A43-C28E8F2A54CF@cs.rutgers.edu>
 <20180830134549.GI2656@dhcp22.suse.cz>
 <C0146217-821B-4530-A2E2-57D4CCDE8102@cs.rutgers.edu>
 <20180830164057.GK2656@dhcp22.suse.cz>
 <20180905034403.GN4762@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180905034403.GN4762@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

On Tue 04-09-18 23:44:03, Andrea Arcangeli wrote:
[...]
> That kind of swapping may only pay off in the very long long term,
> which is what khugepaged is for. khugepaged already takes care of the
> long term, so we could later argue and think if khugepaged should
> swapout or not in such condition, but I don't think there's much to
> argue about the page fault.

I agree that defrag==always doing a reclaim is not really good and
benefits are questionable. If you remember this was the primary reason
why the default has been changed.

> > Thanks for your and Stefan's testing. I will wait for some more
> > feedback. I will be offline next few days and if there are no major
> > objections I will repost with both tested-bys early next week.
> 
> I'm not so positive about 2 of the above tests if I understood the
> test correctly.
> 
> Those results are totally fine if you used the non default memory
> policy, but with MPOL_DEFAULT and in turn no hard bind of the memory,
> I'm afraid it'll be even be harder to reproduce when things will go
> wrong again in those two cases.

We can and should think about this much more but I would like to have
this regression closed. So can we address GFP_THISNODE part first and
build more complex solution on top?

Is there any objection to my patch which does the similar thing to your
patch v2 in a different location?
-- 
Michal Hocko
SUSE Labs
