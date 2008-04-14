Date: Mon, 14 Apr 2008 10:32:31 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 8/15] Mempolicy: Rework mempolicy Reference Counting
 [yet again]
Message-Id: <20080414103231.60cf6005.randy.dunlap@oracle.com>
In-Reply-To: <20080404150034.5442.92020.sendpatchset@localhost>
References: <20080404145944.5442.2684.sendpatchset@localhost>
	<20080404150034.5442.92020.sendpatchset@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-numa@vger.kernel.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 04 Apr 2008 11:00:34 -0400 Lee Schermerhorn wrote:

> PATCH 08/15 Mem Policy:  rework mempolicy reference counting [yet again]
> 
> Against:  2.6.25-rc8-mm1
> 
>  Documentation/vm/numa_memory_policy.txt |   68 ++++++++++++++
> 
> Index: linux-2.6.25-rc8-mm1/Documentation/vm/numa_memory_policy.txt
> ===================================================================
> --- linux-2.6.25-rc8-mm1.orig/Documentation/vm/numa_memory_policy.txt	2008-04-02 17:47:15.000000000 -0400
> +++ linux-2.6.25-rc8-mm1/Documentation/vm/numa_memory_policy.txt	2008-04-02 17:47:26.000000000 -0400
> @@ -311,6 +311,74 @@ Components of Memory Policies
>  	    MPOL_PREFERRED policies that were created with an empty nodemask
>  	    (local allocation).

...

> +   Because of this extra reference counting, and because we must lookup
> +   shared policies in a tree structure under spinlock, shared policies are
> +   more expensive to use in the page allocation path.  This is expecially

                                                                  especially

> +   true for shared policies on shared memory regions shared by tasks running
> +   on different NUMA nodes.  This extra overhead can be avoided by always
> +   falling back to task or system default policy for shared memory regions,
> +   or by prefaulting the entire shared memory region into memory and locking
> +   it down.  However, this might not be appropriate for all applications.
> +
>  MEMORY POLICY APIs
>  
>  Linux supports 3 system calls for controlling memory policy.  These APIS


---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
