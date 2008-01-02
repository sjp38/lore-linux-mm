Date: Wed, 2 Jan 2008 12:58:45 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 05/10] x86_64: Use generic percpu
In-Reply-To: <200712290255.40233.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0801021256080.22538@schroedinger.engr.sgi.com>
References: <20071228001046.854702000@sgi.com> <200712281354.52453.ak@suse.de>
 <47757311.5050503@sgi.com> <200712290255.40233.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Mike Travis <travis@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, tglx@linutronix.de, mingo@redhat.com
List-ID: <linux-mm.kvack.org>

On Sat, 29 Dec 2007, Andi Kleen wrote:

> Anyways the difference between the x86 percpu.h and the generic one is
> that x86-64 uses a short cut through the PDA to get the current cpu
> offset for the current CPU case. The generic one goes through 
> smp_processor_id()->array reference instead. 

No the patch also uses the pda.

> I would request that this optimization is not being removed
> without suitable replacement in the same patchkit.

The optimization was not removed __my_cpu_offset is used to calculate the 
current offset which is using the pda.

#define __my_cpu_offset read_pda(data_offset)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
