Message-ID: <47BC7816.2030008@sgi.com>
Date: Wed, 20 Feb 2008 10:57:26 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] x86_64: Fold pda into per cpu area v3
References: <20080219203335.866324000@polaris-admin.engr.sgi.com> <20080219203336.046039000@polaris-admin.engr.sgi.com> <20080220120747.GA13695@elte.hu>
In-Reply-To: <20080220120747.GA13695@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Randy Dunlap <rdunlap@xenotime.net>, Joel Schopp <jschopp@austin.ibm.com>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Mike Travis <travis@sgi.com> wrote:
> 
>>   * Declare the pda as a per cpu variable. This will move the pda area
>>     to an address accessible by the x86_64 per cpu macros.  
>>     Subtraction of __per_cpu_start will make the offset based from the 
>>     beginning of the per cpu area.  Since %gs is pointing to the pda, 
>>     it will then also point to the per cpu variables and can be 
>>     accessed thusly:
>>
>> 	%gs:[&per_cpu_xxxx - __per_cpu_start]
> 
> randconfig QA on x86.git found a crash on x86.git#testing with 
> nmi_watchdog=2 (config attached) - and i bisected it down to this patch.
> 
> config and crashlog attached. You can pick up x86.git#testing via:
> 
>   http://people.redhat.com/mingo/x86.git/README
> 
> (since i had to hand-merge the patch when integrating it, i've attached 
> the merged version below.)
> 
> 	Ingo
> 

I must need some different test machines as my AMD box does not fail with
either yours or Thomas's configs, and the Intel box complains about the
PCI-e e1000 driver and dies.  I'll see about configuring a new box.

Did you try Eric's patch to see if that fixed the failure?

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
