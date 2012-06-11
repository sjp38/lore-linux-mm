Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 49EEA6B0098
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 00:50:27 -0400 (EDT)
Message-ID: <4FD5790F.1050501@kernel.org>
Date: Mon, 11 Jun 2012 13:50:23 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Some vmevent fixes...
References: <4FCD14F1.1030105@gmail.com> <CAOJsxLHR4wSgT2hNfOB=X6ud0rXgYg+h7PTHzAZYCUdLs6Ktug@mail.gmail.com> <20120605083921.GA21745@lizard> <4FD014D7.6000605@kernel.org> <20120608074906.GA27095@lizard> <4FD1BB29.1050805@kernel.org> <CAOJsxLHPvg=bsv+GakFGHyJwH0BoGA=fmzy5bwqWKNGryYTDtg@mail.gmail.com> <84FF21A720B0874AA94B46D76DB98269045F7B42@008-AM1MPN1-004.mgdnok.nokia.com> <20120608094507.GA11963@lizard> <20120608104204.GA2185@barrios> <20120608111421.GA18696@lizard>
In-Reply-To: <20120608111421.GA18696@lizard>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: leonid.moiseichuk@nokia.com, penberg@kernel.org, kosaki.motohiro@gmail.com, john.stultz@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On 06/08/2012 08:14 PM, Anton Vorontsov wrote:

> On Fri, Jun 08, 2012 at 07:42:04PM +0900, Minchan Kim wrote:
> [...]
>> I can't understand. Why can't the approach catch the situation?
>> Let's think about it.
>>
>> There is 40M in CleanCache LRU which has easy-reclaimable pages and
>> there is 10M free pages and 5M high watermark in system.
>>
>> Your application start to consume free pages very slowly.
>> So when your application consumed 5M, VM start to reclaim. So far, it's okay
>> because we have 40M easy-reclaimable pages. And low memory notifier can start
>> to notify so your dameon can do some action to get free pages.
> 
> Maybe I'm missing how would you use the shrinker. But the last time
> I tried on my (swap-less, FWIW) qemu test setup, I was not receiving
> any notifications from the shrinker until the system was almost
> (but not exactly) out of memory.
> 
> My test app was allocating all memory MB by MB, filling the memory
> with zeroes. So, what I was observing is that shrinker callback was
> called just a few MB before OOM, not every 'X' consumed MBs.


Yes. page reclaimer doesn't make sure calling shrinker per MB.
So if you want to be notified per your threshold, shrinker isn't good.

I didn't say I will use shrinker.
I want to add hooks directly in vmscan.c's normal reclaim path, not shrinker.

Still, I want to implement it by level triggering like I mentioned.
I will show you my concept if anybody doesn't interrupt me within a few weeks. :)

Thanks.

> 
>> I think it's not so late.
>>
>> sidenote:
>> It seems I live in the complete opposite place because
>> you guys always start discussion when I am about going out of office.
>> Please understand my late response.
>> Maybe I will come back after weekend. :)
> 
> Well, it's 4AM here. :-) Have a great weekend!
> 


You win! :)
 
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
