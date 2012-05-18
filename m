Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 7B6658D0001
	for <linux-mm@kvack.org>; Fri, 18 May 2012 04:36:00 -0400 (EDT)
Message-ID: <4FB60A1F.4010202@kernel.org>
Date: Fri, 18 May 2012 17:36:47 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/3] x86: Support local_flush_tlb_kernel_range
References: <1337133919-4182-1-git-send-email-minchan@kernel.org>  <1337133919-4182-3-git-send-email-minchan@kernel.org>  <4FB4B29C.4010908@kernel.org> <1337266310.4281.30.camel@twins>
In-Reply-To: <1337266310.4281.30.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>, David Howells <dhowells@redhat.com>, x86@kernel.org, Nick Piggin <npiggin@gmail.com>

Hi Peter,

On 05/17/2012 11:51 PM, Peter Zijlstra wrote:

> On Thu, 2012-05-17 at 17:11 +0900, Minchan Kim wrote:
>>> +++ b/arch/x86/include/asm/tlbflush.h
>>> @@ -172,4 +172,16 @@ static inline void flush_tlb_kernel_range(unsigned long start,
>>>       flush_tlb_all();
>>>  }
>>>  
>>> +static inline void local_flush_tlb_kernel_range(unsigned long start,
>>> +             unsigned long end)
>>> +{
>>> +     if (cpu_has_invlpg) {
>>> +             while (start < end) {
>>> +                     __flush_tlb_single(start);
>>> +                     start += PAGE_SIZE;
>>> +             }
>>> +     } else
>>> +             local_flush_tlb();
>>> +}
> 
> 
> It would be much better if you wait for Alex Shi's patch to mature.
> doing the invlpg thing for ranges is not an unconditional win.


Thanks for the information. I will watch that patchset.
Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
