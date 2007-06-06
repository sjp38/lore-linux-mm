Date: Wed, 6 Jun 2007 16:19:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: SLUB: Use ilog2 instead of series of constant comparisons.
Message-Id: <20070606161909.ea6a2556.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0706061349451.12665@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705211250410.27950@schroedinger.engr.sgi.com>
	<20070606100817.7af24b74.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0706061053290.11553@schroedinger.engr.sgi.com>
	<20070606131121.a8f7be78.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0706061326020.12565@schroedinger.engr.sgi.com>
	<20070606133432.2f3cb26a.akpm@linux-foundation.org>
	<46671C16.9080409@mbligh.org>
	<Pine.LNX.4.64.0706061349451.12665@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Martin Bligh <mbligh@mbligh.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Wed, 6 Jun 2007 13:52:01 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 6 Jun 2007, Martin Bligh wrote:
> 
> > > I tried to build gcc-3.3.3 the other day.  Would you believe that gcc-4.1.0
> > > fails to compile gcc-3.3.3?
> > 
> > IIRC, the SUSE ones were customized anyway, so not sure that'd help you.
> > Might do though.
> 
> Tried building with gcc-3.3
> 
> clameter@schroedinger:~/software/slub$ powerpc-linux-gnu-gcc --version
> powerpc-linux-gnu-gcc (GCC) 3.3.6 (Debian 1:3.3.6-15)
> 
> but cell_defconfig and pseries_defconfig fail to build straight out.
> This is what happens with pseries_defconfig:
> 
>   CHK     include/linux/version.h
>   CHK     include/linux/utsrelease.h
>   CC      arch/powerpc/kernel/asm-offsets.s
> In file included from include/asm/mmu.h:7,
>                  from include/asm/lppaca.h:32,
>                  from include/asm/paca.h:20,
>                  from include/asm/hw_irq.h:17,
>                  from include/asm/system.h:9,
>                  from include/linux/list.h:9,
>                  from include/linux/signal.h:8,
>                  from arch/powerpc/kernel/asm-offsets.c:16:
> include/asm/mmu-hash64.h: In function `hpte_encode_r':
> include/asm/mmu-hash64.h:216: warning: integer constant is too large for 
> "unsigned long" type
> include/asm/mmu-hash64.h: In function `hpt_hash':
> include/asm/mmu-hash64.h:231: warning: integer constant is too large for 
> "unsigned long" type
> include/asm/mmu-hash64.h: In function `vsid_scramble':
> include/asm/mmu-hash64.h:387: warning: right shift count >= width of type
> include/asm/mmu-hash64.h:387: warning: left shift count >= width of type
> include/asm/mmu-hash64.h:388: warning: right shift count >= width of type
> include/asm/mmu-hash64.h:388: warning: left shift count >= width of type
> include/asm/mmu-hash64.h: In function `get_kernel_vsid':
> include/asm/mmu-hash64.h:395: error: `SID_SHIFT' undeclared (first use in 
> this function)

<recovers from three-hour outage, caused by both ends of ethernet cable
plugged into the same switch, two switches away.  Offspring suspected.>

Did you try starting from the test.kernel.org config? 
http://test.kernel.org/abat/93412/build/dotconfig

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
