Date: Tue, 8 Aug 2006 11:16:52 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] Slab: Enforce clean node lists per zone, add policy
 support and fallback
Message-Id: <20060808111652.571f85db.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608080951240.27620@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608080951240.27620@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, penberg@cs.helsinki.fi, kiran@scalex86.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

Christoph wrote:
> Currently the allocations may be redirected via cpusets to other nodes. 

Minor picky point of terminology ... I wouldn't say that cpusets
"redirect" the allocation, but "force" or "constrain" it.  To my way
of speaking, a "redirect" would apply if the rule was "allocations
on node 6 should be satisfied on (redirected to) node 9", for
example.  A forced constraint applies if the rule is "I don't care
what you asked for buddy - you're getting node 9, period."

Separate point - I think we already have a workaround in place for
the migration case to keep cpuset constraints out of the way.  See
the overwriting of tsk->mems_allowed in the kernel/cpuset.c routine
cpuset_migrate_mm().  With Christoph's new __GFP_THISNODE, or whatever
alloc_pages_exact_node() with limited zonelist equivalent we come up
with, we don't need both that and the cpuset_migrate_mm() workaround.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
