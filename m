Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7196B0279
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 11:25:23 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id c204so9543270vke.1
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 08:25:23 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id p2si99823vkd.138.2017.06.13.08.25.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 08:25:22 -0700 (PDT)
Date: Tue, 13 Jun 2017 11:25:02 -0400
From: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Subject: Re: [PATCH] mm/hugetlb: Warn the user when issues arise on boot due
 to hugepages
Message-ID: <20170613152501.w27r2q2agy4sue5x@oracle.com>
References: <20170605045725.GA9248@dhcp22.suse.cz>
 <20170605151541.avidrotxpoiekoy5@oracle.com>
 <20170606054917.GA1189@dhcp22.suse.cz>
 <20170606060147.GB1189@dhcp22.suse.cz>
 <20170612172829.bzjfmm7navnobh4t@oracle.com>
 <20170612174911.GA23493@dhcp22.suse.cz>
 <20170612183717.qgcusdfvdfcj7zr7@oracle.com>
 <20170612185208.GC23493@dhcp22.suse.cz>
 <20170613013516.7fcmvmoltwhxmtmp@oracle.com>
 <20170613054204.GB5363@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170613054204.GB5363@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mike.kravetz@Oracle.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, zhongjiang@huawei.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com

* Michal Hocko <mhocko@suse.com> [170613 01:42]:
> On Mon 12-06-17 21:35:17, Liam R. Howlett wrote:
> [...]
> > Understood.  Again, I appreciate all the time you have taken on my
> > patch and explaining your points.  I will look at this again as you
> > have suggested.
> 
> One way to go forward might be to check the size of the per node pool
> and warn if it grows over a certain threshold of the available memory
> on that node. I do not have a good idea what would be that threshold,
> though. It will certainly depend on workloads. I can also imagine that
> somebody might want to dedicate the full numa node for hugetlb pages
> and still be OK so take this suggestion with some reserve. It is hard
> to protect against misconfigurations in general but maybe you will find
> some way here.

I thought about an upper threshold of memory and discussed it
internally, but came to the same conclusion; it may be desired and
there's no safe bet beyond warning if the user requests over 100% of the
memory.  In the case of requesting over 100% of the memory, we could
warn the user and specify what was allocated.  Would it be reasonable to
warn on both boot and through sysfs of such requests?  I'm concerned
that this is yet another too-targeted approach.

The OOM issue would still arise much later in boot for the init
situation.  I have an OOM patch I'd like to send out for another hugetlb
corner case which may improve this situation.  I was going to send it
out separately as I thought of it as unrelated to this scenario and I
believe it should be a config option.  The OOM patch has its own issues
and would only be an RFC at this point.

Thanks,
Liam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
