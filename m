Received: by nf-out-0910.google.com with SMTP id c10so608902nfd.6
        for <linux-mm@kvack.org>; Fri, 24 Oct 2008 15:05:48 -0700 (PDT)
Date: Sat, 25 Oct 2008 02:09:05 +0400
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: 2.6.28-rc1: EIP: slab_destroy+0x84/0x142
Message-ID: <20081024220750.GA22973@x200.localdomain>
References: <alpine.LFD.2.00.0810232028500.3287@nehalem.linux-foundation.org> <20081024185952.GA18526@x200.localdomain> <1224884318.3248.54.camel@calx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1224884318.3248.54.camel@calx>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, cl@linux-foundation.org, penberg@cs.helsinki.fi, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 24, 2008 at 04:38:38PM -0500, Matt Mackall wrote:
> On Fri, 2008-10-24 at 22:59 +0400, Alexey Dobriyan wrote:
> > Reproducible under KVM during initscripts:
> 
> Not sure what you're trying to tell us here. Are you implying that a
> fault occurred at this line?

Fault occured at slab_destroy in KVM guest kernel.

> Do you have an oops?

Two are below, it seems impossible to copy-paste from KVM window.

> > 	debug_check_no_locks_freed
> > 	free_hot_cold_page
> > 	free_hot_page
> > 	put_page
> > 	free_page_and_swap_cache
> > 	unmap_vmas
> > 	exit_mmap
> > 	mmput
> > 	flush_old_exec
> > 	vfs_read
> > 	kernel_read
> > 	load_elf_binary
> > 	search_binary_handler
> > 	load_elf_binary
> > 	load_elf_binary
> > 	search_binary_handler
> > 	do_execve
> > 	sys_execve
> > 	syscall_call
> > --------------------------------
> > 	kmem_cache_free
> > 	file_free_rcu
> > 	__rcu_process_callbacks
> > 	__do_softirq
> > 	do_softirq
> > 	irq_exit
> > 	do_IRQ
> > 	common_interrupt
> > 	kvm_leave_lazy_mmu
> > 	copy_page_range
> > 	dup_mm
> > 	copy_process
> > 	do_fork
> > 	trace_hardirqs_on
> > 	copy_to_user
> > 	trace_hardirqs_on_thunk
> > 	sys_clone
> > 	syscall_call
> > 
> > EIP: slab_destroy+0x84/0x142
> > 
> > mm/slab.c:1924

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
