Date: Mon, 2 Apr 2007 08:37:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
In-Reply-To: <200704011246.52238.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
 <20070401071029.23757.78021.sendpatchset@schroedinger.engr.sgi.com>
 <200704011246.52238.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Sun, 1 Apr 2007, Andi Kleen wrote:

> Hmm, this means there is at least 2MB worth of struct page on every node?
> Or do you have overlaps with other memory (I think you have)
> In that case you have to handle the overlap in change_page_attr()

Correct. 2MB worth of struct page is 128 mb of memory. Are there nodes 
with smaller amounts of memory? Note also that the default sparsemem
section size is (include/asm-x86_64/sparsemem.h)

#define SECTION_SIZE_BITS       27 /* matt - 128 is convenient right now */

128MB ....

So you currently cannot have smaller sections of memory anyways.

> Also your "generic" vmemmap code doesn't look very generic, but
> rather x86 specific. I didn't think huge pages could be easily
> set up this way in many other architectures.  

We do this pmd special casing in other parts of the core VM. I have also a 
patch for IA64 that workks with this.

> Do you have any benchmarks numbers to prove it? There seem to be a few
> benchmarks where the discontig virt_to_page is a problem
> (although I know ways to make it more efficient), and sparsemem
> is normally slower. Still some numbers would be good.

You want a benchmark to prove that the removal of memory references and 
code improves performance?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
