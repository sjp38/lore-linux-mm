Date: Tue, 25 Sep 2007 18:20:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 7/5] oom: filter tasklist dump by mem_cgroup
In-Reply-To: <20070925181442.aeb7b205.pj@sgi.com>
Message-ID: <alpine.DEB.0.9999.0709251819400.19627@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709250035570.11015@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709250037030.11015@chino.kir.corp.google.com> <6599ad830709251100n352028beraddaf2ac33ea8f6c@mail.gmail.com> <20070925181442.aeb7b205.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Paul Menage <menage@google.com>, akpm@linux-foundation.org, clameter@sgi.com, balbir@linux.vnet.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Sep 2007, Paul Jackson wrote:

> > It would be nice to be able to do the same thing for cpuset
> > membership, in the event that cpusets are active and the memory
> > controller is not.
> 
> But cpusets can overlap.  For those configurations where we use
> CONSTRAINT_CPUSET, I guess this doesn't matter, as we just shoot the
> current task.  But what about configurations using overlapping cpusets
> but not CONSTRAINT_CPUSET?
> 

CONSTRAINT_CPUSET isn't as simple as just killing current anymore in -mm.  
For that behavior, you need

	echo 1 > /proc/sys/vm/oom_kill_allocating_task

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
