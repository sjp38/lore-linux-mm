Date: Wed, 3 May 2006 16:54:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: RFC: RCU protected page table walking
In-Reply-To: <Pine.LNX.4.64.0605031847190.15463@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0605031649400.32117@schroedinger.engr.sgi.com>
References: <4458CCDC.5060607@bull.net> <200605031846.51657.ak@suse.de>
 <Pine.LNX.4.64.0605031847190.15463@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kenneth.w.chen@intel.com
Cc: Hugh Dickins <hugh@veritas.com>, Andi Kleen <ak@suse.de>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, linux-mm@kvack.org, Zoltan.Menyhart@free.fr, linux-i64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 May 2006, Hugh Dickins wrote:

> Those architectures (including i386 and x86_64) which #define their
> __pte_free_tlb etc. to tlb_remove_page are safe as is.  But Zoltan's
> ia64 #defines it to pte_free, which looks like it may free_page before
> the TLB flush.  But it is surprising if it has actually been unsafe

Sorry but I am in .au right now with spotty high latency connectivity. 
But the people on linux-ia64 should know. Ken?

Why was linux-ia64 not cced??

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
