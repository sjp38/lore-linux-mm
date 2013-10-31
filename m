Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f79.google.com (mail-oa0-f79.google.com [209.85.219.79])
	by kanga.kvack.org (Postfix) with ESMTP id 51C8A6B003A
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 10:09:46 -0400 (EDT)
Received: by mail-oa0-f79.google.com with SMTP id k14so140645oag.2
        for <linux-mm@kvack.org>; Fri, 01 Nov 2013 07:09:46 -0700 (PDT)
Received: from psmtp.com ([74.125.245.156])
        by mx.google.com with SMTP id ru9si2015561pbc.318.2013.10.31.07.16.59
        for <linux-mm@kvack.org>;
        Thu, 31 Oct 2013 07:17:00 -0700 (PDT)
Date: Thu, 31 Oct 2013 10:14:09 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: + mm-memcg-use-proper-memcg-in-limit-bypass.patch added to -mm
 tree
Message-ID: <20131031141409.GD14054@cmpxchg.org>
References: <5271845f.Z9YgMQjBJAhXMdBZ%akpm@linux-foundation.org>
 <20131031083707.GA13144@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131031083707.GA13144@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Thu, Oct 31, 2013 at 09:37:07AM +0100, Michal Hocko wrote:
> On Wed 30-10-13 15:12:47, Andrew Morton wrote:
> > Subject: + mm-memcg-use-proper-memcg-in-limit-bypass.patch added to -mm tree
> > To: hannes@cmpxchg.org,mhocko@suse.cz
> > From: akpm@linux-foundation.org
> > Date: Wed, 30 Oct 2013 15:12:47 -0700
> > 
> > 
> > The patch titled
> >      Subject: mm: memcg: use proper memcg in limit bypass
> > has been added to the -mm tree.  Its filename is
> >      mm-memcg-use-proper-memcg-in-limit-bypass.patch
> > 
> > This patch should soon appear at
> >     http://ozlabs.org/~akpm/mmots/broken-out/mm-memcg-use-proper-memcg-in-limit-bypass.patch
> > and later at
> >     http://ozlabs.org/~akpm/mmotm/broken-out/mm-memcg-use-proper-memcg-in-limit-bypass.patch
> > 
> > Before you just go and hit "reply", please:
> >    a) Consider who else should be cc'ed
> >    b) Prefer to cc a suitable mailing list as well
> >    c) Ideally: find the original patch on the mailing list and do a
> >       reply-to-all to that, adding suitable additional cc's
> > 
> > *** Remember to use Documentation/SubmitChecklist when testing your code ***
> > 
> > The -mm tree is included into linux-next and is updated
> > there every 3-4 working days
> > 
> > ------------------------------------------------------
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > Subject: mm: memcg: use proper memcg in limit bypass
> > 
> > 84235de ("fs: buffer: move allocation failure loop into the allocator")
> > allowed __GFP_NOFAIL allocations to bypass the limit if they fail to
> > reclaim enough memory for the charge.  Because the main test case was on a
> > 3.2-based system, this patch missed the fact that on newer kernels the
> > charge function needs to return root_mem_cgroup when bypassing the limit,
> > and not NULL.  This will corrupt whatever memory is at NULL + percpu
> > pointer offset.  Fix this quickly before problems are reported.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@suse.cz>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> Acked-by: Michal Hocko <mhocko@suse.cz>
> 
> I guess this should be marked for stable as 84235de has been marked so.
> It would be also nice to mention that bypass with root_mem_cgroup
> happened at 3.3 times (it was done by 38c5d72f3ebe5 AFAICS).

I recalled the stable tag for the other patch, will send the full
series to stable once those patches have been in a release for some
time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
