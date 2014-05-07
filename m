Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id C76E96B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 13:49:27 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id d17so988149eek.2
        for <linux-mm@kvack.org>; Wed, 07 May 2014 10:49:27 -0700 (PDT)
Received: from mail-ee0-x230.google.com (mail-ee0-x230.google.com [2a00:1450:4013:c00::230])
        by mx.google.com with ESMTPS id 43si17015836eei.55.2014.05.07.10.49.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 10:49:26 -0700 (PDT)
Received: by mail-ee0-f48.google.com with SMTP id e49so977200eek.7
        for <linux-mm@kvack.org>; Wed, 07 May 2014 10:49:25 -0700 (PDT)
Message-ID: <5369C43D.1000206@gmail.com>
Date: Wed, 07 May 2014 07:27:25 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] ipc/shm.c: increase the limits for SHMMAX, SHMALL
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>	 <CAKgNAkjuU68hgyMOVGBVoBTOhhGdBytQh6H0ExiLoXfujKyP_w@mail.gmail.com>	 <1399406800.13799.20.camel@buesod1.americas.hpqcorp.net>	 <CAKgNAkjOKP7P9veOpnokNkVXSszVZt5asFsNp7rm7AXJdjcLLA@mail.gmail.com> <1399414081.30629.2.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1399414081.30629.2.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: mtk.manpages@gmail.com, Manfred Spraul <manfred@colorfullife.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, aswin@hp.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 05/07/2014 12:08 AM, Davidlohr Bueso wrote:
> On Tue, 2014-05-06 at 22:40 +0200, Michael Kerrisk (man-pages) wrote:
>> Hi Davidlohr,
>>
>> On Tue, May 6, 2014 at 10:06 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
>>> On Fri, 2014-05-02 at 15:16 +0200, Michael Kerrisk (man-pages) wrote:
>>>> Hi Manfred,
>>>>
>>>> On Mon, Apr 21, 2014 at 4:26 PM, Manfred Spraul
>>>> <manfred@colorfullife.com> wrote:
>>>>> Hi all,
>>>>>
>>>>> the increase of SHMMAX/SHMALL is now a 4 patch series.
>>>>> I don't have ideas how to improve it further.
>>>>
>>>> On the assumption that your patches are heading to mainline, could you
>>>> send me a man-pages patch for the changes?
>>>
>>> Btw, I think that the code could still use some love wrt documentation.
>>
>> (Agreed.)
>>
>>> Andrew, please consider this for -next if folks agree. Thanks.
>>>
>>> 8<----------------------------------------------------------
>>>
>>> From: Davidlohr Bueso <davidlohr@hp.com>
>>> Subject: [PATCH] ipc,shm: document new limits in the uapi header
>>>
>>> This is useful in the future and allows users to
>>> better understand the reasoning behind the changes.
>>>
>>> Also use UL as we're dealing with it anyways.
>>>
>>> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
>>> ---
>>>  include/uapi/linux/shm.h | 14 ++++++++------
>>>  1 file changed, 8 insertions(+), 6 deletions(-)
>>>
>>> diff --git a/include/uapi/linux/shm.h b/include/uapi/linux/shm.h
>>> index 74e786d..e37fb08 100644
>>> --- a/include/uapi/linux/shm.h
>>> +++ b/include/uapi/linux/shm.h
>>> @@ -8,17 +8,19 @@
>>>  #endif
>>>
>>>  /*
>>> - * SHMMAX, SHMMNI and SHMALL are upper limits are defaults which can
>>
>> Something is wrong in the line above (missing word(s)?) ("are upper
>> limits are defaults")
>>
>>> - * be modified by sysctl.
>>> + * SHMMNI, SHMMAX and SHMALL are the default upper limits which can be
>>> + * modified by sysctl. Both SHMMAX and SHMALL have their default values
>>> + * to the maximum limit which is as large as it can be without helping
>>> + * userspace overflow the values. There is really nothing the kernel
>>> + * can do to avoid this any variables. It is therefore not advised to
>>
>> Something is missing in that last line.
>>
>>> + * make them any larger. This is suitable for both 32 and 64-bit systems.
>>
>> "This" is not so clear. I suggest replacing with an actual noun.
> 
> Good point. Perhaps 'These values are ...' would do instead. 

That's better.

Did you miss the first point I raised above?

Cheers,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
