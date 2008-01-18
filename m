Date: Fri, 18 Jan 2008 10:56:41 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 5/5] x86: Add debug of invalid per_cpu map accesses
In-Reply-To: <200801181933.05662.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0801181055320.30775@schroedinger.engr.sgi.com>
References: <20080118183011.354965000@sgi.com> <20080118183012.050317000@sgi.com>
 <200801181933.05662.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: travis@sgi.com, Andrew Morton <akpm@linux-foundation.org>, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 18 Jan 2008, Andi Kleen wrote:

> On Friday 18 January 2008 19:30:16 travis@sgi.com wrote:
> > Provide a means to trap usages of per_cpu map variables before
> > they are setup.  Define CONFIG_DEBUG_PER_CPU_MAPS to activate.
> 
> Are you sure that debug option is generally useful enough
> to merge? It seems very specific to your patchkit, but I'm not
> sure it would be worth carrying forever in the kernel.
> 
> Better would be probably to just unmap those areas anyways.

Its generally useful also for the cpu_alloc changes that may lead 
to the moving around of early initialization code for consolidation of 
code between i386 and x86_64 once Mike's initial patchset is in.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
