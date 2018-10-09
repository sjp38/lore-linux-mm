Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 688AE6B0005
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 08:27:48 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h24-v6so1156485eda.10
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 05:27:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m18-v6si7523798edf.133.2018.10.09.05.27.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 05:27:46 -0700 (PDT)
Date: Tue, 9 Oct 2018 14:27:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-ID: <20181009122745.GN8528@dhcp22.suse.cz>
References: <20180925120326.24392-1-mhocko@kernel.org>
 <20180925120326.24392-2-mhocko@kernel.org>
 <alpine.DEB.2.21.1810041302330.16935@chino.kir.corp.google.com>
 <20181005073854.GB6931@suse.de>
 <alpine.DEB.2.21.1810051320270.202739@chino.kir.corp.google.com>
 <20181005232155.GA2298@redhat.com>
 <alpine.DEB.2.21.1810081303060.221006@chino.kir.corp.google.com>
 <20181009094825.GC6931@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181009094825.GC6931@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

[Sorry for being slow in responding but I was mostly offline last few
 days]

On Tue 09-10-18 10:48:25, Mel Gorman wrote:
[...]
> This goes back to my point that the MADV_HUGEPAGE hint should not make
> promises about locality and that introducing MADV_LOCAL for specialised
> libraries may be more appropriate with the initial semantic being how it
> treats MADV_HUGEPAGE regions.

I agree with your other points and not going to repeat them. I am not
sure madvise s the best API for the purpose though. We are talking about
memory policy here and there is an existing api for that so I would
_prefer_ to reuse it for this purpose.

Sure we will likely need somethin in the compaction as well but we
should start simple and go forward in smaller steps.
-- 
Michal Hocko
SUSE Labs
