From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 26/31] x86, pkeys: add arch_validate_pkey()
Date: Fri, 8 Jan 2016 20:34:27 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1601082034170.3575@nanos>
References: <20160107000104.1A105322@viggo.jf.intel.com> <20160107000141.DC5BF73E@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160107000141.DC5BF73E@viggo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com
List-Id: linux-mm.kvack.org

On Wed, 6 Jan 2016, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> The syscall-level code is passed a protection key and need to
> return an appropriate error code if the protection key is bogus.
> We will be using this in subsequent patches.
> 
> Note that this also begins a series of arch-specific calls that
> we need to expose in otherwise arch-independent code.  We create
> a linux/pkeys.h header where we will put *all* the stubs for
> these functions.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
