Date: Wed, 31 Aug 2005 16:06:12 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 1/1] Implement shared page tables
In-Reply-To: <16640000.1125498711@[10.10.2.4]>
Message-ID: <Pine.LNX.4.61.0508311557190.17726@goblin.wat.veritas.com>
References: <7C49DFF721CB4E671DB260F9@[10.1.1.4]>
 <Pine.LNX.4.61.0508311143340.15467@goblin.wat.veritas.com><1125489077.3213.12.camel@laptopd505.fenrus.org>
 <Pine.LNX.4.61.0508311437070.16834@goblin.wat.veritas.com>
 <16640000.1125498711@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Arjan van de Ven <arjan@infradead.org>, Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 31 Aug 2005, Martin J. Bligh wrote:
> --Hugh Dickins <hugh@veritas.com> wrote (on Wednesday, August 31, 2005 14:42:38 +0100):
> > 
> > Which is indeed a further disincentive against shared page tables.
> 
> Or shared pagetables a disincentive to randomizing the mmap space ;-)

Fair point!

> They're incompatible, but you could be left to choose one or the other
> via config option.

Wouldn't need config option: there's /proc/sys/kernel/randomize_va_space
for the whole running system, compatibility check on the ELFs run, and
the infinite stack rlimit: enough ways to suppress randomization if it
doesn't suit you.

> 3% on "a certain industry-standard database benchmark" (cough) is huge,
> and we expect the benefit for PPC64 will be larger as we can share the
> underlying hardware PTEs without TLB flushing as well.

Okay - and you're implying that 3% comes from _using_ the shared page
tables, rather than from avoiding the fork/exit overhead of setting
them up and tearing them down.  And it can't use huge TLB pages
because...  fragmentation?

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
