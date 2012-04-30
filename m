Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 863ED6B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 03:52:16 -0400 (EDT)
Message-ID: <4F9E44AD.8020701@kernel.org>
Date: Mon, 30 Apr 2012 16:52:13 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: vmevent: question?
References: <4F9E39F1.5030600@kernel.org> <CAOJsxLE3A3b5HSrRm0NVCBmzv7AAs-RWEiZC1BL=se309+=WTA@mail.gmail.com>
In-Reply-To: <CAOJsxLE3A3b5HSrRm0NVCBmzv7AAs-RWEiZC1BL=se309+=WTA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <anton.vorontsov@linaro.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>

On 04/30/2012 04:35 PM, Pekka Enberg wrote:

> Hi Minchan,
> 
> On Mon, Apr 30, 2012 at 10:06 AM, Minchan Kim <minchan@kernel.org> wrote:
>> vmevent_smaple gathers all registered values to report to user if vmevent match.
>> But the time gap between vmevent match check and vmevent_sample_attr could make error
>> so user could confuse.
>>
>> Q 1. Why do we report _all_ registered vmstat value?
>>     In my opinion, it's okay just to report _a_ value vmevent_match happens.
> 
> It makes the userspace side simpler for "lowmem notification" use
> case. I'm open to changing the ABI if it doesn't make the userspace
> side too complex.


Yes. I understand your point but if we still consider all of values,
we don't have any way to capture exact values except triggered event value.
I mean there is no lock to keep consistency.
If stale data is okay, no problem but IMHO, it could make user very confusing.
So let's return value for first matched event if various event match.
Of course, let's write down it in ABI.
If there is other idea for reporting all of item with consistent, I'm okay.

>> Q 2. Is it okay although value when vmevent_match check happens is different with
>>     vmevent_sample_attr in vmevent_sample's for loop?
>>     I think it's not good.
> 
> Yeah, that's just silly and needs fixing.


It depends on Q.1. So first of all, we have to determine Q 1's policy.

> 
>> Q 3. Do you have any plan to change getting value's method?
>>     Now it's IRQ context so we have limitation to get a vmstat values so that
>>     It couldn't be generic. IMHO, To merge into mainline, we should solve this problem.
> 
> Yes, that needs fixing as well. I was hoping to reuse perf sampling
> code for this.
> 
>> Q 4. Do you have any plan for this patchset to merge into mainline?
> 
> Yes, I'm interested in pushing it forward if we can show that the ABI
> makes sense, is stable and generic enough, and fixes real world
> problems.


Yes. I think it would be a good for embedded and KVM world for preventing
unnecessary swapped-out and OOM. :)


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
