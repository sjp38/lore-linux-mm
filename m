Date: Sun, 19 Aug 2007 19:34:31 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: cpusets vs. mempolicy and how to get interleaving
Message-Id: <20070819193431.dce5d4cf.pj@sgi.com>
In-Reply-To: <46C8E604.8040101@google.com>
References: <46C63BDE.20602@google.com>
	<46C63D5D.3020107@google.com>
	<alpine.DEB.0.99.0708190304510.7613@chino.kir.corp.google.com>
	<46C8E604.8040101@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: rientjes@google.com, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ethan wrote:
> 	And what happens when the weight then goes back up? e.g. at first the 
> mems_allowed specifies nodes 0 and 1, and the user sets a 
> MPOL_INTERLEAVE policy across nodes 0 and 1. At some point the "cpuset 
> manager" shrinks the number of nodes to just node 0, then later it adds 
> back node 1. What nodes are in my MPOL_INTERLEAVE policy?
> 
> 	As I read the code, I'll only have one node in the mempolicy. If that's 
> true, this doesn't do what I want.

I read the code the same way.

Sounds to me like you want a new and different MPOL_* mempolicy, that
interleaves over whatever nodes are available (allowed) to the task.

The existing MPOL_INTERLEAVE mempolicy interleaves over some specified
nodemask, so we do the best we can to remap that set when it changes.

You want a mempolicy that interleaves over all available nodes, not over
some specified subset of them.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
