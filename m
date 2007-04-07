From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 1/4] x86_64: (SPARSE_VIRTUAL doubles sparsemem speed)
Date: Sun, 8 Apr 2007 00:18:44 +0200
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0704051119400.9800@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0704071455060.31468@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0704071455060.31468@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200704080018.45084.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Martin Bligh <mbligh@google.com>, Dave Hansen <hansendc@us.ibm.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Sunday 08 April 2007 00:06:13 Christoph Lameter wrote:

> Results:
> 
> x86_64 boot with virtual memmap
> 
> Format:               #events totaltime (min/avg/max)
> 
> kfree_virt_to_page       598430 5.6ms(3ns/9ns/322ns)
> 
> x86_64 boot regular sparsemem
> 
> kfree_virt_to_page       596360 10.5ms(4ns/18ns/28.7us)
> 
> 
> On average sparsemem virtual takes half the time than of sparsemem.

Nice.  But on what workloads? 

Anyways it looks promising. I hope we can just
replace old style sparsemem support with this for x86-64.

> Time is measured using the cycle counter (TSC on IA32, ITC on IA64) which has
> a very low latency.

Sorry that triggered my usual RDTSC rant...

Not on NetBurst (hundred of cycles) And on the others (C2,K8) it is a bit dangerous 
to measure short code blocks because RDTSC is not guaranteed ordered with the surrounding 
instructions.

-Andi
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
