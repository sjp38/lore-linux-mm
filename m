Date: Tue, 25 Sep 2007 18:14:42 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [patch -mm 7/5] oom: filter tasklist dump by mem_cgroup
Message-Id: <20070925181442.aeb7b205.pj@sgi.com>
In-Reply-To: <6599ad830709251100n352028beraddaf2ac33ea8f6c@mail.gmail.com>
References: <alpine.DEB.0.9999.0709250035570.11015@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709250037030.11015@chino.kir.corp.google.com>
	<6599ad830709251100n352028beraddaf2ac33ea8f6c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: rientjes@google.com, akpm@linux-foundation.org, clameter@sgi.com, balbir@linux.vnet.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/25/07, David Rientjes <rientjes@google.com> wrote:
> If an OOM was triggered as a result a cgroup's memory controller, the
> tasklist shall be filtered to exclude tasks that are not a member of the
> same group.

Paul M replied:
> It would be nice to be able to do the same thing for cpuset
> membership, in the event that cpusets are active and the memory
> controller is not.

But cpusets can overlap.  For those configurations where we use
CONSTRAINT_CPUSET, I guess this doesn't matter, as we just shoot the
current task.  But what about configurations using overlapping cpusets
but not CONSTRAINT_CPUSET?

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
