Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id DBBDF6B04CE
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 03:16:16 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id x23so29520498wrb.6
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 00:16:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q18si9819424wrb.366.2017.07.11.00.16.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 00:16:15 -0700 (PDT)
Date: Tue, 11 Jul 2017 09:16:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] mm/mremap: Remove redundant checks inside vma_expandable()
Message-ID: <20170711071612.GG24852@dhcp22.suse.cz>
References: <20170710111059.30795-1-khandual@linux.vnet.ibm.com>
 <20170710134917.GB19645@dhcp22.suse.cz>
 <d6f9ec12-4518-8f97-eca9-6592808b839d@linux.vnet.ibm.com>
 <20170711060354.GA24852@dhcp22.suse.cz>
 <4c182da0-6c84-df67-b173-6960fac0544a@suse.cz>
 <20170711065030.GE24852@dhcp22.suse.cz>
 <337a8a4c-1f27-7371-409d-6a9f181b3871@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <337a8a4c-1f27-7371-409d-6a9f181b3871@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com

On Tue 11-07-17 08:56:04, Vlastimil Babka wrote:
> On 07/11/2017 08:50 AM, Michal Hocko wrote:
> > On Tue 11-07-17 08:26:40, Vlastimil Babka wrote:
> >> On 07/11/2017 08:03 AM, Michal Hocko wrote:
> >>>
> >>> Are you telling me that two if conditions cause more than a second
> >>> difference? That sounds suspicious.
> >>
> >> It's removing also a call to get_unmapped_area(), AFAICS. That means a
> >> vma search?
> > 
> > Ohh, right. I have somehow missed that. Is this removal intentional?
> 
> I think it is: "Checking for availability of virtual address range at
> the end of the VMA for the incremental size is also reduntant at this
> point."

I though this referred to this check
	if (vma->vm_next && vma->vm_next->vm_start < end)

becuase get_unampped_area with MAP_FIXED doesn't really check
anything. It will simply return the given address. Btw. this also rules
out find_vma.
 
> > The
> > changelog is silent about it.
> 
> It doesn't explain why it's redundant, indeed. Unfortunately, the commit
> f106af4e90ea ("fix checks for expand-in-place mremap") which added this,
> also doesn't explain why it's needed.

Because it doesn't do anything AFAICS.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
