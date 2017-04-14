Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DAC226B0038
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 09:40:00 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h87so2511676pfh.2
        for <linux-mm@kvack.org>; Fri, 14 Apr 2017 06:40:00 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s70si2046334pfg.202.2017.04.14.06.39.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Apr 2017 06:39:59 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3EDcu3A080848
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 09:39:59 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29tp4bamkj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 09:39:58 -0400
Received: from localhost
	by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 14 Apr 2017 09:39:57 -0400
Date: Fri, 14 Apr 2017 06:39:51 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH tip/core/rcu 01/13] mm: Rename SLAB_DESTROY_BY_RCU to
 SLAB_TYPESAFE_BY_RCU
Reply-To: paulmck@linux.vnet.ibm.com
References: <20170412165441.GA17149@linux.vnet.ibm.com>
 <1492016149-18834-1-git-send-email-paulmck@linux.vnet.ibm.com>
 <20170413091248.xnctlppstkrm6eq5@hirez.programming.kicks-ass.net>
 <50d59b9c-fa8e-1992-2613-e84774ec5428@suse.cz>
 <20170413161709.ej3qxuqitykhqtyf@hirez.programming.kicks-ass.net>
 <CANn89iLAG9COnimUgqKFipX1VOuXdVFS-jJ8yoVDHSCNu7f+6w@mail.gmail.com>
 <20170414084544.wgubp4ikqmohgn67@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170414084544.wgubp4ikqmohgn67@hirez.programming.kicks-ass.net>
Message-Id: <20170414133951.GY3956@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Eric Dumazet <edumazet@google.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, jiangshanlai@gmail.com, dipankar@in.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, oleg@redhat.com, pranith kumar <bobby.prani@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm <linux-mm@kvack.org>

On Fri, Apr 14, 2017 at 10:45:44AM +0200, Peter Zijlstra wrote:
> On Thu, Apr 13, 2017 at 02:30:19PM -0700, Eric Dumazet wrote:
> > On Thu, Apr 13, 2017 at 9:17 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> > 
> > > git log -S SLAB_DESTROY_BY_RCU
> > 
> > Maybe, but "git log -S" is damn slow at least here.
> > 
> > While "git grep" is _very_ fast
> 
> All true. But in general we don't leave endless markers around like
> this.
> 
> For instance:
> 
>   /* the function formerly known as smp_mb__before_clear_bit() */
> 
> is not part of the kernel tree. People that used that thing out of tree
> get to deal with it in whatever way they see fit.

Sometimes we don't provide markers and sometimes we do:

$ git grep synchronize_kernel
Documentation/RCU/RTFP.txt:,Title="API change: synchronize_kernel() deprecated"
Documentation/RCU/RTFP.txt:     Jon Corbet describes deprecation of synchronize_kernel()
kernel/rcu/tree.c: * synchronize_kernel() API.  In contrast, synchronize_rcu() only

Given that it has been more than a decade, I could easily see my way to
removing this synchronize_kernel() tombstone in kernel/rcu/tree.c if
people are annoyed by it.  But thus far, no one has complained.

So how long should we wait to remove the SLAB_DESTROY_BY_RCU tombstone?
I can easily add an event to my calendar to remind me to remove it.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
