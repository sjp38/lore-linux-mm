Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 673906B0311
	for <linux-mm@kvack.org>; Sat, 17 Jun 2017 02:51:48 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b19so6036472wmb.8
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 23:51:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 200si1019528wmw.0.2017.06.16.23.51.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 23:51:46 -0700 (PDT)
Date: Sat, 17 Jun 2017 08:51:43 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/hugetlb: Warn the user when issues arise on boot due
 to hugepages
Message-ID: <20170617065141.GB26698@dhcp22.suse.cz>
References: <20170605045725.GA9248@dhcp22.suse.cz>
 <20170605151541.avidrotxpoiekoy5@oracle.com>
 <20170606054917.GA1189@dhcp22.suse.cz>
 <20170606060147.GB1189@dhcp22.suse.cz>
 <20170612172829.bzjfmm7navnobh4t@oracle.com>
 <20170612174911.GA23493@dhcp22.suse.cz>
 <20170612183717.qgcusdfvdfcj7zr7@oracle.com>
 <20170612185208.GC23493@dhcp22.suse.cz>
 <20170613013516.7fcmvmoltwhxmtmp@oracle.com>
 <20170616120755.c56d205f49d93a6e3dffb14f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170616120755.c56d205f49d93a6e3dffb14f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Liam R. Howlett" <Liam.Howlett@Oracle.com>, linux-mm@kvack.org, mike.kravetz@Oracle.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, zhongjiang@huawei.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com

On Fri 16-06-17 12:07:55, Andrew Morton wrote:
> On Mon, 12 Jun 2017 21:35:17 -0400 "Liam R. Howlett" <Liam.Howlett@Oracle.com> wrote:
> 
> > > 
> > > > If there's no message stating any
> > > > configuration issue, then many admins would probably think something is
> > > > seriously broken and it's not just a simple typo of K vs M.
> > > > 
> > > > Even though this doesn't catch all errors, I think it's a worth while
> > > > change since this is currently a silent failure which results in a
> > > > system crash.
> > > 
> > > Seriously, this warning just doesn't help in _most_ miscofigurations. It
> > > just focuses on one particular which really requires to misconfigure
> > > really badly. And there are way too many other ways to screw your system
> > > that way, yet we do not warn about many of those. So just try to step
> > > back and think whether this is something we actually do care about and
> > > if yes then try to come up with a more reasonable warning which would
> > > cover a wider range of misconfigurations.
> > 
> > Understood.  Again, I appreciate all the time you have taken on my
> > patch and explaining your points.  I will look at this again as you
> > have suggested.
> 
> So do we want to drop
> mm-hugetlb-warn-the-user-when-issues-arise-on-boot-due-to-hugepages.patch?
> 
> I'd be inclined to keep it if Liam found it a bit useful - it does have
> some overhead, but half the patch is in __init code...

I would rather see a more generic warning that would catch more
misconfiguration than those ultimately broken ones. If we find out that
such a warning is not feasible then I would not oppose to go with the
current approach but let's try a bit harder before we go that way.

Liam, are you willing to go that way?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
