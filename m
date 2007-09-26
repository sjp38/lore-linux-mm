Date: Tue, 25 Sep 2007 20:56:32 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [patch -mm 7/5] oom: filter tasklist dump by mem_cgroup
Message-Id: <20070925205632.47795637.pj@sgi.com>
In-Reply-To: <alpine.DEB.0.9999.0709251819400.19627@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709250035570.11015@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709250037030.11015@chino.kir.corp.google.com>
	<6599ad830709251100n352028beraddaf2ac33ea8f6c@mail.gmail.com>
	<20070925181442.aeb7b205.pj@sgi.com>
	<alpine.DEB.0.9999.0709251819400.19627@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: menage@google.com, akpm@linux-foundation.org, clameter@sgi.com, balbir@linux.vnet.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

pj wrote:
> current task.  But what about configurations using overlapping cpusets
> but not CONSTRAINT_CPUSET?

David replied:
> CONSTRAINT_CPUSET isn't as simple as just killing current anymore in -mm.  
> For that behavior, you need
> 
> 	echo 1 > /proc/sys/vm/oom_kill_allocating_task

True.

... but what about configs with overlappnig cpusets that don't set
oom_kill_allocating_tasks ?

To connect back this back to the original point:

On 9/25/07, David Rientjes <rientjes@google.com> wrote:
> If an OOM was triggered as a result a cgroup's memory controller, the
> tasklist shall be filtered to exclude tasks that are not a member of the
> same group.

I would think that excluding tasks not in the same cpuset (if that's what
"not a member of the same group" would mean here) wouldn't be the right
thing to do, if the cpusets had overlapping mems_allowed and if we had
not set oom_kill_allocating_task.

... or am I still exposing my ignorance ??

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
