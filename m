Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 64F356B000A
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 18:51:08 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id ce7-v6so6781881plb.22
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 15:51:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y4-v6sor2418679pfm.45.2018.10.03.15.51.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Oct 2018 15:51:07 -0700 (PDT)
Date: Wed, 3 Oct 2018 15:51:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH] mm, proc: report PR_SET_THP_DISABLE in proc
In-Reply-To: <20181003073640.GF18290@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1810031547150.202532@chino.kir.corp.google.com>
References: <20180924195603.GJ18685@dhcp22.suse.cz> <20180924200258.GK18685@dhcp22.suse.cz> <0aa3eb55-82c0-eba3-b12c-2ba22e052a8e@suse.cz> <alpine.DEB.2.21.1809251248450.50347@chino.kir.corp.google.com> <20180925202959.GY18685@dhcp22.suse.cz>
 <alpine.DEB.2.21.1809251440001.94921@chino.kir.corp.google.com> <20180925150406.872aab9f4f945193e5915d69@linux-foundation.org> <20180926060624.GA18685@dhcp22.suse.cz> <20181002112851.GP18290@dhcp22.suse.cz> <alpine.DEB.2.21.1810021329260.87409@chino.kir.corp.google.com>
 <20181003073640.GF18290@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Wed, 3 Oct 2018, Michal Hocko wrote:

> > > So how about this? (not tested yet but it should be pretty
> > > straightforward)
> > 
> > Umm, prctl(PR_GET_THP_DISABLE)?
> 
> /me confused. I thought you want to query for the flag on a
> _different_ process. 

Why would we want to check three locations (system wide setting, prctl 
setting, madvise setting) to determine if a heap can be backed by thp?

If the nh flag being exported to VmFlag is to be extended beyond what my 
patch did, I suggest (1) it does it for the system wide setting as well 
and/or (2) calling a helper function to determine if the vma could be 
backed by thp in the first place regardless of any setting to determine if 
nh/hg is important.

The last thing I suggest is done is adding a third place to check.
