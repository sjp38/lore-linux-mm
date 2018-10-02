Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 080556B0005
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 16:29:46 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y7-v6so3878350plp.16
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 13:29:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q129-v6sor5163470pga.31.2018.10.02.13.29.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Oct 2018 13:29:44 -0700 (PDT)
Date: Tue, 2 Oct 2018 13:29:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH] mm, proc: report PR_SET_THP_DISABLE in proc
In-Reply-To: <20181002112851.GP18290@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1810021329260.87409@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1809241215170.239142@chino.kir.corp.google.com> <alpine.DEB.2.21.1809241227370.241621@chino.kir.corp.google.com> <20180924195603.GJ18685@dhcp22.suse.cz> <20180924200258.GK18685@dhcp22.suse.cz> <0aa3eb55-82c0-eba3-b12c-2ba22e052a8e@suse.cz>
 <alpine.DEB.2.21.1809251248450.50347@chino.kir.corp.google.com> <20180925202959.GY18685@dhcp22.suse.cz> <alpine.DEB.2.21.1809251440001.94921@chino.kir.corp.google.com> <20180925150406.872aab9f4f945193e5915d69@linux-foundation.org> <20180926060624.GA18685@dhcp22.suse.cz>
 <20181002112851.GP18290@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Tue, 2 Oct 2018, Michal Hocko wrote:

> On Wed 26-09-18 08:06:24, Michal Hocko wrote:
> > On Tue 25-09-18 15:04:06, Andrew Morton wrote:
> > > On Tue, 25 Sep 2018 14:45:19 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> > > 
> > > > > > It is also used in 
> > > > > > automated testing to ensure that vmas get disabled for thp appropriately 
> > > > > > and we used "nh" since that is how PR_SET_THP_DISABLE previously enforced 
> > > > > > this, and those tests now break.
> > > > > 
> > > > > This sounds like a bit of an abuse to me. It shows how an internal
> > > > > implementation detail leaks out to the userspace which is something we
> > > > > should try to avoid.
> > > > > 
> > > > 
> > > > Well, it's already how this has worked for years before commit 
> > > > 1860033237d4 broke it.  Changing the implementation in the kernel is fine 
> > > > as long as you don't break userspace who relies on what is exported to it 
> > > > and is the only way to determine if MADV_NOHUGEPAGE is preventing it from 
> > > > being backed by hugepages.
> > > 
> > > 1860033237d4 was over a year ago so perhaps we don't need to be
> > > too worried about restoring the old interface.  In which case
> > > we have an opportunity to make improvements such as that suggested
> > > by Michal?
> > 
> > Yeah, can we add a way to export PR_SET_THP_DISABLE to userspace
> > somehow? E.g. /proc/<pid>/status. It is a process wide thing so
> > reporting it per VMA sounds strange at best.
> 
> So how about this? (not tested yet but it should be pretty
> straightforward)

Umm, prctl(PR_GET_THP_DISABLE)?
