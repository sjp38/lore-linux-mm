Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 559316B04EC
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 07:22:56 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id l34so30960372wrc.12
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 04:22:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f57si10403203wrf.145.2017.07.11.04.22.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 04:22:55 -0700 (PDT)
Date: Tue, 11 Jul 2017 13:22:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] mm/mremap: Remove redundant checks inside vma_expandable()
Message-ID: <20170711112253.GA11936@dhcp22.suse.cz>
References: <20170710111059.30795-1-khandual@linux.vnet.ibm.com>
 <20170710134917.GB19645@dhcp22.suse.cz>
 <d6f9ec12-4518-8f97-eca9-6592808b839d@linux.vnet.ibm.com>
 <20170711060354.GA24852@dhcp22.suse.cz>
 <4c182da0-6c84-df67-b173-6960fac0544a@suse.cz>
 <20170711065030.GE24852@dhcp22.suse.cz>
 <337a8a4c-1f27-7371-409d-6a9f181b3871@suse.cz>
 <8bcc5908-7f0d-ba5c-a484-e0763f9b7664@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8bcc5908-7f0d-ba5c-a484-e0763f9b7664@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com

On Tue 11-07-17 16:38:46, Anshuman Khandual wrote:
> On 07/11/2017 12:26 PM, Vlastimil Babka wrote:
> > On 07/11/2017 08:50 AM, Michal Hocko wrote:
> >> On Tue 11-07-17 08:26:40, Vlastimil Babka wrote:
> >>> On 07/11/2017 08:03 AM, Michal Hocko wrote:
> >>>>
> >>>> Are you telling me that two if conditions cause more than a second
> >>>> difference? That sounds suspicious.
> >>>
> >>> It's removing also a call to get_unmapped_area(), AFAICS. That means a
> >>> vma search?
> >>
> >> Ohh, right. I have somehow missed that. Is this removal intentional?
> > 
> > I think it is: "Checking for availability of virtual address range at
> > the end of the VMA for the incremental size is also reduntant at this
> > point."
> > 
> >> The
> >> changelog is silent about it.
> > 
> > It doesn't explain why it's redundant, indeed. Unfortunately, the commit
> > f106af4e90ea ("fix checks for expand-in-place mremap") which added this,
> > also doesn't explain why it's needed.
> 
> Its redundant because there are calls to get_unmapped_area() down the
> line in the function whose failure will anyway fail the expansion of
> the VMA.

mremap code is quite complex and I am not sure you are right here.
Anyway, please make sure you document why you believe those checks are
not needed when resubmitting your patch.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
