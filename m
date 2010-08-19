Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D877B6B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 21:04:18 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id o7J145i8014511
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 18:04:05 -0700
Received: from gyg4 (gyg4.prod.google.com [10.243.50.132])
	by hpaq1.eem.corp.google.com with ESMTP id o7J143ZL026785
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 18:04:03 -0700
Received: by gyg4 with SMTP id 4so572024gyg.13
        for <linux-mm@kvack.org>; Wed, 18 Aug 2010 18:04:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTimqzQHtSo5f41ze4JEznGCjMNTC_1DPgc21JYT0@mail.gmail.com>
References: <20100818151857.GA6188@barrios-desktop>
	<20100818172627.7e38969f@varda>
	<AANLkTimxbJQ7+cJ20x1Bcm=1xk_JgMANUQDFn-pJ9jZa@mail.gmail.com>
	<AANLkTimqzQHtSo5f41ze4JEznGCjMNTC_1DPgc21JYT0@mail.gmail.com>
Date: Wed, 18 Aug 2010 18:04:03 -0700
Message-ID: <AANLkTinjKK_jKm04BNmTRwq5uW8ainDcJHOXCGCmOXuD@mail.gmail.com>
Subject: Re: android-kernel memory reclaim x20 boost?
From: San Mehat <san@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: =?ISO-8859-1?Q?Arve_Hj=F8nnev=E5g?= <arve@android.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, =?ISO-8859-1?Q?Alejandro_Riveira_Fern=E1ndez?= <ariveira@gmail.com>, swetland@google.com, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 18, 2010 at 6:01 PM, Arve Hj=F8nnev=E5g <arve@android.com> wrot=
e:
> On Wed, Aug 18, 2010 at 5:54 PM, Minchan Kim <minchan.kim@gmail.com> wrot=
e:
>> On Thu, Aug 19, 2010 at 12:26 AM, Alejandro Riveira Fern=E1ndez
>> <ariveira@gmail.com> wrote:
>>> El Thu, 19 Aug 2010 00:18:57 +0900
>>> Minchan Kim <minchan.kim@gmail.com> escribi=F3:
>>>
>>>> Hello Android forks,
>>> [ ... ]
>>>>
>>>> I saw the advertisement phrase in this[1].
>>>>
>>>> "Kernel Memory Management Boost: Improved memory reclaim by up to 20x,
>>>> which results in faster app switching and smoother performance
>>>> on memory-constrained devices."
>>>>
>>>> But I can't find any code for it in android kernel git tree.
>>>
>>> =A0Maybe the enhancements are on the Dalvik VM (shooting in the dark he=
re)
>>
>> Thanks.
>> Android guys! Could you confirm this?
>>
>
> It is more likely referring to this change:
>

There are other changes after the one mentioned that remove the
requirement for CONFIG_PROFILING
(and the subsequent task_struct leak that was caused by it)

-san

> Author: San Mehat <san@google.com>
> Date: =A0 Wed May 5 11:38:42 2010 -0700
>
> =A0 =A0staging: android: lowmemkiller: Substantially reduce overhead duri=
ng reclaim
>
> =A0 =A0This patch optimizes lowmemkiller to not do any work when it has
> an outstanding
> =A0 =A0kill-request. This greatly reduces the pressure on the task_list l=
ock
> =A0 =A0(improving interactivity), as well as improving the vmscan perform=
ance
> =A0 =A0when under heavy memory pressure (by up to 20x in tests).
>
> =A0 =A0Note: For this enhancement to work, you need CONFIG_PROFILING
>
> =A0 =A0Signed-off-by: San Mehat <san@google.com>
>
>
> --
> Arve Hj=F8nnev=E5g
>



--=20
San Mehat =A0| =A0Staff Software Engineer =A0| =A0Infrastructure =A0| =A0Go=
ogle Inc.
415.366.6172 (san@google.com)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
