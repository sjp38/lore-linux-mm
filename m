Message-ID: <47EA75C7.7020506@sgi.com>
Date: Wed, 26 Mar 2008 09:11:51 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/10] x86_64: Cleanup non-smp usage of cpu maps v2
References: <20080325220650.835342000@polaris-admin.engr.sgi.com> <20080325220651.011213000@polaris-admin.engr.sgi.com> <20080326064045.GF18301@elte.hu>
In-Reply-To: <20080326064045.GF18301@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Mike Travis <travis@sgi.com> wrote:
> 
>> Cleanup references to the early cpu maps for the non-SMP configuration 
>> and remove some functions called for SMP configurations only.
> 
> thanks, applied.
> 
> one observation:
> 
>> +#ifdef CONFIG_SMP
>>  extern int x86_cpu_to_node_map_init[];
>>  extern void *x86_cpu_to_node_map_early_ptr;
>> +#else
>> +#define x86_cpu_to_node_map_early_ptr NULL
>> +#endif
> 
> Right now all these early_ptrs are in essence open-coded "early 
> per-cpu", right? But shouldnt we solve that in a much cleaner way: by 
> explicitly adding an early-per-cpu types and accessors, and avoid all 
> that #ifdeffery?
> 
> 	Ingo

I was thinking of something similar but had to put it on the back
burner until we got to the point of being able to boot a kernel
with NR_CPUS set to 4096.  It should pop back up on the priority
queue very soon... ;-)

Thanks!
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
