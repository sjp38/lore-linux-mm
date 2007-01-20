Date: Fri, 19 Jan 2007 21:15:32 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 1/5] Add a map to to track dirty pages per node
Message-Id: <20070119211532.d47793b1.pj@sgi.com>
In-Reply-To: <20070120031012.17491.72105.sendpatchset@schroedinger.engr.sgi.com>
References: <20070120031007.17491.33355.sendpatchset@schroedinger.engr.sgi.com>
	<20070120031012.17491.72105.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, menage@google.com, a.p.zijlstra@chello.nl, nickpiggin@yahoo.com.au, linux-mm@kvack.org, dgc@sgi.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Christoph wrote:
> + * Called without the tree_lock! So we may on rare occasions (when we race with
> + * cpuset_clear_dirty_nodes()) follow the dirty_node pointer to random data.

Random is ok, on rate occassion, as you note.

But is there any chance you could follow it to a non-existent memory location
and oops?  These long nodemasks are kmalloc/kfree'd, and I thought that once
kfree'd, there was no guarantee that the stale address would even point to
a mapped page of RAM.  This situation reminds me of the one that led to adding
some RCU dependent code to kernel/cpuset.c.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
