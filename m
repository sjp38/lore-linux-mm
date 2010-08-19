Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5AB466B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 21:53:47 -0400 (EDT)
Received: by iwn2 with SMTP id 2so1094447iwn.14
        for <linux-mm@kvack.org>; Wed, 18 Aug 2010 18:53:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTinjKK_jKm04BNmTRwq5uW8ainDcJHOXCGCmOXuD@mail.gmail.com>
References: <20100818151857.GA6188@barrios-desktop>
	<20100818172627.7e38969f@varda>
	<AANLkTimxbJQ7+cJ20x1Bcm=1xk_JgMANUQDFn-pJ9jZa@mail.gmail.com>
	<AANLkTimqzQHtSo5f41ze4JEznGCjMNTC_1DPgc21JYT0@mail.gmail.com>
	<AANLkTinjKK_jKm04BNmTRwq5uW8ainDcJHOXCGCmOXuD@mail.gmail.com>
Date: Thu, 19 Aug 2010 10:53:45 +0900
Message-ID: <AANLkTingyhdHQUF4zp-xr_RMD1AJTid6m4kMUuOEH9M3@mail.gmail.com>
Subject: Re: android-kernel memory reclaim x20 boost?
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: San Mehat <san@google.com>
Cc: =?ISO-8859-1?Q?Arve_Hj=F8nnev=E5g?= <arve@android.com>, =?ISO-8859-1?Q?Alejandro_Riveira_Fern=E1ndez?= <ariveira@gmail.com>, swetland@google.com, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 19, 2010 at 10:04 AM, San Mehat <san@google.com> wrote:
> On Wed, Aug 18, 2010 at 6:01 PM, Arve Hj=F8nnev=E5g <arve@android.com> wr=
ote:
>> On Wed, Aug 18, 2010 at 5:54 PM, Minchan Kim <minchan.kim@gmail.com> wro=
te:
>>> On Thu, Aug 19, 2010 at 12:26 AM, Alejandro Riveira Fern=E1ndez
>>> <ariveira@gmail.com> wrote:
>>>> El Thu, 19 Aug 2010 00:18:57 +0900
>>>> Minchan Kim <minchan.kim@gmail.com> escribi=F3:
>>>>
>>>>> Hello Android forks,
>>>> [ ... ]
>>>>>
>>>>> I saw the advertisement phrase in this[1].
>>>>>
>>>>> "Kernel Memory Management Boost: Improved memory reclaim by up to 20x=
,
>>>>> which results in faster app switching and smoother performance
>>>>> on memory-constrained devices."
>>>>>
>>>>> But I can't find any code for it in android kernel git tree.
>>>>
>>>> =A0Maybe the enhancements are on the Dalvik VM (shooting in the dark h=
ere)
>>>
>>> Thanks.
>>> Android guys! Could you confirm this?
>>>
>>
>> It is more likely referring to this change:
>>
>
> There are other changes after the one mentioned that remove the
> requirement for CONFIG_PROFILING
> (and the subsequent task_struct leak that was caused by it)
>
> -san

It seems to be not a issue of mainline but only one of android lowmemkiller=
.
Thanks for the information, Android forks.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
