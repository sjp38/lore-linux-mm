Date: Tue, 25 Sep 2007 21:37:57 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [patch -mm 7/5] oom: filter tasklist dump by mem_cgroup
Message-Id: <20070925213757.af33ef01.pj@sgi.com>
In-Reply-To: <alpine.DEB.0.9999.0709252104180.30932@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709250035570.11015@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709250037030.11015@chino.kir.corp.google.com>
	<6599ad830709251100n352028beraddaf2ac33ea8f6c@mail.gmail.com>
	<20070925181442.aeb7b205.pj@sgi.com>
	<alpine.DEB.0.9999.0709251819400.19627@chino.kir.corp.google.com>
	<20070925205632.47795637.pj@sgi.com>
	<alpine.DEB.0.9999.0709252104180.30932@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: menage@google.com, akpm@linux-foundation.org, clameter@sgi.com, balbir@linux.vnet.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> The OOM killer in -mm no longer checks cpuset_excl_nodes_overlap() to 
> select an overlapping task and, in fact, that function has been removed 
> entirely from kernel/cpuset.c.
> 
> If oom_kill_allocating_tasks is zero (which it is by default), the 
> tasklist is scanned and each task is checked for intersection with 
> current's mems_allowed (task->mems_allowed, not dereferencing 
> task->cpuset).  If it doesn't intersect, its "badness" score is divided by 
> eight.

Yes - I recall seeing that change go by recently.  Seemed good to me.


> Yes, absolutely.
> 
> I think Paul Menage is talking about filtering tasks that are not a member 
> of the same cpuset because we're more familiar with mem_exclusive cpusets.  
> So I think his suggestion was initially to filter based on overlapping 
> mems_allowed instead, which makes sense.
> 
> 	void dump_tasks(const struct mem_cgroup *mem)

As Paul M realized in his reply shortly ago, I missed the simple and
essential detail that we were discussing the dump routine.

It makes more sense now - thanks.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
