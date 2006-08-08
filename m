Date: Tue, 8 Aug 2006 11:32:44 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Slab: Enforce clean node lists per zone, add policy support
 and fallback
In-Reply-To: <20060808111652.571f85db.pj@sgi.com>
Message-ID: <Pine.LNX.4.64.0608081129410.28922@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608080951240.27620@schroedinger.engr.sgi.com>
 <20060808111652.571f85db.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, penberg@cs.helsinki.fi, kiran@scalex86.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Tue, 8 Aug 2006, Paul Jackson wrote:

> Separate point - I think we already have a workaround in place for
> the migration case to keep cpuset constraints out of the way.  See
> the overwriting of tsk->mems_allowed in the kernel/cpuset.c routine
> cpuset_migrate_mm().  With Christoph's new __GFP_THISNODE, or whatever
> alloc_pages_exact_node() with limited zonelist equivalent we come up
> with, we don't need both that and the cpuset_migrate_mm() workaround.

You are confusing two issues in the migration code. The case of 
sys_migrate_page was fixed by you by changing the cpuset context. Thats 
fine and we do not need __GFP_THISNODE there because the page are to be 
allocated in conformity with a cpuset context of a process.

In the case of sys_move_pages we move individual pages to particular 
nodes. There we do not want to have cpuset redirection by constraints or 
mempolicy influences.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
