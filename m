Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E4C5A6B786B
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 07:10:59 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f13-v6so5382654pgs.15
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 04:10:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d20-v6si5021549pgj.535.2018.09.06.04.10.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 04:10:58 -0700 (PDT)
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
References: <39BE14E6-D0FB-428A-B062-8B5AEDC06E61@cs.rutgers.edu>
 <20180829162528.GD10223@dhcp22.suse.cz>
 <20180829192451.GG10223@dhcp22.suse.cz>
 <E97C9342-9BA0-48DD-A580-738ACEE49B41@cs.rutgers.edu>
 <20180830070021.GB2656@dhcp22.suse.cz>
 <4AFDF557-46E3-4C62-8A43-C28E8F2A54CF@cs.rutgers.edu>
 <20180830134549.GI2656@dhcp22.suse.cz>
 <C0146217-821B-4530-A2E2-57D4CCDE8102@cs.rutgers.edu>
 <20180830164057.GK2656@dhcp22.suse.cz> <20180905034403.GN4762@redhat.com>
 <20180905070803.GZ14951@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <99ee1104-9258-e801-2ba3-a643892cc6c1@suse.cz>
Date: Thu, 6 Sep 2018 13:10:53 +0200
MIME-Version: 1.0
In-Reply-To: <20180905070803.GZ14951@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

On 09/05/2018 09:08 AM, Michal Hocko wrote:
> On Tue 04-09-18 23:44:03, Andrea Arcangeli wrote:
> [...]
>> That kind of swapping may only pay off in the very long long term,
>> which is what khugepaged is for. khugepaged already takes care of the
>> long term, so we could later argue and think if khugepaged should
>> swapout or not in such condition, but I don't think there's much to
>> argue about the page fault.
> 
> I agree that defrag==always doing a reclaim is not really good and
> benefits are questionable. If you remember this was the primary reason
> why the default has been changed.
> 
>>> Thanks for your and Stefan's testing. I will wait for some more
>>> feedback. I will be offline next few days and if there are no major
>>> objections I will repost with both tested-bys early next week.
>>
>> I'm not so positive about 2 of the above tests if I understood the
>> test correctly.
>>
>> Those results are totally fine if you used the non default memory
>> policy, but with MPOL_DEFAULT and in turn no hard bind of the memory,
>> I'm afraid it'll be even be harder to reproduce when things will go
>> wrong again in those two cases.
> 
> We can and should think about this much more but I would like to have
> this regression closed. So can we address GFP_THISNODE part first and
> build more complex solution on top?
> 
> Is there any objection to my patch which does the similar thing to your
> patch v2 in a different location?

Similar but not the same. It fixes the madvise case, but I wonder about
the no-madvise defrag=defer case, where Zi Yan reports it still causes
swapping.
