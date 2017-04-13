Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0ECB96B0390
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 05:12:57 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g23so1161670pfj.10
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 02:12:57 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h5si3836559plk.84.2017.04.13.02.12.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 02:12:56 -0700 (PDT)
Date: Thu, 13 Apr 2017 11:12:48 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH tip/core/rcu 01/13] mm: Rename SLAB_DESTROY_BY_RCU to
 SLAB_TYPESAFE_BY_RCU
Message-ID: <20170413091248.xnctlppstkrm6eq5@hirez.programming.kicks-ass.net>
References: <20170412165441.GA17149@linux.vnet.ibm.com>
 <1492016149-18834-1-git-send-email-paulmck@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1492016149-18834-1-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, mingo@kernel.org, jiangshanlai@gmail.com, dipankar@in.ibm.com, akpm@linux-foundation.org, mathieu.desnoyers@efficios.com, josh@joshtriplett.org, tglx@linutronix.de, rostedt@goodmis.org, dhowells@redhat.com, edumazet@google.com, fweisbec@gmail.com, oleg@redhat.com, bobby.prani@gmail.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

On Wed, Apr 12, 2017 at 09:55:37AM -0700, Paul E. McKenney wrote:
> A group of Linux kernel hackers reported chasing a bug that resulted
> from their assumption that SLAB_DESTROY_BY_RCU provided an existence
> guarantee, that is, that no block from such a slab would be reallocated
> during an RCU read-side critical section.  Of course, that is not the
> case.  Instead, SLAB_DESTROY_BY_RCU only prevents freeing of an entire
> slab of blocks.

And that while we wrote a huge honking comment right along with it...

> [ paulmck: Add "tombstone" comments as requested by Eric Dumazet. ]

I cannot find any occurrence of "tomb" or "TOMB" in the actual patch,
confused?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
