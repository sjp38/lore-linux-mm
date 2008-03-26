Message-ID: <47EA7177.8010605@sgi.com>
Date: Wed, 26 Mar 2008 08:53:27 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/12] cpumask: reduce stack pressure from local/passed
 cpumask variables v2
References: <20080326013811.569646000@polaris-admin.engr.sgi.com> <20080326061824.GB18301@elte.hu>
In-Reply-To: <20080326061824.GB18301@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Mike Travis <travis@sgi.com> wrote:
> 
>> Modify usage of cpumask_t variables to use pointers as much as 
>> possible.
> 
> hm, why is there no minimal patch against -git that does nothing but 
> introduces the new pointer based generic APIs (without using them) - 
> such as set_cpus_allowed_ptr(), etc.? Once that is upstream all the 
> remaining changes can trickle one arch and one subsystem at a time, and 
> once that's done, the old set_cpus_allowed() can be removed. This is far 
> more manageable than one large patch.
> 
> and the cpumask_of_cpu() change should be Kconfig based initially - once 
> all arches have moved to it (or even sooner) we can remove that.
> 
> 	Ingo

Yes, good idea!  I'll see about dividing them up.  Though 99% seems to
be in generic kernel code (kernel/sched.c is by far the biggest user.)

There is one function pointer in a struct that would need an additional entry
if we keep both interfaces.

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
