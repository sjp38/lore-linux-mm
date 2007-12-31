Message-ID: <477916A9.6030001@sgi.com>
Date: Mon, 31 Dec 2007 08:19:53 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/10] x86_64: Use generic percpu
References: <20071228001046.854702000@sgi.com> <200712281354.52453.ak@suse.de> <47757311.5050503@sgi.com> <200712290255.40233.ak@suse.de>
In-Reply-To: <200712290255.40233.ak@suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, tglx@linutronix.de, mingo@redhat.com
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Friday 28 December 2007 23:05:05 Mike Travis wrote:
>> Andi Kleen wrote:
>>> On Friday 28 December 2007 01:10:51 travis@sgi.com wrote:
>>>> x86_64 provides an optimized way to determine the local per cpu area
>>>> offset through the pda and determines the base by accessing a remote
>>>> pda.
>>> And? The rationale for this patch seems to be incomplete.
>>>
>>> As far as I can figure out you're replacing an optimized percpu
>>> implementation which a dumber generic one. Which needs
>>> at least some description why.
>> The specific intent for the next wave of changes coming are to reduce
> [...] That should be in the changelog of the patch.
> 
> Anyways the difference between the x86 percpu.h and the generic one is
> that x86-64 uses a short cut through the PDA to get the current cpu
> offset for the current CPU case. The generic one goes through 
> smp_processor_id()->array reference instead. 
> 
> I would request that this optimization is not being removed
> without suitable replacement in the same patchkit.
> 
> -Andi

I'll take a closer look at this, but it may have to wait until Christoph
is back this Wednesday.

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
