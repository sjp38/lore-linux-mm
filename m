Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id C6FF18D0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 19:43:33 -0500 (EST)
Date: Fri, 28 Dec 2012 01:42:41 +0100
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
MIME-Version: 1.0
References: <CA+icZUV_CdAvq1nmOVZeLSAu0mZj+BO0T++REc6U1hevt50hXA@mail.gmail.com> <50DCDC21.6080303@iskon.hr> <CA+icZUX2g0R46QNFpntA1r6E3wu0HNhBjk+Kjm581aUBgM6VKA@mail.gmail.com> <50DCDEE5.9000700@iskon.hr> <CA+icZUUXbCCtPaimG6hKsSUQTmnoMAZHsd_nrn7eityepqYUkQ@mail.gmail.com> <50DCE8C8.8050103@iskon.hr> <CA+icZUWDPux3QAzQ85ntfUTHMr5m3Ueo-zjfnoGGxi=VrB9_7A@mail.gmail.com>
In-Reply-To: <CA+icZUWDPux3QAzQ85ntfUTHMr5m3Ueo-zjfnoGGxi=VrB9_7A@mail.gmail.com>
Message-ID: <50DCEB01.3060903@iskon.hr>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 0000000000000500
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sedat.dilek@gmail.com
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On 28.12.2012 01:37, Sedat Dilek wrote:
> On Fri, Dec 28, 2012 at 1:33 AM, Zlatko Calusic <zlatko.calusic@iskon.hr> wrote:
>> On 28.12.2012 01:24, Sedat Dilek wrote:
>>>
>>> On Fri, Dec 28, 2012 at 12:51 AM, Zlatko Calusic
>>> <zlatko.calusic@iskon.hr> wrote:
>>>>
>>>> On 28.12.2012 00:42, Sedat Dilek wrote:
>>>>>
>>>>>
>>>>> On Fri, Dec 28, 2012 at 12:39 AM, Zlatko Calusic
>>>>> <zlatko.calusic@iskon.hr> wrote:
>>>>>>
>>>>>>
>>>>>> On 28.12.2012 00:30, Sedat Dilek wrote:
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>> Hi Zlatko,
>>>>>>>
>>>>>>> I am not sure if I hit the same problem as described in this thread.
>>>>>>>
>>>>>>> Under heavy load, while building a customized toolchain for the Freetz
>>>>>>> router project I got a BUG || NULL pointer derefence || kswapd ||
>>>>>>> zone_balanced || pgdat_balanced() etc. (details see my screenshot).
>>>>>>>
>>>>>>> I will try your patch from [1] ***only*** on top of my last
>>>>>>> Linux-v3.8-rc1 GIT setup (post-v3.8-rc1 mainline + some net-fixes).
>>>>>>>
>>>>>>
>>>>>> Yes, that's the same bug. It should be fixed with my latest patch, so
>>>>>> I'd
>>>>>> appreciate you testing it, to be on the safe side this time. There
>>>>>> should
>>>>>> be
>>>>>> no difference if you apply it to anything newer than 3.8-rc1, so go for
>>>>>> it.
>>>>>> Thanks!
>>>>>>
>>>>>
>>>>> Not sure how I can really reproduce this bug as one build worked fine
>>>>> within my last v3.8-rc1 kernel.
>>>>> I increased the parallel-make-jobs-number from "4" to "8" to stress a
>>>>> bit harder.
>>>>> Just building right now... and will report.
>>>>>
>>>>> If you have any test-case (script or whatever), please let me/us know.
>>>>>
>>>>
>>>> Unfortunately not, I haven't reproduced it yet on my machines. But it
>>>> seems
>>>> that bug will hit only under heavy memory pressure. When close to OOM, or
>>>> possibly with lots of writing to disk. It's also possible that
>>>> fragmentation
>>>> of memory zones could provoke it, that means testing it for a longer
>>>> time.
>>>>
>>>
>>> I tested successfully by doing simultaneously...
>>> - building Freetz with 8 parallel make-jobs
>>> - building Linux GIT with 1 make-job
>>> - 9 tabs open in firefox
>>> - In one tab I ran YouTube music video
>>> - etc.
>>>
>>> I am reading [1] and [2] where another user reports success by reverting
>>> this...
>>>
>>> commit cda73a10eb3f493871ed39f468db50a65ebeddce
>>> "mm: do not sleep in balance_pgdat if there's no i/o congestion"
>>>
>>> BTW, this machine has also 4GiB RAM (Ubuntu/precise AMD64).
>>>
>>> Feel free to add a "Reported-by/Tested-by" if you think this is a
>>> positive report.
>>>
>>
>> Thanks for the testing! And keep running it in case something interesting
>> pops up. ;)
>>
>> No need to revert cda73a10eb because it fixes another bug. And the patch
>> you're now running fixes the new bug I introduced with a combination of my
>> latest 2 patches. Nah, it gets complicated... :)
>>
>> But, at least I found the culprit and as soon as Linus applies the fix,
>> everything will be hunky dory again, at least on this front. :P
>>
>
> I am not subscribed to LKML and linux-mm,,,
> Do you have a patch with a proper subject and descriptive text? URL?
>

Soon to follow. I'd appreciate Zhouping Liu testing it too, though.
-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
