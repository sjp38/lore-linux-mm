Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8F2556B0397
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 04:45:59 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id v34so32463070iov.22
        for <linux-mm@kvack.org>; Fri, 14 Apr 2017 01:45:59 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id u128si1869073ioe.3.2017.04.14.01.45.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Apr 2017 01:45:58 -0700 (PDT)
Date: Fri, 14 Apr 2017 10:45:44 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH tip/core/rcu 01/13] mm: Rename SLAB_DESTROY_BY_RCU to
 SLAB_TYPESAFE_BY_RCU
Message-ID: <20170414084544.wgubp4ikqmohgn67@hirez.programming.kicks-ass.net>
References: <20170412165441.GA17149@linux.vnet.ibm.com>
 <1492016149-18834-1-git-send-email-paulmck@linux.vnet.ibm.com>
 <20170413091248.xnctlppstkrm6eq5@hirez.programming.kicks-ass.net>
 <50d59b9c-fa8e-1992-2613-e84774ec5428@suse.cz>
 <20170413161709.ej3qxuqitykhqtyf@hirez.programming.kicks-ass.net>
 <CANn89iLAG9COnimUgqKFipX1VOuXdVFS-jJ8yoVDHSCNu7f+6w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANn89iLAG9COnimUgqKFipX1VOuXdVFS-jJ8yoVDHSCNu7f+6w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <edumazet@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, jiangshanlai@gmail.com, dipankar@in.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, oleg@redhat.com, pranith kumar <bobby.prani@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm <linux-mm@kvack.org>

On Thu, Apr 13, 2017 at 02:30:19PM -0700, Eric Dumazet wrote:
> On Thu, Apr 13, 2017 at 9:17 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > git log -S SLAB_DESTROY_BY_RCU
> 
> Maybe, but "git log -S" is damn slow at least here.
> 
> While "git grep" is _very_ fast

All true. But in general we don't leave endless markers around like
this.

For instance:

  /* the function formerly known as smp_mb__before_clear_bit() */

is not part of the kernel tree. People that used that thing out of tree
get to deal with it in whatever way they see fit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
