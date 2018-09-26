Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CC0B98E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 02:06:27 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e11so698543edv.20
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 23:06:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c8-v6si2669988edc.311.2018.09.25.23.06.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 23:06:26 -0700 (PDT)
Date: Wed, 26 Sep 2018 08:06:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, thp: always specify ineligible vmas as nh in smaps
Message-ID: <20180926060624.GA18685@dhcp22.suse.cz>
References: <e2f159f3-5373-dda4-5904-ed24d029de3c@suse.cz>
 <alpine.DEB.2.21.1809241215170.239142@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1809241227370.241621@chino.kir.corp.google.com>
 <20180924195603.GJ18685@dhcp22.suse.cz>
 <20180924200258.GK18685@dhcp22.suse.cz>
 <0aa3eb55-82c0-eba3-b12c-2ba22e052a8e@suse.cz>
 <alpine.DEB.2.21.1809251248450.50347@chino.kir.corp.google.com>
 <20180925202959.GY18685@dhcp22.suse.cz>
 <alpine.DEB.2.21.1809251440001.94921@chino.kir.corp.google.com>
 <20180925150406.872aab9f4f945193e5915d69@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180925150406.872aab9f4f945193e5915d69@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Tue 25-09-18 15:04:06, Andrew Morton wrote:
> On Tue, 25 Sep 2018 14:45:19 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> 
> > > > It is also used in 
> > > > automated testing to ensure that vmas get disabled for thp appropriately 
> > > > and we used "nh" since that is how PR_SET_THP_DISABLE previously enforced 
> > > > this, and those tests now break.
> > > 
> > > This sounds like a bit of an abuse to me. It shows how an internal
> > > implementation detail leaks out to the userspace which is something we
> > > should try to avoid.
> > > 
> > 
> > Well, it's already how this has worked for years before commit 
> > 1860033237d4 broke it.  Changing the implementation in the kernel is fine 
> > as long as you don't break userspace who relies on what is exported to it 
> > and is the only way to determine if MADV_NOHUGEPAGE is preventing it from 
> > being backed by hugepages.
> 
> 1860033237d4 was over a year ago so perhaps we don't need to be
> too worried about restoring the old interface.  In which case
> we have an opportunity to make improvements such as that suggested
> by Michal?

Yeah, can we add a way to export PR_SET_THP_DISABLE to userspace
somehow? E.g. /proc/<pid>/status. It is a process wide thing so
reporting it per VMA sounds strange at best.

This would also keep a sane (and currently documented) semantic for
the smaps flag to be really
    hg  - huge page advise flag
    nh  - no-huge page advise flag
-- 
Michal Hocko
SUSE Labs
