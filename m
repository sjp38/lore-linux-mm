Subject: Re: looking for explanations on linux memory management
From: Rob Love <rml@tech9.net>
In-Reply-To: <200311261830.02711.mickael.bailly@telintrans.fr>
References: <200311261830.02711.mickael.bailly@telintrans.fr>
Content-Type: text/plain
Message-Id: <1069870409.10070.8.camel@localhost>
Mime-Version: 1.0
Date: Wed, 26 Nov 2003 13:13:29 -0500
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mickael Bailly <mickael.bailly@telintrans.fr>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2003-11-26 at 12:30, Mickael Bailly wrote:

> 1/ can you explain me what happened in week 47 so cached memory don't get down 
> anymore ? Nothing really changed in this week on the server.

Somehow you started generating more page I/O and thus more page cache. 
What actually strikes me as odd is the fact it was so low despite having
free memory.

But it could be a low vs. high memory thing, since you have 2GB of RAM. 
The full output from /proc/meminfo and /proc/slabinfo might be more
useful than this graph.

> 2/ how can I know when my server needs more RAM/SWAP, if free memory is always 
> about 0

When swap is abnormally large (or, even better, when swapped activity is
high.  See vmstat(8)).  Free memory being zero does not say much...
Linux will use most of available memory for cache, but will of course
prune that in response to page allocation.

> 3/ can you tell me where to find PER PROCESS memory usage (/proc/[process 
> id]/stat ? /proc/[process id]/statm ? ) 

/proc/pid/status has VmSize, etc.

You can also see this with ps(1) and top(1), of course.

	Rob Love


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
