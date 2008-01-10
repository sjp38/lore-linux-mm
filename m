Message-ID: <4785D208.4020804@de.ibm.com>
Date: Thu, 10 Jan 2008 09:06:32 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [rfc][patch 1/4] include: add callbacks to toggle reference counting
 for VM_MIXEDMAP pages
References: <476A73F0.4070704@de.ibm.com> <476A7D21.7070607@de.ibm.com> <20071221004556.GB31040@wotan.suse.de> <476B9000.2090707@de.ibm.com> <20071221102052.GB28484@wotan.suse.de> <476B96D6.2010302@de.ibm.com> <20071221104701.GE28484@wotan.suse.de> <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com> <1199891032.28689.9.camel@cotte.boeblingen.de.ibm.com> <1199891645.28689.22.camel@cotte.boeblingen.de.ibm.com> <20080110002021.GC19997@wotan.suse.de>
In-Reply-To: <20080110002021.GC19997@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: carsteno@linux.vnet.ibm.com, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, mschwid2@linux.vnet.ibm.com, heicars2@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Hmm, I had it in my mind that this would be entirely hidden in the s390's
> mixedmap_refcount_pfn, but of course you actually need to set the pte too....
I did'nt think about that upfront too.

> In that case, I would rather prefer to go along the lines of my pte_special
> patch, which would replace all of vm_normal_page (on a per-arch basis), and
> you wouldn't need this mixedmap_refcount_* stuff (it can stay pfn_valid for
> those architectures that don't implement pte_special).
I am going to play with PTE_SPECIAL next.  I tend to agree with you 
that the
PTE_SPECIAL path looks more promising than the one implemented in this 
patch
series because it offers a more generic meaning for our valuable pte 
bit which
can be used for various purposes by core-vm.
Let's just implement them all, and figure the best one after that ;-).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
