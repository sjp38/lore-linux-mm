Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id F3C0E6B7A09
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 14:08:58 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id m9-v6so3893468eds.17
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 11:08:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h20-v6si1725851edv.329.2018.09.06.11.08.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 11:08:57 -0700 (PDT)
Date: Thu, 6 Sep 2018 20:08:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm: Move page struct poisoning to
 CONFIG_DEBUG_VM_PAGE_INIT_POISON
Message-ID: <20180906180854.GG14951@dhcp22.suse.cz>
References: <20180905211041.3286.19083.stgit@localhost.localdomain>
 <20180905211328.3286.71674.stgit@localhost.localdomain>
 <20180906054735.GJ14951@dhcp22.suse.cz>
 <0c1c36f7-f45a-8fe9-dd52-0f60b42064a9@intel.com>
 <20180906151336.GD14951@dhcp22.suse.cz>
 <CAKgT0UfiKWZO6hyjc1RpRTgD+CvM=KnbYokSueLFi7X5h+GMKQ@mail.gmail.com>
 <4f154937-118c-96cf-cf8e-c95a2ca68d44@microsoft.com>
 <c5dc8ef6-587d-e286-af80-568094a65007@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c5dc8ef6-587d-e286-af80-568094a65007@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Pasha Tatashin <Pavel.Tatashin@microsoft.com>, Alexander Duyck <alexander.duyck@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Duyck, Alexander H" <alexander.h.duyck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu 06-09-18 10:07:51, Dave Hansen wrote:
> On 09/06/2018 09:12 AM, Pasha Tatashin wrote:
> > 
> > I do not want to make this feature less tested. Poisoning memory allowed
> > us to catch corner case bugs like these:
> > 
> > ab1e8d8960b68f54af42b6484b5950bd13a4054b
> > mm: don't allow deferred pages with NEED_PER_CPU_KM
> > 
> > e181ae0c5db9544de9c53239eb22bc012ce75033
> > mm: zero unavailable pages before memmap init
> > 
> > And several more that were fixed by other people.
> 
> Just curious: were these found in the wild, or by a developer doing
> normal development having turned on lots of debug options?

Some of those were 0day AFAIR but my memory is quite dim. Pavel will
know better. The bottom line is, however, that those bugs depend on
strange or unexpected memory configurations or HW which is usually
deployed outside of developers machine pool. So more people have this
enabled the more likely we hit all those strange corner cases nobody
even thought of.

-- 
Michal Hocko
SUSE Labs
