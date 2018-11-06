Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B079B6B02EC
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 04:21:48 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id r20-v6so4219730eds.18
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 01:21:48 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v9-v6si1584485eje.240.2018.11.06.01.21.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 01:21:47 -0800 (PST)
Date: Tue, 6 Nov 2018 10:21:45 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH v4 00/13] ktask: multithread CPU-intensive kernel work
Message-ID: <20181106092145.GF27423@dhcp22.suse.cz>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105172931.GP4361@dhcp22.suse.cz>
 <20181106012955.br5swua3ykvolyjq@ca-dmjordan1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181106012955.br5swua3ykvolyjq@ca-dmjordan1.us.oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

On Mon 05-11-18 17:29:55, Daniel Jordan wrote:
> On Mon, Nov 05, 2018 at 06:29:31PM +0100, Michal Hocko wrote:
> > On Mon 05-11-18 11:55:45, Daniel Jordan wrote:
> > > Michal, you mentioned that ktask should be sensitive to CPU utilization[1].
> > > ktask threads now run at the lowest priority on the system to avoid disturbing
> > > busy CPUs (more details in patches 4 and 5).  Does this address your concern?
> > > The plan to address your other comments is explained below.
> > 
> > I have only glanced through the documentation patch and it looks like it
> > will be much less disruptive than the previous attempts. Now the obvious
> > question is how does this behave on a moderately or even busy system
> > when you compare that to a single threaded execution. Some numbers about
> > best/worst case execution would be really helpful.
> 
> Patches 4 and 5 have some numbers where a ktask and non-ktask workload compete
> against each other.  Those show either 8 ktask threads on 8 CPUs (worst case) or no ktask threads (best case).
> 
> By single threaded execution, I guess you mean 1 ktask thread.  I'll run the
> experiments that way too and post the numbers.

I mean a comparision of how much time it gets to accomplish the same
amount of work if it was done singlethreaded to ktask based distribution
on a idle system (best case for both) and fully contended system (the
worst case). It would be also great to get some numbers on partially
contended system to see how much the priority handover etc. acts under
different CPU contention.
-- 
Michal Hocko
SUSE Labs
