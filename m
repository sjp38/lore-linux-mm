Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id DCC026B02A7
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 21:28:04 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id g14-v6so361403ybf.12
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 18:28:04 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id e195-v6si29735138ywa.54.2018.11.05.18.28.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 18:28:03 -0800 (PST)
Date: Mon, 5 Nov 2018 18:27:47 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [RFC PATCH v4 01/13] ktask: add documentation
Message-ID: <20181106022747.dmtq24pvulcnv3lc@ca-dmjordan1.us.oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105165558.11698-2-daniel.m.jordan@oracle.com>
 <7693f8a2-e180-520a-0d07-cc3090d2139f@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7693f8a2-e180-520a-0d07-cc3090d2139f@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

On Mon, Nov 05, 2018 at 01:19:50PM -0800, Randy Dunlap wrote:
> On 11/5/18 8:55 AM, Daniel Jordan wrote:
> 
> Hi,
> 
> > +Resource Limits
> > +===============
> > +
> > +ktask has resource limits on the number of work items it sends to workqueue.
> 
>                                                                   to a workqueue.
> or:                                                               to workqueues.

Ok, I'll do "to workqueues" since ktask uses two internally (NUMA-aware and
non-NUMA-aware).

> 
> > +In ktask, a workqueue item is a thread that runs chunks of the task until the
> > +task is finished.
> > +
> > +These limits support the different ways ktask uses workqueues:
> > + - ktask_run to run threads on the calling thread's node.
> > + - ktask_run_numa to run threads on the node(s) specified.
> > + - ktask_run_numa with nid=NUMA_NO_NODE to run threads on any node in the
> > +   system.
> > +
> > +To support these different ways of queueing work while maintaining an efficient
> > +concurrency level, we need both system-wide and per-node limits on the number
> 
> I would prefer to refer to ktask as ktask instead of "we", so
> s/we need/ktask needs/

Good idea, I'll change it.

> > +of threads.  Without per-node limits, a node might become oversubscribed
> > +despite ktask staying within the system-wide limit, and without a system-wide
> > +limit, we can't properly account for work that can run on any node.
> 
> s/we/ktask/

Ok.

> > +
> > +The system-wide limit is based on the total number of CPUs, and the per-node
> > +limit on the CPU count for each node.  A per-node work item counts against the
> > +system-wide limit.  Workqueue's max_active can't accommodate both types of
> > +limit, no matter how many workqueues are used, so ktask implements its own.
> > +
> > +If a per-node limit is reached, the work item is allowed to run anywhere on the
> > +machine to avoid overwhelming the node.  If the global limit is also reached,
> > +ktask won't queue additional work items until we fall below the limit again.
> 
> s/we fall/ktask falls/
> or s/we fall/it falls/

'ktask.'  Will change.

> > +
> > +These limits apply only to workqueue items--that is, helper threads beyond the
> > +one starting the task.  That way, one thread per task is always allowed to run.
> 
> 
> thanks.

Appreciate the feedback!
