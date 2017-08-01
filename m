Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1AB4C6B0505
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 04:29:58 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id l3so1329632wrc.12
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 01:29:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 1si362322wrj.342.2017.08.01.01.29.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Aug 2017 01:29:57 -0700 (PDT)
Date: Tue, 1 Aug 2017 10:29:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/1] mm/hugetlb mm/oom_kill:  Add support for
 reclaiming hugepages on OOM events.
Message-ID: <20170801082952.GB15774@dhcp22.suse.cz>
References: <20170727180236.6175-2-Liam.Howlett@Oracle.com>
 <20170728064602.GC2274@dhcp22.suse.cz>
 <20170728113347.rrn5igjyllrj3z4n@node.shutemov.name>
 <20170728122350.GM2274@dhcp22.suse.cz>
 <20170728124443.GO2274@dhcp22.suse.cz>
 <20170729015638.lnazqgf5isjqqkqg@oracle.com>
 <20170731091025.GH15767@dhcp22.suse.cz>
 <20170731135647.wpzk56m5qrmz3xht@oracle.com>
 <20170731140810.GD4829@dhcp22.suse.cz>
 <20170801011124.co373mej7o6u7flu@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170801011124.co373mej7o6u7flu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@Oracle.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, punit.agrawal@arm.com, arnd@arndb.de, gerald.schaefer@de.ibm.com, aarcange@redhat.com, oleg@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, mingo@kernel.org, kirill.shutemov@linux.intel.com, vdavydov.dev@gmail.com, willy@infradead.org

On Mon 31-07-17 21:11:25, Liam R. Howlett wrote:
> * Michal Hocko <mhocko@kernel.org> [170731 10:08]:
> > On Mon 31-07-17 09:56:48, Liam R. Howlett wrote:
[...]
> > > No,  I'm talking about failed memory for whatever reason.  The system
> > > reboots by a hardware means (I believe the memory controller) and
> > > removes the memory on that failed module from the pool.  Now you
> > > effectively have a system with less memory than before which invalidates
> > > your configuration.  Is it worth while to have Linux successfully boot
> > > when the system attempts to recover from a failure?
> > 
> > Cetainly yes but if you boot with much less memory and you want to use
> > hugetlb pages then you have to reconsider and maybe even reconfigure
> > your workload to reflect new conditions. So I am not really sure this
> > can be fully automated.
> > 
> 
> I agree.  A reconfiguration or repair is required to have optimum
> performance.  Would you agree that having functioning system better than
> a reboot loop or hang on a panic?  It's also easier to reconfigure a
> system that's booting.

Absolutely. The thing is that I am not even sure that the hugetlb
problem is real. Using hugetlb reservation from the boot command line
parameter is easily fixable (just update the boot comand line from the
boot loader). From my experience the init time hugetlb initialization
is usually trying to be portable and as such configures a certain
percentage of the available memory for hugetlb (some of them even on per
NUMA node basis). Even if somebody uses hard coded values then this is
something that is fixable during recovery.

That being said I am not sure you are focusing on a real problem while
the solution you are proposing might break an existing userspace. Please
try to play with your memory recovery feature some more with real
hugetlb usecases (Oracle DB is a heavy user AFAIR) and see what the real
life problems might happen and we can revisit potential solutions with
more data in hands.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
