Date: Mon, 2 Apr 2007 08:44:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
In-Reply-To: <200704011246.52238.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0704020840370.30394@schroedinger.engr.sgi.com>
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

> And when you reserve virtual space somewhere you should 
> update Documentation/x86_64/mm.txt. Also you didn't adjust 
> the end of the vmalloc area so in theory vmalloc could run
> into your vmemmap.

Ok. will add to the doc in the next release.

No need to adjust the end of the vmalloc area because
the vmemmap starts at the end of it:

include/asm-x86_64/pgtable.h:

#define VMALLOC_START    0xffffc20000000000UL
#define VMALLOC_END      0xffffe1ffffffffffUL

Index: linux-2.6.21-rc5-mm2/include/asm-x86_64/page.h

#define vmemmap ((struct page *)0xffffe20000000000UL)

According to Documentation/x86_64/mm.txt this is an unused hole:

ffffc20000000000 - ffffe1ffffffffff (=45 bits) vmalloc/ioremap space
... unused hole ...
ffffffff80000000 - ffffffff82800000 (=40 MB)   kernel text mapping, from phys 0
... unused hole ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
