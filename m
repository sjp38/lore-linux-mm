Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 668586B0008
	for <linux-mm@kvack.org>; Wed, 30 May 2018 04:02:14 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e1-v6so12020419wma.3
        for <linux-mm@kvack.org>; Wed, 30 May 2018 01:02:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u20-v6si3323339edl.251.2018.05.30.01.02.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 May 2018 01:02:13 -0700 (PDT)
Date: Wed, 30 May 2018 10:02:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] fs, elf: drop MAP_FIXED usage from elf_map
Message-ID: <20180530080212.GA27180@dhcp22.suse.cz>
References: <20171129144219.22867-1-mhocko@kernel.org>
 <20171129144219.22867-3-mhocko@kernel.org>
 <93ce964b-e352-1905-c2b6-deedf2ea06f8@oracle.com>
 <c0e447b3-4ba7-239e-6550-64de7721ad28@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c0e447b3-4ba7-239e-6550-64de7721ad28@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, libhugetlbfs@googlegroups.com

On Tue 29-05-18 15:21:14, Mike Kravetz wrote:
> Just a quick heads up.  I noticed a change in libhugetlbfs testing starting
> with v4.17-rc1.
> 
> V4.16 libhugetlbfs test results
> ********** TEST SUMMARY
> *                      2M            
> *                      32-bit 64-bit 
> *     Total testcases:   110    113   
> *             Skipped:     0      0   
> *                PASS:   105    111   
> *                FAIL:     0      0   
> *    Killed by signal:     4      1   
> *   Bad configuration:     1      1   
> *       Expected FAIL:     0      0   
> *     Unexpected PASS:     0      0   
> *    Test not present:     0      0   
> * Strange test result:     0      0   
> **********
> 
> v4.17-rc1 (and later) libhugetlbfs test results
> ********** TEST SUMMARY
> *                      2M            
> *                      32-bit 64-bit 
> *     Total testcases:   110    113   
> *             Skipped:     0      0   
> *                PASS:    98    111   
> *                FAIL:     0      0   
> *    Killed by signal:    11      1   
> *   Bad configuration:     1      1   
> *       Expected FAIL:     0      0   
> *     Unexpected PASS:     0      0   
> *    Test not present:     0      0   
> * Strange test result:     0      0   
> **********
> 
> I traced the 7 additional (32-bit) killed by signal results to this
> commit 4ed28639519c fs, elf: drop MAP_FIXED usage from elf_map.
> 
> libhugetlbfs does unusual things and even provides custom linker scripts.
> So, in hindsight this change in behavior does not seem too unexpected.  I
> JUST discovered this while running libhugetlbfs tests for an unrelated
> issue/change and, will do some analysis to see exactly what is happening.

I am definitely interested about further details. Are there any messages
in the kernel log?

-- 
Michal Hocko
SUSE Labs
