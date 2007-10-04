Date: Thu, 4 Oct 2007 12:26:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [14/18] Configure stack size
In-Reply-To: <200710041111.05141.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0710041221080.12075@schroedinger.engr.sgi.com>
References: <20071004035935.042951211@sgi.com> <20071004040004.936534357@sgi.com>
 <200710041111.05141.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, travis@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 4 Oct 2007, Andi Kleen wrote:

> On Thursday 04 October 2007 05:59, Christoph Lameter wrote:
> > Make the stack size configurable now that we can fallback to vmalloc if
> > necessary. SGI NUMA configurations may need more stack because cpumasks
> > and nodemasks are at times kept on the stack.  With the coming 16k cpu 
> > support 
> 
> Hmm, I was told 512 byte cpumasks for x86 earlier. Why is this suddenly 2K? 

512 is for the default 4k cpu configuration that should be enough for most 
purposes. The hardware maximum is 16k and we need at least a kernel config 
option that covers the potential stack size issues.

> 2K is too much imho. If you really want to go that big you have
> to look in allocating them all separately imho. But messing
> with the stack TLB entries and risking more TLB misses 
> is not a good idea.

These machines have very large amounts of memory (up to the maximum 
addressable memory of an x86_64 cpu). The fallback is as good as 
impossible. If you get into fallback then we are likely already swapping 
and doing other bad placement things. We typically tune the loads to avoid 
this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
