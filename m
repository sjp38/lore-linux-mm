Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A9351280393
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 03:04:09 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a186so15914591wmh.9
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 00:04:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 94si19890382wrf.83.2017.07.28.00.04.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 00:04:08 -0700 (PDT)
Date: Fri, 28 Jul 2017 09:04:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/3] mm/hugetlb: Remove pmd_huge_split_prepare
Message-ID: <20170728070403.GF2274@dhcp22.suse.cz>
References: <20170727083756.32217-1-aneesh.kumar@linux.vnet.ibm.com>
 <20170727083756.32217-3-aneesh.kumar@linux.vnet.ibm.com>
 <20170727125756.GD27766@dhcp22.suse.cz>
 <6d836bdb-0bf4-e855-e3d8-01a622714d1b@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6d836bdb-0bf4-e855-e3d8-01a622714d1b@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, "Kirill A . Shutemov" <kirill@shutemov.name>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu 27-07-17 21:27:37, Aneesh Kumar K.V wrote:
> 
> 
> On 07/27/2017 06:27 PM, Michal Hocko wrote:
> >On Thu 27-07-17 14:07:56, Aneesh Kumar K.V wrote:
> >>Instead of marking the pmd ready for split, invalidate the pmd. This should
> >>take care of powerpc requirement.
> >
> >which is?
> 
> I can add the commit which explain details here. Or add more details from
> the older commit here.
> 
> c777e2a8b65420b31dac28a453e35be984f5808b
> 
> powerpc/mm: Fix Multi hit ERAT cause by recent THP update

Each patch should be self descriptive. You can reference older commits
but always make sure that the full context is clear. This will make the
life easier to whoever is going to look at it later.
 
> >>Only side effect is that we mark the pmd
> >>invalid early. This can result in us blocking access to the page a bit longer
> >>if we race against a thp split.
> >
> >Again, this doesn't tell me what is the problem and why do we care.
> 
> Primary motivation is code reduction.

Then be explicit about it. This wasn't clear from the above description.
At least not to me.
 
>   7 files changed, 35 insertions(+), 87 deletions(-)
> 
> 
> -aneesh

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
