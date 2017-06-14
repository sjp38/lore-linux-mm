Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B9C316B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 03:25:41 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g46so5240266wrd.3
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 00:25:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t131si596133wmb.109.2017.06.14.00.25.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 00:25:40 -0700 (PDT)
Date: Wed, 14 Jun 2017 09:25:36 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/hugetlb: Warn the user when issues arise on boot due
 to hugepages
Message-ID: <20170614072536.GG6045@dhcp22.suse.cz>
References: <20170605151541.avidrotxpoiekoy5@oracle.com>
 <20170606054917.GA1189@dhcp22.suse.cz>
 <20170606060147.GB1189@dhcp22.suse.cz>
 <20170612172829.bzjfmm7navnobh4t@oracle.com>
 <20170612174911.GA23493@dhcp22.suse.cz>
 <20170612183717.qgcusdfvdfcj7zr7@oracle.com>
 <20170612185208.GC23493@dhcp22.suse.cz>
 <20170613013516.7fcmvmoltwhxmtmp@oracle.com>
 <20170613054204.GB5363@dhcp22.suse.cz>
 <20170613152501.w27r2q2agy4sue5x@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170613152501.w27r2q2agy4sue5x@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mike.kravetz@Oracle.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, zhongjiang@huawei.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com

On Tue 13-06-17 11:25:02, Liam R. Howlett wrote:
> * Michal Hocko <mhocko@suse.com> [170613 01:42]:
> > On Mon 12-06-17 21:35:17, Liam R. Howlett wrote:
> > [...]
> > > Understood.  Again, I appreciate all the time you have taken on my
> > > patch and explaining your points.  I will look at this again as you
> > > have suggested.
> > 
> > One way to go forward might be to check the size of the per node pool
> > and warn if it grows over a certain threshold of the available memory
> > on that node. I do not have a good idea what would be that threshold,
> > though. It will certainly depend on workloads. I can also imagine that
> > somebody might want to dedicate the full numa node for hugetlb pages
> > and still be OK so take this suggestion with some reserve. It is hard
> > to protect against misconfigurations in general but maybe you will find
> > some way here.
> 
> I thought about an upper threshold of memory and discussed it
> internally, but came to the same conclusion; it may be desired and
> there's no safe bet beyond warning if the user requests over 100% of the
> memory.  In the case of requesting over 100% of the memory, we could
> warn the user and specify what was allocated.  Would it be reasonable to
> warn on both boot and through sysfs of such requests?  I'm concerned
> that this is yet another too-targeted approach.

No, I think 100% is just too targeted. As I've said already said, a good
enough treshold might be hard to get right but filling up more than 90%
of memory with hugetlb pages will just bite you unless you know what you
are doing. And if so you can safely ignore such a warning...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
