Date: Wed, 26 Nov 2003 14:01:22 -0500 (EST)
From: Mark Hahn <hahn@physics.mcmaster.ca>
Subject: Re: looking for explanations on linux memory management
In-Reply-To: <200311261830.02711.mickael.bailly@telintrans.fr>
Message-ID: <Pine.LNX.4.44.0311261351220.18209-100000@coffee.psychology.mcmaster.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mickael Bailly <mickael.bailly@telintrans.fr>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 1/ Hardware
> We are working on SMP 2.8GHz Pentium Xeon Hyperthread

only relevant in the sense that there are some artifacts of 32b-ness
(highmem, etc).

> We have between 2 and 2.5 gigas of RAM.

what does /proc/meminfo look like?

> 2/ Kernel
> We are using RedHat kernel 2.4.20-20.7 (last kernel upgrade for RedHat 7.3)

you should seriously consider running a modern kernel.org kernel.
RH doesn't have all that much in the way of special magic that they put
in their kernels, and you can make one yourself that's at least as good.

> Memory usage: 
> In the attached graph you can see last month memory usage for this host.

it's remarkable that you have so much wasted memory!

> 1/ can you explain me what happened in week 47 so cached memory don't get down 
> anymore ? Nothing really changed in this week on the server.

I'm guessing someone did a "find /" or similar, which caused lots of 
dcache/icache entries to be created.  of course, it could also be normal
cached file pages, stale SHM segments (run ipcs -a), or maybe even 
a big-VM proces that's gotten into some limbo state...

> 2/ how can I know when my server needs more RAM/SWAP, if free memory is always 
> about 0

free memory is WASTED memory - you might as well have not bought it.
you know you need more memory when you see swapin traffic (NOT swapouts,
which are normal and in fact good).  swapins are a sign that the kernel
has either chosen the wrong pages to swap out, or is needing to swap out
so much that hot pages are getting swapped, or that you simply have a 
working set that's larger than physical memory.

> 3/ can you tell me where to find PER PROCESS memory usage (/proc/[process 
> id]/stat ? /proc/[process id]/statm ? ) 

why not just run top or ps?  they both reformat info from /proc/<pid>
to make it easier to read.

regards, mark hahn.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
