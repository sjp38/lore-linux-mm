Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1C2AD6B04C4
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 02:50:37 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z45so29316473wrb.13
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 23:50:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l11si10511998wrl.217.2017.07.10.23.50.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 23:50:36 -0700 (PDT)
Date: Tue, 11 Jul 2017 08:50:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] mm/mremap: Remove redundant checks inside vma_expandable()
Message-ID: <20170711065030.GE24852@dhcp22.suse.cz>
References: <20170710111059.30795-1-khandual@linux.vnet.ibm.com>
 <20170710134917.GB19645@dhcp22.suse.cz>
 <d6f9ec12-4518-8f97-eca9-6592808b839d@linux.vnet.ibm.com>
 <20170711060354.GA24852@dhcp22.suse.cz>
 <4c182da0-6c84-df67-b173-6960fac0544a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4c182da0-6c84-df67-b173-6960fac0544a@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com

On Tue 11-07-17 08:26:40, Vlastimil Babka wrote:
> On 07/11/2017 08:03 AM, Michal Hocko wrote:
> > On Tue 11-07-17 09:58:42, Anshuman Khandual wrote:
> >>> here. This is hardly something that would save many cycles in a
> >>> relatively cold path.
> >>
> >> Though I have not done any detailed instruction level measurement,
> >> there is a reduction in real and system amount of time to execute
> >> the test with and without the patch.
> >>
> >> Without the patch
> >>
> >> real	0m2.100s
> >> user	0m0.162s
> >> sys	0m1.937s
> >>
> >> With this patch
> >>
> >> real	0m0.928s
> >> user	0m0.161s
> >> sys	0m0.756s
> > 
> > Are you telling me that two if conditions cause more than a second
> > difference? That sounds suspicious.
> 
> It's removing also a call to get_unmapped_area(), AFAICS. That means a
> vma search?

Ohh, right. I have somehow missed that. Is this removal intentional? The
changelog is silent about it.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
