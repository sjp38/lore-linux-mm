From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 24/32] x86, pkeys: actually enable Memory Protection Keys
 in CPU
Date: Mon, 14 Dec 2015 21:00:52 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1512142100410.4336@nanos>
References: <20151214190542.39C4886D@viggo.jf.intel.com> <20151214190622.8DAD0692@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151214190622.8DAD0692@viggo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com
List-Id: linux-mm.kvack.org

On Mon, 14 Dec 2015, Dave Hansen wrote:
> This sets the bit in 'cr4' to actually enable the protection
> keys feature.  We also include a boot-time disable for the
> feature "nopku".
> 
> Seting X86_CR4_PKE will cause the X86_FEATURE_OSPKE cpuid
> bit to appear set.  At this point in boot, identify_cpu()
> has already run the actual CPUID instructions and populated
> the "cpu features" structures.  We need to go back and
> re-run identify_cpu() to make sure it gets updated values.
> 
> We *could* simply re-populate the 11th word of the cpuid
> data, but this is probably quick enough.
> 
> Also note that with the cpu_has() check and X86_FEATURE_PKU
> present in disabled-features.h, we do not need an #ifdef
> for setup_pku().
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
