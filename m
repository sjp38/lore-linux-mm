From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 30/31] x86, pkeys: create an x86 arch_calc_vm_prot_bits()
 for VMA flags
Date: Fri, 8 Jan 2016 20:40:31 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1601082040190.3575@nanos>
References: <20160107000104.1A105322@viggo.jf.intel.com> <20160107000146.EB87C6BA@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160107000146.EB87C6BA@viggo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com
List-Id: linux-mm.kvack.org

On Wed, 6 Jan 2016, Dave Hansen wrote:

> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> calc_vm_prot_bits() takes PROT_{READ,WRITE,EXECUTE} bits and
> turns them in to the vma->vm_flags/VM_* bits.  We need to do a
> similar thing for protection keys.
> 
> We take a protection key (4 bits) and encode it in to the 4
> VM_PKEY_* bits.
> 
> Note: this code is not new.  It was simply a part of the
> mprotect_pkey() patch in the past.  I broke it out for use
> in the execute-only support.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
