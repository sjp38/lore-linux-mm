Date: Fri, 31 Mar 2006 15:48:44 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Avoid excessive time spend on concurrent slab shrinking
In-Reply-To: <20060331153235.754deb0c.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0603311541260.8948@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603311441400.8465@schroedinger.engr.sgi.com>
 <20060331150120.21fad488.akpm@osdl.org> <Pine.LNX.4.64.0603311507130.8617@schroedinger.engr.sgi.com>
 <20060331153235.754deb0c.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 31 Mar 2006, Andrew Morton wrote:

> > System sluggish in general. cscope takes 20 minutes to start etc. Dropping 
> > the caches restored performance.
> 
> OK.  What sort of system was it, and what was the workload?  FIlesystem types?

A build server. Lots of scripts running, compilers etc etc.

> It's been like that for an awful long time.  Can you think why this has
> only just now been noticed?

Testing has reached new level of thoroughness because of the new releases 
that are due soon...

> > We just noticed general sluggishness and took some stackdumps to see what 
> > the system was up to.
> 
> OK.  But was it D-state sleep (semaphore lock contention) or what?

Yes, lots of processes waiting on semaphores in 
shrink_slab->shrink_icache_memory. Need to look at this in more detail it 
seems.

I looked at the old release that worked. Seems that it did the same thing 
in terms of slab shrinking. Concurrent slab shrinking was no problem. So 
you may be right. Its something unrelated to the code in vmscan.c. Maybe 
Nick knows something about this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
