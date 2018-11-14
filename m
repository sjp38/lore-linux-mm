Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5AAF06B0003
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 08:23:10 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id z72-v6so8273019ede.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 05:23:10 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n10-v6si8190452edf.156.2018.11.14.05.23.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 05:23:08 -0800 (PST)
Date: Wed, 14 Nov 2018 14:23:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, proc: report PR_SET_THP_DISABLE in proc
Message-ID: <20181114132306.GX23419@dhcp22.suse.cz>
References: <20181004094637.GG22173@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810041130380.12951@chino.kir.corp.google.com>
 <20181009083326.GG8528@dhcp22.suse.cz>
 <20181015150325.GN18839@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810151519250.247641@chino.kir.corp.google.com>
 <20181016104855.GQ18839@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810161416540.83080@chino.kir.corp.google.com>
 <20181017070531.GC18839@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810171256330.60837@chino.kir.corp.google.com>
 <20181018070031.GW18839@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018070031.GW18839@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Thu 18-10-18 09:00:31, Michal Hocko wrote:
> On Wed 17-10-18 12:59:18, David Rientjes wrote:
> > On Wed, 17 Oct 2018, Michal Hocko wrote:
> > 
> > > Do you know of any other userspace except your usecase? Is there
> > > anything fundamental that would prevent a proper API adoption for you?
> > > 
> > 
> > Yes, it would require us to go back in time and build patched binaries. 
> 
> I read that as there is a fundamental problem to update existing
> binaries. If that is the case then there surely is no way around it
> and another sad page in the screwed up APIs book we provide.
> 
> But I was under impression that the SW stack which actually does the
> monitoring is under your controll. Moreover I was under impression that
> you do not use the current vanilla kernel so there is no need for an
> immediate change on your end. It is trivial to come up with a backward
> compatible way to check for the new flag (if it is not present then
> fallback to vma flags).
> 
> I am sorry for pushing here but if this is just a matter of a _single_
> user which _can_ be fixed with a reasonable effort then I would love to
> see the future api unscrewed.

ping
-- 
Michal Hocko
SUSE Labs
