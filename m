Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 29A9B6B5AED
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 19:13:31 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id s7-v6so4640738ybp.10
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 16:13:31 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id z63-v6si3974523yba.492.2018.11.30.16.13.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 16:13:29 -0800 (PST)
Date: Fri, 30 Nov 2018 16:13:07 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [RFC PATCH v4 00/13] ktask: multithread CPU-intensive kernel work
Message-ID: <20181201001307.wmb6o4fuysnl7vcz@ca-dmjordan1.us.oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181130191819.GJ2509588@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181130191819.GJ2509588@devbig004.ftw2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, vbabka@suse.cz, peterz@infradead.org, dhaval.giani@oracle.com

On Fri, Nov 30, 2018 at 11:18:19AM -0800, Tejun Heo wrote:
> Hello,
> 
> On Mon, Nov 05, 2018 at 11:55:45AM -0500, Daniel Jordan wrote:
> > Michal, you mentioned that ktask should be sensitive to CPU utilization[1].
> > ktask threads now run at the lowest priority on the system to avoid disturbing
> > busy CPUs (more details in patches 4 and 5).  Does this address your concern?
> > The plan to address your other comments is explained below.
> 
> Have you tested what kind of impact this has on bandwidth of a system
> in addition to latency?  The thing is while this would make a better
> use of a system which has idle capacity, it does so by doing more
> total work.  It'd be really interesting to see how this affects
> bandwidth of a system too.

I guess you mean something like comparing aggregate CPU time across threads to
the base single thread time for some job or set of jobs?  Then no, I haven't
measured that, but I can for next time.
