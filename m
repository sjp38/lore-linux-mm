Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8275F6B6A0F
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 11:16:38 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id p141so4403170ywg.17
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 08:16:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m185sor2274749ywb.64.2018.12.03.08.16.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 08:16:37 -0800 (PST)
Date: Mon, 3 Dec 2018 08:16:33 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v4 00/13] ktask: multithread CPU-intensive kernel work
Message-ID: <20181203161633.GK2509588@devbig004.ftw2.facebook.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181130191819.GJ2509588@devbig004.ftw2.facebook.com>
 <20181201001307.wmb6o4fuysnl7vcz@ca-dmjordan1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181201001307.wmb6o4fuysnl7vcz@ca-dmjordan1.us.oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, vbabka@suse.cz, peterz@infradead.org, dhaval.giani@oracle.com

Hello,

On Fri, Nov 30, 2018 at 04:13:07PM -0800, Daniel Jordan wrote:
> On Fri, Nov 30, 2018 at 11:18:19AM -0800, Tejun Heo wrote:
> > Hello,
> > 
> > On Mon, Nov 05, 2018 at 11:55:45AM -0500, Daniel Jordan wrote:
> > > Michal, you mentioned that ktask should be sensitive to CPU utilization[1].
> > > ktask threads now run at the lowest priority on the system to avoid disturbing
> > > busy CPUs (more details in patches 4 and 5).  Does this address your concern?
> > > The plan to address your other comments is explained below.
> > 
> > Have you tested what kind of impact this has on bandwidth of a system
> > in addition to latency?  The thing is while this would make a better
> > use of a system which has idle capacity, it does so by doing more
> > total work.  It'd be really interesting to see how this affects
> > bandwidth of a system too.
> 
> I guess you mean something like comparing aggregate CPU time across threads to
> the base single thread time for some job or set of jobs?  Then no, I haven't
> measured that, but I can for next time.

Yeah, I'm primarily curious how expensive this is on an already loaded
system, so sth like loading up the system with a workload which can
saturate the system and comparing the bw impacts of serial and
parallel page clearings at the same frequency.

Thanks.

-- 
tejun
