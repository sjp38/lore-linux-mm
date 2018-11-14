Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 986C66B0003
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 16:41:16 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 33-v6so12953322pld.19
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 13:41:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g4sor28778041pgr.22.2018.11.14.13.41.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Nov 2018 13:41:15 -0800 (PST)
Date: Wed, 14 Nov 2018 13:41:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH] mm, proc: report PR_SET_THP_DISABLE in proc
In-Reply-To: <20181114132306.GX23419@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1811141336010.200345@chino.kir.corp.google.com>
References: <20181004094637.GG22173@dhcp22.suse.cz> <alpine.DEB.2.21.1810041130380.12951@chino.kir.corp.google.com> <20181009083326.GG8528@dhcp22.suse.cz> <20181015150325.GN18839@dhcp22.suse.cz> <alpine.DEB.2.21.1810151519250.247641@chino.kir.corp.google.com>
 <20181016104855.GQ18839@dhcp22.suse.cz> <alpine.DEB.2.21.1810161416540.83080@chino.kir.corp.google.com> <20181017070531.GC18839@dhcp22.suse.cz> <alpine.DEB.2.21.1810171256330.60837@chino.kir.corp.google.com> <20181018070031.GW18839@dhcp22.suse.cz>
 <20181114132306.GX23419@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Wed, 14 Nov 2018, Michal Hocko wrote:

> > > > Do you know of any other userspace except your usecase? Is there
> > > > anything fundamental that would prevent a proper API adoption for you?
> > > > 
> > > 
> > > Yes, it would require us to go back in time and build patched binaries. 
> > 
> > I read that as there is a fundamental problem to update existing
> > binaries. If that is the case then there surely is no way around it
> > and another sad page in the screwed up APIs book we provide.
> > 
> > But I was under impression that the SW stack which actually does the
> > monitoring is under your controll. Moreover I was under impression that
> > you do not use the current vanilla kernel so there is no need for an
> > immediate change on your end. It is trivial to come up with a backward
> > compatible way to check for the new flag (if it is not present then
> > fallback to vma flags).
> > 

The userspace had a single way to determine if thp had been disabled for a 
specific vma and that was broken with your commit.  We have since fixed 
it.  Modifying our software stack to start looking for some field 
somewhere else will not help anybody else that this has affected or will 
affect.  I'm interested in not breaking userspace, not trying a wait and 
see approach to see if anybody else complains once we start looking for 
some other field.  The risk outweighs the reward, it already broke us, and 
I'd prefer not to even open the possibility of breaking anybody else.
