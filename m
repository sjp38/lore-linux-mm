Date: Tue, 25 Sep 2007 11:49:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 6/5] memcontrol: move mm_cgroup to header file
In-Reply-To: <46F942D6.3020103@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.0.9999.0709251145270.19001@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709250035570.11015@chino.kir.corp.google.com> <46F942D6.3020103@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Sep 2007, Balbir Singh wrote:

> > Inline functions must preceed their use, so mm_cgroup() should be defined
> > in linux/memcontrol.h.
> > 
> > include/linux/memcontrol.h:48: warning: 'mm_cgroup' declared inline after
> > 	being called
> > include/linux/memcontrol.h:48: warning: previous declaration of
> > 	'mm_cgroup' was here
> > 
> > Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> Is this a new warning or have you seen this earlier. I don't see the
> warning in any of the versions upto 2.6.23-rc7-mm1. I'll check
> the compilation output again and of-course 2.6.23-rc8-mm1
> 

It was produced when I implemented the filtering for the task dump with 
respect to cgroups, that's why this fix is included in a series that 
applies to the OOM killer.

Inline functions always need to preceed their use, otherwise the compiler 
can't inline them and they become normal functions.  So the quick rule is 
that inline functions are always "static inline," which this one was not.  
Those functions are always available in only one source file or declared 
in a header (and usually included before source file code) so that you 
don't need to worry about the declaration and use ordering.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
