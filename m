Date: Wed, 9 Apr 2008 04:10:19 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] SLQB: YASA
Message-ID: <20080409021019.GA23602@wotan.suse.de>
References: <20080403072550.GC25932@wotan.suse.de> <Pine.LNX.4.64.0804031200530.7265@schroedinger.engr.sgi.com> <20080408115717.GB22687@wotan.suse.de> <20080408155142.4b421497@mandriva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080408155142.4b421497@mandriva.com.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
Cc: Christoph Lameter <clameter@sgi.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 08, 2008 at 03:51:42PM -0300, Luiz Fernando N. Capitulino wrote:
> Em Tue, 8 Apr 2008 13:57:17 +0200
> Nick Piggin <npiggin@suse.de> escreveu:
> 
> | Here is my more working version of SLQB. 
> | 
> | Was experimenting with a couple of different ways to do remote freeing,
> | but it is really hard to tune properly without having "real" workloads,
> | due to cache effects.
> | 
> | Anyway, same comments apply. Patch is against mainline.
> 
>  I get the following error when compiling without CONFIG_SMP
> 
> """
> In file included from include/linux/rcupdate.h:52,
>                  from include/linux/slqb_def.h:15,
>                  from include/linux/slab.h:121,
>                  from include/asm/pgtable_32.h:22,
>                  from include/asm/pgtable.h:241,
>                  from include/linux/mm.h:40,
>                  from arch/x86/kernel/pci-dma_32.c:12:
> include/linux/percpu.h: In function '__percpu_alloc_mask':
> include/linux/percpu.h:106: error: implicit declaration of function 'kzalloc'
> include/linux/percpu.h:106: warning: return makes pointer from integer without a cast
> In file included from include/asm/pgtable_32.h:22,
>                  from include/asm/pgtable.h:241,
>                  from include/linux/mm.h:40,
>                  from arch/x86/kernel/pci-dma_32.c:12:
> include/linux/slab.h: At top level:
> include/linux/slab.h:272: error: conflicting types for 'kzalloc'
> include/linux/percpu.h:106: error: previous implicit declaration of 'kzalloc' was here
> ICECC[27645] 15:49:30: Compiled on XXXXXXXX
> make[1]: *** [arch/x86/kernel/pci-dma_32.o] Error 1
> make: *** [arch/x86/kernel] Error 2
> 
> """
> 
>  Could not figure out what the problem is.

Hmm, it seems like some kind of recursive dep, but somehow it goes away
with SMP, so it must be fixable... I'll take a further look.

 
>  Regarding performance tests, I saw that Christoph has some
> interesting test modules in his git repository. Do you think it's
> worth to run them?

I have tried some of them, yes. Performance comparisons vary depending on
machine and workload, but I'd say it is mostly competitive. But those
tests are quite basic and are very far from real world situations. They
are very good for some cases showing where you might have a problem, but
not so useful when comparing 2 different allocators.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
