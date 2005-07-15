Date: Fri, 15 Jul 2005 14:55:45 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [NUMA] Display and modify the memory policy of a process through
 /proc/<pid>/numa_policy
In-Reply-To: <20050715214700.GJ15783@wotan.suse.de>
Message-ID: <Pine.LNX.4.62.0507151450570.11656@schroedinger.engr.sgi.com>
References: <200507150452.j6F4q9g10274@unix-os.sc.intel.com>
 <Pine.LNX.4.62.0507142152400.2139@schroedinger.engr.sgi.com>
 <20050714230501.4a9df11e.pj@sgi.com> <Pine.LNX.4.62.0507150901500.8556@schroedinger.engr.sgi.com>
 <20050715140437.7399921f.pj@sgi.com> <20050715211210.GI15783@wotan.suse.de>
 <Pine.LNX.4.62.0507151413360.11563@schroedinger.engr.sgi.com>
 <20050715214700.GJ15783@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Paul Jackson <pj@sgi.com>, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Jul 2005, Andi Kleen wrote:

> So for what does that batch monstrosity need to know 
> about the VMAs? 

It needs to know where the memory of a process is. Thus 
/proc/<pid>/numa_maps.

> I don't believe any admin will mess with virtual addresses.

No but they will mess with vma's which are only identifiable by the 
starting virtual address.
 
> But for "uncooperative" programs working on bigger objects
> like threads/files/shm areas/processes makes much more sense. And gives
> much cleaner interfaces too.

Look at the existing patches and you see a huge complexity and heuristics 
because the kernel guesses which vma's to migrate. If the vma are 
exposed to the batch scheduler / admin then things become much easier to 
implement and the batch scheduler / admin has finer grained control.

> Now I can see some people being interested in more fine grained
> policy, but the only sane way to do that is to change the source
> code and use libnuma.

Can libnuma change the memory policy and move pages of existing processes?
 
> Basically to mess with finegrained virtual addresses you need code access,
> and when you have that you can as well do it well and add 
> libnuma and recompile.

libnuma is pretty heavy and AFAIK does not have the functionality that is 
required here.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
