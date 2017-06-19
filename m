Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F8096B02C3
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 15:59:54 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id l2so85047310ybb.6
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 12:59:54 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id v184si2954630ybv.369.2017.06.19.12.59.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 12:59:53 -0700 (PDT)
Date: Mon, 19 Jun 2017 15:59:35 -0400
From: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Subject: Re: [PATCH] mm/hugetlb: Warn the user when issues arise on boot due
 to hugepages
Message-ID: <20170619195935.tymymev7bntslxci@oracle.com>
References: <20170605151541.avidrotxpoiekoy5@oracle.com>
 <20170606054917.GA1189@dhcp22.suse.cz>
 <20170606060147.GB1189@dhcp22.suse.cz>
 <20170612172829.bzjfmm7navnobh4t@oracle.com>
 <20170612174911.GA23493@dhcp22.suse.cz>
 <20170612183717.qgcusdfvdfcj7zr7@oracle.com>
 <20170612185208.GC23493@dhcp22.suse.cz>
 <20170613013516.7fcmvmoltwhxmtmp@oracle.com>
 <20170616120755.c56d205f49d93a6e3dffb14f@linux-foundation.org>
 <20170617065141.GB26698@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170617065141.GB26698@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, mike.kravetz@Oracle.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, zhongjiang@huawei.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com

* Michal Hocko <mhocko@suse.com> [170617 02:51]:
> On Fri 16-06-17 12:07:55, Andrew Morton wrote:
> > On Mon, 12 Jun 2017 21:35:17 -0400 "Liam R. Howlett" <Liam.Howlett@Oracle.com> wrote:
> > 
> > > > 
> > > > > If there's no message stating any
> > > > > configuration issue, then many admins would probably think something is
> > > > > seriously broken and it's not just a simple typo of K vs M.
> > > > > 
> > > > > Even though this doesn't catch all errors, I think it's a worth while
> > > > > change since this is currently a silent failure which results in a
> > > > > system crash.
> > > > 
> > > > Seriously, this warning just doesn't help in _most_ miscofigurations. It
> > > > just focuses on one particular which really requires to misconfigure
> > > > really badly. And there are way too many other ways to screw your system
> > > > that way, yet we do not warn about many of those. So just try to step
> > > > back and think whether this is something we actually do care about and
> > > > if yes then try to come up with a more reasonable warning which would
> > > > cover a wider range of misconfigurations.
> > > 
> > > Understood.  Again, I appreciate all the time you have taken on my
> > > patch and explaining your points.  I will look at this again as you
> > > have suggested.
> > 
> > So do we want to drop
> > mm-hugetlb-warn-the-user-when-issues-arise-on-boot-due-to-hugepages.patch?
> > 
> > I'd be inclined to keep it if Liam found it a bit useful - it does have
> > some overhead, but half the patch is in __init code...
> 
> I would rather see a more generic warning that would catch more
> misconfiguration than those ultimately broken ones. If we find out that
> such a warning is not feasible then I would not oppose to go with the
> current approach but let's try a bit harder before we go that way.
> 
> Liam, are you willing to go that way?

As I see it, and as you have pointed out, we can only be sure it's an
error if it's over 100% of the memory.  Although it's certainly worth
while looking for a way to detect an incorrect configuration that
doesn't meet this criteria, I'm not sure it's worth holding out to make
the change.  I think giving any direct message could save someone a lot
of debug time.  If it's okay, I'd like to go ahead with the change and
also look for a way to correct and notify of a broader range of
configurations that cause severe issues in regards to hugepages.

Thanks,
Liam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
