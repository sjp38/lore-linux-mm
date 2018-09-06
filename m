Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 008026B788A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 07:25:49 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z30-v6so3566969edd.19
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 04:25:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o35-v6si944655edo.114.2018.09.06.04.25.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 04:25:47 -0700 (PDT)
Date: Thu, 6 Sep 2018 13:25:46 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
Message-ID: <20180906112546.GP14951@dhcp22.suse.cz>
References: <E97C9342-9BA0-48DD-A580-738ACEE49B41@cs.rutgers.edu>
 <20180830070021.GB2656@dhcp22.suse.cz>
 <4AFDF557-46E3-4C62-8A43-C28E8F2A54CF@cs.rutgers.edu>
 <20180830134549.GI2656@dhcp22.suse.cz>
 <C0146217-821B-4530-A2E2-57D4CCDE8102@cs.rutgers.edu>
 <20180830164057.GK2656@dhcp22.suse.cz>
 <20180905034403.GN4762@redhat.com>
 <20180905070803.GZ14951@dhcp22.suse.cz>
 <99ee1104-9258-e801-2ba3-a643892cc6c1@suse.cz>
 <d339247b-18a5-e26d-d402-c44c8cca6cee@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d339247b-18a5-e26d-d402-c44c8cca6cee@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

On Thu 06-09-18 13:16:00, Vlastimil Babka wrote:
> On 09/06/2018 01:10 PM, Vlastimil Babka wrote:
> >> We can and should think about this much more but I would like to have
> >> this regression closed. So can we address GFP_THISNODE part first and
> >> build more complex solution on top?
> >>
> >> Is there any objection to my patch which does the similar thing to your
> >> patch v2 in a different location?
> > 
> > Similar but not the same. It fixes the madvise case, but I wonder about
> > the no-madvise defrag=defer case, where Zi Yan reports it still causes
> > swapping.
> 
> Ah, but that should be the same with Andrea's variant 2) patch. There
> should only be difference with defrag=always, which is direct reclaim
> with __GFP_NORETRY, Andrea's patch would drop __GFP_THISNODE and your
> not. Maybe Zi Yan can do the same kind of tests with Andrea's patch [1]
> to confirm?

Yes, that is the only difference and that is why I've said those patches
are mostly similar. I do not want to touch defrag=always case because
this one has always been stall prone and we have replaced it as a
default just because of that. We should discuss what should be done with
that case separately IMHO.
-- 
Michal Hocko
SUSE Labs
