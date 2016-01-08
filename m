From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 29/31] x86, pkeys: allow kernel to modify user pkey rights
 register
Date: Fri, 8 Jan 2016 20:40:14 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1601082039570.3575@nanos>
References: <20160107000104.1A105322@viggo.jf.intel.com> <20160107000145.96AD9FDD@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160107000145.96AD9FDD@viggo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com
List-Id: linux-mm.kvack.org

On Wed, 6 Jan 2016, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> The Protection Key Rights for User memory (PKRU) is a 32-bit
> user-accessible register.  It contains two bits for each
> protection key: one to write-disable (WD) access to memory
> covered by the key and another to access-disable (AD).
> 
> Userspace can read/write the register with the RDPKRU and WRPKRU
> instructions.  But, the register is saved and restored with the
> XSAVE family of instructions, which means we have to treat it
> like a floating point register.
> 
> The kernel needs to write to the register if it wants to
> implement execute-only memory or if it implements a system call
> to change PKRU.
> 
> To do this, we need to create a 'pkru_state' buffer, read the old
> contents in to it, modify it, and then tell the FPU code that
> there is modified data in there so it can (possibly) move the
> buffer back in to the registers.
> 
> This uses the fpu__xfeature_set_state() function that we defined
> in the previous patch.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
