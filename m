Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 22F526B0089
	for <linux-mm@kvack.org>; Sun, 14 Jul 2013 21:38:52 -0400 (EDT)
Received: by mail-ie0-f170.google.com with SMTP id e11so25031448iej.15
        for <linux-mm@kvack.org>; Sun, 14 Jul 2013 18:38:51 -0700 (PDT)
Message-ID: <51E3529F.6070909@gmail.com>
Date: Mon, 15 Jul 2013 09:38:39 +0800
From: Sam Ben <sam.bennn@gmail.com>
MIME-Version: 1.0
Subject: Re: boot tracing
References: <1373594635-131067-1-git-send-email-holt@sgi.com> <20130712082756.GA4328@gmail.com> <20130712084712.GD24008@pd.tnic> <20130712085341.GC4328@gmail.com>
In-Reply-To: <20130712085341.GC4328@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, Robin Holt <holt@sgi.com>, Robert Richter <rric@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Nate Zimmer <nzimmer@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On 07/12/2013 04:53 PM, Ingo Molnar wrote:
> * Borislav Petkov <bp@alien8.de> wrote:
>
>> On Fri, Jul 12, 2013 at 10:27:56AM +0200, Ingo Molnar wrote:
>>> Robert Richter and Boris Petkov are working on 'persistent events'
>>> support for perf, which will eventually allow boot time profiling -
>>> I'm not sure if the patches and the tooling support is ready enough
>>> yet for your purposes.
>> Nope, not yet but we're getting there.
>>
>>> Robert, Boris, the following workflow would be pretty intuitive:
>>>
>>>   - kernel developer sets boot flag: perf=boot,freq=1khz,size=16MB
>> What does perf=boot mean? I assume boot tracing.
> In this case it would mean boot profiling - i.e. a cycles hardware-PMU
> event collecting into a perf trace buffer as usual.
>
> Essentially a 'perf record -a' work-alike, just one that gets activated as
> early as practical, and which would allow the profiling of memory
> initialization.
>
> Now, one extra complication here is that to be able to profile buddy
> allocator this persistent event would have to work before the buddy
> allocator is active :-/ So this sort of profiling would have to use
> memblock_alloc().

Could perf=boot be used to sample the performance of memblock subsystem? 
I think the perf subsystem is too late to be initialized and monitor this.

>
> Just wanted to highlight this usecase, we might eventually want to support
> it.
>
> [ Note that this is different from boot tracing of one or more trace
>    events - but it's a conceptually pretty close cousin. ]
>   
> Thanks,
>
> 	Ingo
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
