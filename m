Date: Fri, 15 Jul 2005 09:06:25 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [NUMA] Display and modify the memory policy of a process through
 /proc/<pid>/numa_policy
In-Reply-To: <20050714230501.4a9df11e.pj@sgi.com>
Message-ID: <Pine.LNX.4.62.0507150901500.8556@schroedinger.engr.sgi.com>
References: <200507150452.j6F4q9g10274@unix-os.sc.intel.com>
 <Pine.LNX.4.62.0507142152400.2139@schroedinger.engr.sgi.com>
 <20050714230501.4a9df11e.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jul 2005, Paul Jackson wrote:

> Christoph wrote:
> > This is an implementation that deals with monitoring and managing running 
> > processes.
> 
> So is this patch roughly equivalent to adding a pid to the
> mbind/set_mempolicy/get_mempolicy system calls?

Yes. Almost.
 
> Not that I am advocating for or against adding doing that.  But this
> seems like alot of code, with new and exciting API details, just to
> add a pid argument, if such it be.

I think the syscall interface is plainly wrong for monitoring and managing 
a process. The /proc interface is designed to monitor processes and it 
allows the modification of process characteristics. This is the natural 
way to implement viewing of numa allocation maps, the runtime changes
to allocation strategies and finally something that migrates pages of a 
vma between nodes.

A syscall interface implies that you have to write user space programs 
with associated libraries to display and manipulate values. As 
demonstrated this is really not necessary. Implementation via /proc
is fairly simple.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
