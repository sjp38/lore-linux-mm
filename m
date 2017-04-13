Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 742CD6B0390
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 12:00:36 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id h72so52546136iod.0
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 09:00:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y188si9328479itg.69.2017.04.13.09.00.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 09:00:35 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3DFxDt6052658
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 12:00:34 -0400
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29t7g1ffk1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 12:00:34 -0400
Received: from localhost
	by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 13 Apr 2017 12:00:32 -0400
Date: Thu, 13 Apr 2017 09:00:27 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH tip/core/rcu 01/13] mm: Rename SLAB_DESTROY_BY_RCU to
 SLAB_TYPESAFE_BY_RCU
Reply-To: paulmck@linux.vnet.ibm.com
References: <20170412165441.GA17149@linux.vnet.ibm.com>
 <1492016149-18834-1-git-send-email-paulmck@linux.vnet.ibm.com>
 <20170413091248.xnctlppstkrm6eq5@hirez.programming.kicks-ass.net>
 <50d59b9c-fa8e-1992-2613-e84774ec5428@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50d59b9c-fa8e-1992-2613-e84774ec5428@suse.cz>
Message-Id: <20170413160027.GX3956@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, mingo@kernel.org, jiangshanlai@gmail.com, dipankar@in.ibm.com, akpm@linux-foundation.org, mathieu.desnoyers@efficios.com, josh@joshtriplett.org, tglx@linutronix.de, rostedt@goodmis.org, dhowells@redhat.com, edumazet@google.com, fweisbec@gmail.com, oleg@redhat.com, bobby.prani@gmail.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

On Thu, Apr 13, 2017 at 01:06:56PM +0200, Vlastimil Babka wrote:
> On 04/13/2017 11:12 AM, Peter Zijlstra wrote:
> > On Wed, Apr 12, 2017 at 09:55:37AM -0700, Paul E. McKenney wrote:
> >> A group of Linux kernel hackers reported chasing a bug that resulted
> >> from their assumption that SLAB_DESTROY_BY_RCU provided an existence
> >> guarantee, that is, that no block from such a slab would be reallocated
> >> during an RCU read-side critical section.  Of course, that is not the
> >> case.  Instead, SLAB_DESTROY_BY_RCU only prevents freeing of an entire
> >> slab of blocks.
> > 
> > And that while we wrote a huge honking comment right along with it...
> > 
> >> [ paulmck: Add "tombstone" comments as requested by Eric Dumazet. ]
> > 
> > I cannot find any occurrence of "tomb" or "TOMB" in the actual patch,
> > confused?
> 
> It's the comments such as:
> 
> + * Note that SLAB_TYPESAFE_BY_RCU was originally named SLAB_DESTROY_BY_RCU.
> 
> so that people who remember the old name can git grep its fate.

Exactly!

But I must confess that "tombstone" was an excessively obscure word
choice, even for native English speakers.  I have reworded as follows:

[ paulmck: Add comments mentioning the old name, as requested by Eric
  Dumazet, in order to help people familiar with the old name find
  the new one. ]

Does that help?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
