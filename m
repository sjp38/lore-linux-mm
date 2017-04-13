Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id DBA216B039F
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 07:07:00 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v52so5944007wrb.14
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 04:07:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 3si10874682wrs.168.2017.04.13.04.06.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Apr 2017 04:06:59 -0700 (PDT)
Subject: Re: [PATCH tip/core/rcu 01/13] mm: Rename SLAB_DESTROY_BY_RCU to
 SLAB_TYPESAFE_BY_RCU
References: <20170412165441.GA17149@linux.vnet.ibm.com>
 <1492016149-18834-1-git-send-email-paulmck@linux.vnet.ibm.com>
 <20170413091248.xnctlppstkrm6eq5@hirez.programming.kicks-ass.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <50d59b9c-fa8e-1992-2613-e84774ec5428@suse.cz>
Date: Thu, 13 Apr 2017 13:06:56 +0200
MIME-Version: 1.0
In-Reply-To: <20170413091248.xnctlppstkrm6eq5@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, mingo@kernel.org, jiangshanlai@gmail.com, dipankar@in.ibm.com, akpm@linux-foundation.org, mathieu.desnoyers@efficios.com, josh@joshtriplett.org, tglx@linutronix.de, rostedt@goodmis.org, dhowells@redhat.com, edumazet@google.com, fweisbec@gmail.com, oleg@redhat.com, bobby.prani@gmail.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

On 04/13/2017 11:12 AM, Peter Zijlstra wrote:
> On Wed, Apr 12, 2017 at 09:55:37AM -0700, Paul E. McKenney wrote:
>> A group of Linux kernel hackers reported chasing a bug that resulted
>> from their assumption that SLAB_DESTROY_BY_RCU provided an existence
>> guarantee, that is, that no block from such a slab would be reallocated
>> during an RCU read-side critical section.  Of course, that is not the
>> case.  Instead, SLAB_DESTROY_BY_RCU only prevents freeing of an entire
>> slab of blocks.
> 
> And that while we wrote a huge honking comment right along with it...
> 
>> [ paulmck: Add "tombstone" comments as requested by Eric Dumazet. ]
> 
> I cannot find any occurrence of "tomb" or "TOMB" in the actual patch,
> confused?

It's the comments such as:

+ * Note that SLAB_TYPESAFE_BY_RCU was originally named SLAB_DESTROY_BY_RCU.

so that people who remember the old name can git grep its fate.

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
