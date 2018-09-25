Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE9A8E0072
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 08:03:44 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i68-v6so12425113pfb.9
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 05:03:44 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e25-v6sor277917pge.323.2018.09.25.05.03.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Sep 2018 05:03:43 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] thp nodereclaim fixes
Date: Tue, 25 Sep 2018 14:03:24 +0200
Message-Id: <20180925120326.24392-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
this has been brought up by Andrea [1] and he proposed two different
fixes for the regression. I have proposed an alternative fix [2]. I have
changed my mind in the end because whatever fix we end up with it should
be backported to the stable trees so going with a minimalistic one is
preferred so I have got back to the Andrea's second proposed solution
[3] in the end. I have just reworded the changelog to reflect other bug
report with the stall information.

My primary concern about [3] was that the __GFP_THISNODE logic should be
placed in alloc_hugepage_direct_gfpmask which I've done on top of the
fix as a cleanup (patch 2) and it doesn't need to be backported to the
stable tree.

I am still not happy that the David's workload will regress as a result
but we should really focus on the default behavior and come with a more
robust solution for specialized one for those who have more restrictive
NUMA preferences. I am thinking about a new numa policy that would mimic
node reclaim behavior and I am willing to work on that but we really
have to fix the regression first and that is the patch 1.

Thoughts, alternative patches?

[1] http://lkml.kernel.org/r/20180820032204.9591-1-aarcange@redhat.com
[2] http://lkml.kernel.org/r/20180830064732.GA2656@dhcp22.suse.cz
[3] http://lkml.kernel.org/r/20180820032640.9896-2-aarcange@redhat.com
