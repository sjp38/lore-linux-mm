Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6D60F6B03AB
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 20:14:30 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 68so99466751pgj.23
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 17:14:30 -0700 (PDT)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id r74si6105723pfk.148.2017.04.17.17.14.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Apr 2017 17:14:29 -0700 (PDT)
Received: by mail-pf0-x231.google.com with SMTP id 194so33168886pfv.3
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 17:14:29 -0700 (PDT)
Date: Mon, 17 Apr 2017 17:14:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 tip/core/rcu 01/11] mm: Rename SLAB_DESTROY_BY_RCU to
 SLAB_TYPESAFE_BY_RCU
In-Reply-To: <1492471738-1377-1-git-send-email-paulmck@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1704171714140.140456@chino.kir.corp.google.com>
References: <20170417232714.GA19013@linux.vnet.ibm.com> <1492471738-1377-1-git-send-email-paulmck@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, mingo@kernel.org, jiangshanlai@gmail.com, dipankar@in.ibm.com, akpm@linux-foundation.org, mathieu.desnoyers@efficios.com, josh@joshtriplett.org, tglx@linutronix.de, peterz@infradead.org, rostedt@goodmis.org, dhowells@redhat.com, edumazet@google.com, fweisbec@gmail.com, oleg@redhat.com, bobby.prani@gmail.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

On Mon, 17 Apr 2017, Paul E. McKenney wrote:

> A group of Linux kernel hackers reported chasing a bug that resulted
> from their assumption that SLAB_DESTROY_BY_RCU provided an existence
> guarantee, that is, that no block from such a slab would be reallocated
> during an RCU read-side critical section.  Of course, that is not the
> case.  Instead, SLAB_DESTROY_BY_RCU only prevents freeing of an entire
> slab of blocks.
> 
> However, there is a phrase for this, namely "type safety".  This commit
> therefore renames SLAB_DESTROY_BY_RCU to SLAB_TYPESAFE_BY_RCU in order
> to avoid future instances of this sort of confusion.
> 
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: <linux-mm@kvack.org>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> [ paulmck: Add comments mentioning the old name, as requested by Eric
>   Dumazet, in order to help people familiar with the old name find
>   the new one. ]

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
