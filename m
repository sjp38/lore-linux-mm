Date: Sun, 3 Sep 2000 12:10:35 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Stuck at 1GB again
Message-ID: <20000903121035.B7551@redhat.com>
References: <20000902115032.A2764@top.worldcontrol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000902115032.A2764@top.worldcontrol.com>; from brian@worldcontrol.com on Sat, Sep 02, 2000 at 11:50:32AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brian Litzinger <brian@top.worldcontrol.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, Sep 02, 2000 at 11:50:32AM -0700, brian@worldcontrol.com wrote:

> The kernel is compiled with the 4GB option. (which I think is
> the 2/2GB option from 2.2.x kernels).  I believe the option is
> supposed to assign 2GB of address space to real memory, and
> 2GB to virtual memory (from a per process point of view).

No, it's much better than that in 2.4!  The 2.4 4GB option still has
the 3+1 split, and only maps the first just-under-1GB of physical
memory into the kernel's permanent VA space.  The rest of the memory
is mapped on demand.

> Without glibc 2.2 I should be able to get to 2GB of memory
> allocated via the heap.  I only need glibc 2.2 to start
> mmap'ing malloc'able pools from VM. I.E. beyond 2GB of
> malloc'ed memory.

Right.
 
> My app running with 1 GB RAM under linux 2.2, with glibc 2.2
> successfully malloc's up to 3GB and the app works fine. (though
> swapping quite a bit).
> 
> My app running with 2 GB RAM under linux 2.4.0-test7, with glibc 2.2
> dies at 1 GB of memory used.  (it also dies at 1 GB using glibc 2.1.2).

What happens at this point?  If you strace the binary, what fails?

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
