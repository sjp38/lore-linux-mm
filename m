Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC8786B0253
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 03:10:27 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y77so17360784pfd.2
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 00:10:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x18si4927998pge.118.2017.10.03.00.10.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 00:10:26 -0700 (PDT)
Date: Tue, 3 Oct 2017 09:10:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,hugetlb,migration: don't migrate kernelcore hugepages
Message-ID: <20171003071019.hdcdjwjabld4el4p@dhcp22.suse.cz>
References: <20171001225111.GA16432@gmail.com>
 <20171002125432.xiszy6xlvfb2jv67@dhcp22.suse.cz>
 <20171002140632.GA12673@gmail.com>
 <20171002142717.xwe2xymsr3oocxmg@dhcp22.suse.cz>
 <20171002150637.GA14321@gmail.com>
 <20171002161431.kmsrwtta7bwxn63q@dhcp22.suse.cz>
 <20171003054224.GA5025@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171003054224.GA5025@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexandru Moise <00moses.alexander00@gmail.com>
Cc: corbet@lwn.net, paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, tglx@linutronix.de, mingo@kernel.org, cdall@linaro.org, mchehab@kernel.org, zohar@linux.vnet.ibm.com, marc.zyngier@arm.com, rientjes@google.com, hannes@cmpxchg.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, punit.agrawal@arm.com, aarcange@redhat.com, gerald.schaefer@de.ibm.com, jglisse@redhat.com, kirill.shutemov@linux.intel.com, will.deacon@arm.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 03-10-17 07:42:25, Alexandru Moise wrote:
> On Mon, Oct 02, 2017 at 06:15:00PM +0200, Michal Hocko wrote:
[...]
> > I really fail to see why kernel vs. movable zones play any role here.
> > Zones should be mostly an implementation detail which userspace
> > shouldn't really care about.
> 
> Ok, the whole zone approach is a bad idea. Do you think that there's
> any value at all to trying to make hugepages un-movable at all?

I am not aware of any usecase, to be honest.

> Should
> the hugepages_treat_as_movable sysctl die and just make hugepages movable
> by default?

I think that hugepages_treat_as_movable is just a historical relict from
the time when hugetlb pages were not movable but the main purpose of
the movable zone was different back at the time. Just to clarifiy, the
original intention of the zone was to prevent memory fragmentation and
as hugetlb pages are not fragmenting memory because they are long lived
and contiguous, it was acceptable to use the zone. The purpose of the
zone has changed towards a migratability guarantee since then but the
knob has stayed behind. I think we should just remove it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
