Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 68FB68E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 07:27:58 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id m3-v6so7734340plt.9
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 04:27:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b35-v6si16364152pla.420.2018.09.17.04.27.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Sep 2018 04:27:56 -0700 (PDT)
Date: Mon, 17 Sep 2018 13:27:51 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
Message-ID: <20180917112751.GD26286@dhcp22.suse.cz>
References: <20180829142816.GX10223@dhcp22.suse.cz>
 <20180829143545.GY10223@dhcp22.suse.cz>
 <82CA00EB-BF8E-4137-953B-8BC4B74B99AF@cs.rutgers.edu>
 <20180829154744.GC10223@dhcp22.suse.cz>
 <39BE14E6-D0FB-428A-B062-8B5AEDC06E61@cs.rutgers.edu>
 <20180829162528.GD10223@dhcp22.suse.cz>
 <20180829192451.GG10223@dhcp22.suse.cz>
 <20180912172925.GK1719@techsingularity.net>
 <20180917061107.GB26286@dhcp22.suse.cz>
 <e43348ae-c2db-e327-8dd6-c4f6f0e0cac0@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e43348ae-c2db-e327-8dd6-c4f6f0e0cac0@profihost.ag>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: Mel Gorman <mgorman@techsingularity.net>, Zi Yan <zi.yan@cs.rutgers.edu>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

On Mon 17-09-18 09:04:02, Stefan Priebe - Profihost AG wrote:
> Hi,
> 
> i had multiple memory stalls this weekend again. All kvm processes where
> spinning trying to get > 100% CPU and i was not able to even login to
> ssh. After 5-10 minutes i was able to login.
> 
> There were about 150GB free mem on the host.
> 
> Relevant settings (no local storage involved):
>         vm.dirty_background_ratio:
>             3
>         vm.dirty_ratio:
>             10
>         vm.min_free_kbytes:
>             10567004
> 
> # cat /sys/kernel/mm/transparent_hugepage/defrag
> always defer [defer+madvise] madvise never
> 
> # cat /sys/kernel/mm/transparent_hugepage/enabled
> [always] madvise never
> 
> After that i had the following traces on the host node:
> https://pastebin.com/raw/0VhyQmAv

I would suggest reporting this in a new email thread. I would also
recommend to CC kvm guys (see MAINTAINERS file in the kernel source
tree) and trace qemu/kvm processes to see what they are doing at the
time when you see the stall.
-- 
Michal Hocko
SUSE Labs
