Date: Tue, 17 Apr 2007 14:27:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: sysctl_panic_on_oom broken
In-Reply-To: <46250EB1.9010707@redhat.com>
Message-ID: <Pine.LNX.4.64.0704171426010.7409@schroedinger.engr.sgi.com>
References: <46250EB1.9010707@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Larry Woodman <lwoodman@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Apr 2007, Larry Woodman wrote:

> out_of_memory() does not panic when sysctl_panic_on_oom is set
> if constrained_alloc() does not return CONSTRAINT_NONE.  Instead,
> out_of_memory() kills the current process whenever constrained_alloc()
> returns either CONSTRAINT_MEMORY_POLICY or CONSTRAINT_CPUSET.
> This patch fixes this problem:

The patch recreates the problem that the system may OOM 
although lots of memory is still free. Constrained allocation means that 
the allocation was only to a portion of system memory. The rest may be 
free. No reason to oom.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
