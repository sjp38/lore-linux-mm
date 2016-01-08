From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 10/31] x86, pkeys: arch-specific protection bits
Date: Fri, 8 Jan 2016 20:31:18 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1601082031070.3575@nanos>
References: <20160107000104.1A105322@viggo.jf.intel.com> <20160107000119.7BB92E5B@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160107000119.7BB92E5B@viggo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com
List-Id: linux-mm.kvack.org

On Wed, 6 Jan 2016, Dave Hansen wrote:

> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Lots of things seem to do:
> 
>         vma->vm_page_prot = vm_get_page_prot(flags);
> 
> and the ptes get created right from things we pull out
> of ->vm_page_prot.  So it is very convenient if we can
> store the protection key in flags and vm_page_prot, just
> like the existing permission bits (_PAGE_RW/PRESENT).  It
> greatly reduces the amount of plumbing and arch-specific
> hacking we have to do in generic code.
> 
> This also takes the new PROT_PKEY{0,1,2,3} flags and
> turns *those* in to VM_ flags for vma->vm_flags.
> 
> The protection key values are stored in 4 places:
> 	1. "prot" argument to system calls
> 	2. vma->vm_flags, filled from the mmap "prot"
> 	3. vma->vm_page prot, filled from vma->vm_flags
> 	4. the PTE itself.
> 
> The pseudocode for these for steps are as follows:
> 
> 	mmap(PROT_PKEY*)
> 	vma->vm_flags 	  = ... | arch_calc_vm_prot_bits(mmap_prot);
> 	vma->vm_page_prot = ... | arch_vm_get_page_prot(vma->vm_flags);
> 	pte = pfn | vma->vm_page_prot
> 
> Note that this provides a new definitions for x86:
> 
> 	arch_vm_get_page_prot()
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
