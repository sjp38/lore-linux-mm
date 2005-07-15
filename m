Date: Sat, 16 Jul 2005 00:07:54 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [NUMA] Display and modify the memory policy of a process through /proc/<pid>/numa_policy
Message-ID: <20050715220753.GK15783@wotan.suse.de>
References: <200507150452.j6F4q9g10274@unix-os.sc.intel.com> <Pine.LNX.4.62.0507142152400.2139@schroedinger.engr.sgi.com> <20050714230501.4a9df11e.pj@sgi.com> <Pine.LNX.4.62.0507150901500.8556@schroedinger.engr.sgi.com> <20050715140437.7399921f.pj@sgi.com> <20050715211210.GI15783@wotan.suse.de> <Pine.LNX.4.62.0507151413360.11563@schroedinger.engr.sgi.com> <20050715214700.GJ15783@wotan.suse.de> <Pine.LNX.4.62.0507151450570.11656@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0507151450570.11656@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 15, 2005 at 02:55:45PM -0700, Christoph Lameter wrote:
> On Fri, 15 Jul 2005, Andi Kleen wrote:
> 
> > So for what does that batch monstrosity need to know 
> > about the VMAs? 
> 
> It needs to know where the memory of a process is. Thus 

For that the counters I proposed are enough.


> /proc/<pid>/numa_maps.

All it should do is to start processes on specific nodes
(already should work) 
and perhaps later migrate processes from some set of specific
nodes to another set of specific nodes (using Ray's page
migration call) 

I don't see where a knowledge of specific VMAs is needed anywhere
in this.



> 
> > I don't believe any admin will mess with virtual addresses.
> 
> No but they will mess with vma's which are only identifiable by the 
> starting virtual address.

What for? 


>  
> > But for "uncooperative" programs working on bigger objects
> > like threads/files/shm areas/processes makes much more sense. And gives
> > much cleaner interfaces too.
> 
> Look at the existing patches and you see a huge complexity and heuristics 
> because the kernel guesses which vma's to migrate. If the vma are 

They kernel doesn't guess, it knows exactly.

> exposed to the batch scheduler / admin then things become much easier to 
> implement and the batch scheduler / admin has finer grained control.

So you want to tear up the interface Ray came up with and we discussed
and agreed on and replace it with something completely different and something
that uses this ugly /proc file? I don't think that's a good idea.



> 
> > Now I can see some people being interested in more fine grained
> > policy, but the only sane way to do that is to change the source
> > code and use libnuma.
> 
> Can libnuma change the memory policy and move pages of existing processes?

If someone hooks it into mbind() sure. But most likely 
such changes would be handled by migrate_pages()



>  
> > Basically to mess with finegrained virtual addresses you need code access,
> > and when you have that you can as well do it well and add 
> > libnuma and recompile.
> 
> libnuma is pretty heavy and AFAIK does not have the functionality that is 

Heavy??? You're not serious, right? 

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
