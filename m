Date: Tue, 8 Aug 2006 12:20:29 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] Slab: Enforce clean node lists per zone, add policy
 support and fallback
Message-Id: <20060808122029.01e91c2a.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608081129410.28922@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608080951240.27620@schroedinger.engr.sgi.com>
	<20060808111652.571f85db.pj@sgi.com>
	<Pine.LNX.4.64.0608081129410.28922@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, penberg@cs.helsinki.fi, kiran@scalex86.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

> You are confusing two issues in the migration code. The case of 
> sys_migrate_page was fixed by you by changing the cpuset context. Thats 
> fine and we do not need __GFP_THISNODE there because the page are to be 
> allocated in conformity with a cpuset context of a process.

Ah - ok.  Yes, I was looking for the constraints of the new, destination
cpuset, rather than the tasks curent cpuset.  And I was not looking for
exact __GFP_THISNODE placement.  So I was talking about a separate case.

Minor confusion with a confusion ... I don't know why you mentioned
'sys_migrate_page' -- that wasn't what I was referring to.  I was
referring to my cpuset_migrate_mm() hack, which is involved in the two
cases:
    1) a task is put in a cpuset that is marked 'memory_migrate', or
    2) a task is in a cpuset marked 'memory_migrate' and that cpusets
       'mems' are changed.

In any case ... nevermind ;).

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
