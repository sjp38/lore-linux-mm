Date: Thu, 26 Jan 2006 16:57:06 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [patch 3/9] mempool - Make mempools NUMA aware
In-Reply-To: <43D96D08.6050200@us.ibm.com>
Message-ID: <Pine.LNX.4.62.0601261655120.19293@schroedinger.engr.sgi.com>
References: <20060125161321.647368000@localhost.localdomain>
 <1138233093.27293.1.camel@localhost.localdomain>
 <Pine.LNX.4.62.0601260953200.15128@schroedinger.engr.sgi.com>
 <43D953C4.5020205@us.ibm.com> <Pine.LNX.4.62.0601261511520.18716@schroedinger.engr.sgi.com>
 <43D95A2E.4020002@us.ibm.com> <Pine.LNX.4.62.0601261525570.18810@schroedinger.engr.sgi.com>
 <43D96633.4080900@us.ibm.com> <Pine.LNX.4.62.0601261619030.19029@schroedinger.engr.sgi.com>
 <43D96A93.9000600@us.ibm.com> <Pine.LNX.4.62.0601261638210.19078@schroedinger.engr.sgi.com>
 <43D96D08.6050200@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org, pj@sgi.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Thu, 26 Jan 2006, Matthew Dobson wrote:

> > We need this for other issues as well. f.e. to establish memory allocation 
> > policies for the page cache, tmpfs and various other needs. Look at 
> > mempolicy.h which defines a subset of what we need. Currently there is no 
> > way to specify a policy when invoking the page allocator or slab 
> > allocator. The policy is implicily fetched from the current task structure 
> > which is not optimal.
> 
> I agree that the current, task-based policies are subobtimal.  Having to
> allocate and fill in even a small structure for each allocation is going to
> be a tough sell, though.  I suppose most allocations could get by with a
> small handfull of static generic "policy structures"...  This seems like it
> will turn into a signifcant rework of all the kernel's allocation routines,
> no small task.  Certainly not something that I'd even start without
> response from some other major players in the VM area...  Anyone?

No you would have a set of policies and only pass a pointer to the 
policies to the allocator. I.e. have one emergency policy allocated 
somewhere in the IP stack and then pass that to the allocator.

I guess that Andi Kleen and Paul Jackson would likely be interested in 
such an endeavor.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
