Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EEFEA2806D9
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 17:30:22 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id h188so3709635wma.4
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 14:30:22 -0700 (PDT)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id w22si37889765wra.281.2017.04.13.14.30.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 14:30:21 -0700 (PDT)
Received: by mail-wm0-x22c.google.com with SMTP id o81so120095543wmb.1
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 14:30:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170413161709.ej3qxuqitykhqtyf@hirez.programming.kicks-ass.net>
References: <20170412165441.GA17149@linux.vnet.ibm.com> <1492016149-18834-1-git-send-email-paulmck@linux.vnet.ibm.com>
 <20170413091248.xnctlppstkrm6eq5@hirez.programming.kicks-ass.net>
 <50d59b9c-fa8e-1992-2613-e84774ec5428@suse.cz> <20170413161709.ej3qxuqitykhqtyf@hirez.programming.kicks-ass.net>
From: Eric Dumazet <edumazet@google.com>
Date: Thu, 13 Apr 2017 14:30:19 -0700
Message-ID: <CANn89iLAG9COnimUgqKFipX1VOuXdVFS-jJ8yoVDHSCNu7f+6w@mail.gmail.com>
Subject: Re: [PATCH tip/core/rcu 01/13] mm: Rename SLAB_DESTROY_BY_RCU to SLAB_TYPESAFE_BY_RCU
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, jiangshanlai@gmail.com, dipankar@in.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, oleg@redhat.com, pranith kumar <bobby.prani@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm <linux-mm@kvack.org>

On Thu, Apr 13, 2017 at 9:17 AM, Peter Zijlstra <peterz@infradead.org> wrote:

> git log -S SLAB_DESTROY_BY_RCU

Maybe, but "git log -S" is damn slow at least here.

While "git grep" is _very_ fast

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
