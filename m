Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 414A46B0007
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 03:36:46 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 8-v6so2330331pfr.0
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 00:36:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i5-v6si650154pgn.314.2018.10.03.00.36.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 00:36:45 -0700 (PDT)
Date: Wed, 3 Oct 2018 09:36:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, proc: report PR_SET_THP_DISABLE in proc
Message-ID: <20181003073640.GF18290@dhcp22.suse.cz>
References: <20180924195603.GJ18685@dhcp22.suse.cz>
 <20180924200258.GK18685@dhcp22.suse.cz>
 <0aa3eb55-82c0-eba3-b12c-2ba22e052a8e@suse.cz>
 <alpine.DEB.2.21.1809251248450.50347@chino.kir.corp.google.com>
 <20180925202959.GY18685@dhcp22.suse.cz>
 <alpine.DEB.2.21.1809251440001.94921@chino.kir.corp.google.com>
 <20180925150406.872aab9f4f945193e5915d69@linux-foundation.org>
 <20180926060624.GA18685@dhcp22.suse.cz>
 <20181002112851.GP18290@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810021329260.87409@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1810021329260.87409@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Tue 02-10-18 13:29:42, David Rientjes wrote:
> On Tue, 2 Oct 2018, Michal Hocko wrote:
> 
> > On Wed 26-09-18 08:06:24, Michal Hocko wrote:
> > > On Tue 25-09-18 15:04:06, Andrew Morton wrote:
> > > > On Tue, 25 Sep 2018 14:45:19 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> > > > 
> > > > > > > It is also used in 
> > > > > > > automated testing to ensure that vmas get disabled for thp appropriately 
> > > > > > > and we used "nh" since that is how PR_SET_THP_DISABLE previously enforced 
> > > > > > > this, and those tests now break.
> > > > > > 
> > > > > > This sounds like a bit of an abuse to me. It shows how an internal
> > > > > > implementation detail leaks out to the userspace which is something we
> > > > > > should try to avoid.
> > > > > > 
> > > > > 
> > > > > Well, it's already how this has worked for years before commit 
> > > > > 1860033237d4 broke it.  Changing the implementation in the kernel is fine 
> > > > > as long as you don't break userspace who relies on what is exported to it 
> > > > > and is the only way to determine if MADV_NOHUGEPAGE is preventing it from 
> > > > > being backed by hugepages.
> > > > 
> > > > 1860033237d4 was over a year ago so perhaps we don't need to be
> > > > too worried about restoring the old interface.  In which case
> > > > we have an opportunity to make improvements such as that suggested
> > > > by Michal?
> > > 
> > > Yeah, can we add a way to export PR_SET_THP_DISABLE to userspace
> > > somehow? E.g. /proc/<pid>/status. It is a process wide thing so
> > > reporting it per VMA sounds strange at best.
> > 
> > So how about this? (not tested yet but it should be pretty
> > straightforward)
> 
> Umm, prctl(PR_GET_THP_DISABLE)?

/me confused. I thought you want to query for the flag on a
_different_ process. 
-- 
Michal Hocko
SUSE Labs
