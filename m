Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id E5A516B0254
	for <linux-mm@kvack.org>; Sun,  9 Aug 2015 21:30:15 -0400 (EDT)
Received: by ioii16 with SMTP id i16so156050432ioi.0
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 18:30:15 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id t13si4612858igr.93.2015.08.09.18.30.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Sun, 09 Aug 2015 18:30:15 -0700 (PDT)
Subject: Re: PROBLEM: 4.1.4 -- Kernel Panic on shutdown
References: <55C18D2E.4030009@rjmx.net>
 <alpine.DEB.2.11.1508051105070.29534@east.gentwo.org>
 <20150805162436.GD25159@twins.programming.kicks-ass.net>
 <alpine.DEB.2.11.1508051131580.29823@east.gentwo.org>
 <20150805163609.GE25159@twins.programming.kicks-ass.net>
 <alpine.DEB.2.11.1508051201280.29823@east.gentwo.org>
 <55C2BC00.8020302@rjmx.net>
 <alpine.DEB.2.11.1508052229540.891@east.gentwo.org>
 <55C3F70E.2050202@rjmx.net> <55C4C6E8.5090501@redhat.com>
 <55C5645D.1080508@rjmx.net> <55C75A46.6030308@redhat.com>
From: Ron Murray <rjmx@rjmx.net>
Message-ID: <55C7FE9D.9010707@rjmx.net>
Date: Sun, 9 Aug 2015 21:30:05 -0400
MIME-Version: 1.0
In-Reply-To: <55C75A46.6030308@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Christoph Lameter <cl@linux.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>

On 08/09/2015 09:48 AM, Laura Abbott wrote:
> On 08/07/2015 07:07 PM, Ron Murray wrote:
>> On 08/07/2015 10:55 AM, Laura Abbott wrote:
>>>
>>> There was a similar report about a crash on reboot with 4.1.3[1]
>>> where that reporter linked it to a bluetooth mouse. Hopefully this
>>> isn't a red herring but it might be a similar report?
>>>
>>> Thanks,
>>> Laura
>>>
>>> [1]https://bugzilla.redhat.com/show_bug.cgi?id=1248741
>>>
>> Thanks for the suggestion. I don't have a bluetooth mouse (although it
>> is wireless), but I do have a bluetooth keyboard. And -- surprise! -- I
>> don't get a crash when I leave the keyboard turned off.
>>
>> It seems to me that there are at least two possibilities here:
>>
>> 1. Something in the bluetooth stack causes some kind of memory
>> corruption
>>
>> or
>>
>> 2. The corruption is caused by something else, and using bluetooth
>> shifts it into a memory range where it causes crashes (we already know
>> that it's very touchy).
>>
>> Do you know if the original poster in the Red Hat bug report solved the
>> problem, or did he just give up using bluetooth?
>>
>> Suggestions for further faultfinding appreciated.
>>
>>   .....Ron
>>
>>
>
>
> There was a report of HID corruption, can you try the patch at
> https://git.kernel.org/cgit/linux/kernel/git/jikos/hid.git/commit/?id=0621809e37936e7c2b3eac9165cf2aad7f9189eb
>
>
> Thanks,
> Laura

That patch does seem to have fixed the problem (at least, I don't now
get a crash on shutdown).

Thanks,

 .....Ron

-- 
Ron Murray <rjmx@rjmx.net>
PGP Fingerprint: 0ED0 C1D1 615C FCCE 7424  9B27 31D8 AED5 AF6D 0D4A

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
