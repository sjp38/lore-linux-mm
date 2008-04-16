Date: Wed, 16 Apr 2008 14:22:38 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH] - Increase MAX_APICS for large configs
Message-ID: <20080416192238.GA12115@sgi.com>
References: <20080416163936.GA23099@sgi.com> <20080416184543.GD3722@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080416184543.GD3722@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 16, 2008 at 08:45:43PM +0200, Ingo Molnar wrote:
> 
> * Jack Steiner <steiner@sgi.com> wrote:
> 
> > Increase the maximum number of apics when running very large 
> > configurations. This patch has no affect on most systems.
> > 
> > Signed-off-by: Jack Steiner <steiner@sgi.com>
> > 
> > I think this area of the code will be substantially changed when the 
> > full x2apic patch is available. In the meantime, this seems like an 
> > acceptible alternative. The patch has no effect on any 32-bit kernel. 
> > It adds ~4k to the size of 64-bit kernels but only if NR_CPUS > 255.
> 
> ugly ... but well - applied. What's the static size cost of 64K APICs?

64k APICs would add ~8k to the static size of the kernel. Most of the
increase is in the phys_cpu_present_map[].

When the x2apic patch is integrated, I expect (may be wrong) that this
array will be eliminated since x2apic increases the max APIC_ID to 32 bits,

Note that MAX_APICS is really misnamed. It is not the maximum number of APICs. It
is the value of the largest APIC ID. IDs are not necessarily dense.


--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
