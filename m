Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id ACB5E6B002B
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 09:16:46 -0400 (EDT)
Date: Fri, 10 Aug 2012 15:16:43 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] hugetlb: correct page offset index for sharing pmd
Message-ID: <20120810131643.GC1425@dhcp22.suse.cz>
References: <CAJd=RBB=jKD+9JcuBmBGC8R8pAQ-QoWHexMNMsXpb9zV548h5g@mail.gmail.com>
 <20120803133235.GA8434@dhcp22.suse.cz>
 <20120810094825.GA1440@dhcp22.suse.cz>
 <CAJd=RBDA3pLYDpryxafx6dLoy7Fk8PmY-EFkXCkuJTB2ywfsjA@mail.gmail.com>
 <20120810122730.GA1425@dhcp22.suse.cz>
 <CAJd=RBAvCd-QcyN9N4xWEiLeVqRypzCzbADvD1qTziRVCHjd4Q@mail.gmail.com>
 <20120810125102.GB1425@dhcp22.suse.cz>
 <CAJd=RBB8Yuk1FEQxTUbEEeD96oqnO26VojetuDgRo=JxOfnadw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBB8Yuk1FEQxTUbEEeD96oqnO26VojetuDgRo=JxOfnadw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>

[CCing Kamezawa and David]

On Fri 10-08-12 20:53:36, Hillf Danton wrote:
> On Fri, Aug 10, 2012 at 8:51 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Fri 10-08-12 20:37:20, Hillf Danton wrote:
> >> On Fri, Aug 10, 2012 at 8:27 PM, Michal Hocko <mhocko@suse.cz> wrote:
> >> >
> >> > I guess you mean unmap_ref_private and that has been changed by you
> >> > (0c176d5 mm: hugetlb: fix pgoff computation when unmapping page from
> >> > vma)...  I was wrong at that time when giving my Reviewed-by. The patch
> >> > didn't break anything because you still find all relevant vmas because
> >> > vma_hugecache_offset just provides a smaller index which is still within
> >> > boundaries.
> >>
> >> No, as shown by the log message of 0c176d52b,  that fix was
> >> triggered by  (vma->vm_pgoff >> PAGE_SHIFT), thus I dont see
> >> what you really want to revert.
> >
> > fix for that would be a part of the revert of course.
> >
> 
> Fine, go ahead ;)

there you go
---
