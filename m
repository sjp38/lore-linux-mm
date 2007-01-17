From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC 5/8] Make writeout during reclaim cpuset aware
Date: Wed, 17 Jan 2007 16:59:15 +1100
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com> <200701171528.16854.ak@suse.de> <20070116203622.7f1b4e87.pj@sgi.com>
In-Reply-To: <20070116203622.7f1b4e87.pj@sgi.com>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200701171659.16290.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: clameter@sgi.com, akpm@osdl.org, menage@google.com, linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

On Wednesday 17 January 2007 15:36, Paul Jackson wrote:
> > With a per node dirty limit ...
>
> What would this mean?
>
> Lets say we have a simple machine with 4 nodes, cpusets disabled.

There can be always NUMA policy without cpusets for once.

> Lets say all tasks are allowed to use all nodes, no set_mempolicy
> either.

Ok.

> If a task happens to fill up 80% of one node with dirty pages, but
> we have no dirty pages yet on other nodes, and we have a dirty ratio
> of 40%, then do we throttle that task's writes?

Yes we should actually. Every node should be able to supply
memory (unless extreme circumstances like mlock) and that much dirty 
memory on a node will make that hard.

> I am surprised you are asking for this, Andi.  I would have thought
> that on no-cpuset systems, the system wide throttling served your
> needs fine.  

No actually people are fairly unhappy when one node is filled with 
file data and then they don't get local memory from it anymore.
I get regular complaints about that for Opteron.

Dirty limit wouldn't be a full solution, but a good step.

> If not, then I can only guess that is because NUMA 
> mempolicy constraints on allowed nodes are causing the same dirty page
> problems as cpuset constrained systems -- is that your concern?

That is another concern. I haven't checked recently, but it used
to be fairly simple to put a system to its knees by oversubscribing
a single node with a strict memory policy. Fixing that would be good.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
