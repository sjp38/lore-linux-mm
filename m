Date: Wed, 2 Jan 2008 00:26:34 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: fix PageUptodate memory ordering bug
Message-ID: <20080101232634.GA29301@wotan.suse.de>
References: <20071218012632.GA23110@wotan.suse.de> <20071222005737.2675c33b.akpm@linux-foundation.org> <20071223055730.GA29288@wotan.suse.de> <20071222223234.7f0fbd8a.akpm@linux-foundation.org> <20071223071529.GC29288@wotan.suse.de> <20071222232932.590e2b6c.akpm@linux-foundation.org> <20071223091405.GA15631@wotan.suse.de> <20071230163315.GA1384@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071230163315.GA1384@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <ak@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

On Sun, Dec 30, 2007 at 05:33:15PM +0100, Ingo Molnar wrote:
> 
> * Nick Piggin <npiggin@suse.de> wrote:
> 
> > > Sounds worthwhile, if we can't do it via altinstructions.
> > 
> > Altinstructions means we still have code bloat, and sometimes extra 
> > branches etc (an extra 900 bytes of icache in mm/ alone, even before 
> > my fix). I'll let Linus or one of the x86 guys weigh in, though. It's 
> > a really sad cost for distro kernels to carry.
> 
> hm, we should at minimum display a warning if the workaround is not 
> enabled and such a kernel is booted on a true PPro that is affected by 
> this.

The patch does have the warning:
  printk(KERN_INFO "Pentium Pro with Errata#66, #92 detected. Limiting maxcpus to 1.
         Enable CONFIG_X86_BROKEN_PPRO_SMP to run with multiple CPUs\n");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
