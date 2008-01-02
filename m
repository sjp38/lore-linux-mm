From: Andi Kleen <ak@suse.de>
Subject: Re: [patch] mm: fix PageUptodate memory ordering bug
Date: Wed, 2 Jan 2008 22:01:27 +0100
References: <20071218012632.GA23110@wotan.suse.de> <20071230163315.GA1384@elte.hu> <20080101232634.GA29301@wotan.suse.de>
In-Reply-To: <20080101232634.GA29301@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200801022201.28025.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

On Wednesday 02 January 2008 00:26:34 Nick Piggin wrote:
> On Sun, Dec 30, 2007 at 05:33:15PM +0100, Ingo Molnar wrote:
> > 
> > * Nick Piggin <npiggin@suse.de> wrote:
> > 
> > > > Sounds worthwhile, if we can't do it via altinstructions.
> > > 
> > > Altinstructions means we still have code bloat, and sometimes extra 
> > > branches etc (an extra 900 bytes of icache in mm/ alone, even before 
> > > my fix). I'll let Linus or one of the x86 guys weigh in, though. It's 
> > > a really sad cost for distro kernels to carry.
> > 
> > hm, we should at minimum display a warning if the workaround is not 
> > enabled and such a kernel is booted on a true PPro that is affected by 
> > this.
> 
> The patch does have the warning:
>   printk(KERN_INFO "Pentium Pro with Errata#66, #92 detected. Limiting maxcpus to 1.
>          Enable CONFIG_X86_BROKEN_PPRO_SMP to run with multiple CPUs\n");

Haven't seen the full patch, but the printk suggest you're changing the max_cpus 
variable. That is not 100% safe because user space could hot plug CPUs later
using sysfs. The only safe way would be to limit cpu_possible_map

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
