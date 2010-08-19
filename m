Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5C4566B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 21:02:01 -0400 (EDT)
Received: by wwc33 with SMTP id 33so1447105wwc.26
        for <linux-mm@kvack.org>; Wed, 18 Aug 2010 18:01:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTimxbJQ7+cJ20x1Bcm=1xk_JgMANUQDFn-pJ9jZa@mail.gmail.com>
References: <20100818151857.GA6188@barrios-desktop>
	<20100818172627.7e38969f@varda>
	<AANLkTimxbJQ7+cJ20x1Bcm=1xk_JgMANUQDFn-pJ9jZa@mail.gmail.com>
Date: Wed, 18 Aug 2010 18:01:58 -0700
Message-ID: <AANLkTimqzQHtSo5f41ze4JEznGCjMNTC_1DPgc21JYT0@mail.gmail.com>
Subject: Re: android-kernel memory reclaim x20 boost?
From: =?ISO-8859-1?Q?Arve_Hj=F8nnev=E5g?= <arve@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: =?ISO-8859-1?Q?Alejandro_Riveira_Fern=E1ndez?= <ariveira@gmail.com>, swetland@google.com, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, San Mehat <san@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 18, 2010 at 5:54 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Thu, Aug 19, 2010 at 12:26 AM, Alejandro Riveira Fern=E1ndez
> <ariveira@gmail.com> wrote:
>> El Thu, 19 Aug 2010 00:18:57 +0900
>> Minchan Kim <minchan.kim@gmail.com> escribi=F3:
>>
>>> Hello Android forks,
>> [ ... ]
>>>
>>> I saw the advertisement phrase in this[1].
>>>
>>> "Kernel Memory Management Boost: Improved memory reclaim by up to 20x,
>>> which results in faster app switching and smoother performance
>>> on memory-constrained devices."
>>>
>>> But I can't find any code for it in android kernel git tree.
>>
>> =A0Maybe the enhancements are on the Dalvik VM (shooting in the dark her=
e)
>
> Thanks.
> Android guys! Could you confirm this?
>

It is more likely referring to this change:

Author: San Mehat <san@google.com>
Date:   Wed May 5 11:38:42 2010 -0700

    staging: android: lowmemkiller: Substantially reduce overhead during re=
claim

    This patch optimizes lowmemkiller to not do any work when it has
an outstanding
    kill-request. This greatly reduces the pressure on the task_list lock
    (improving interactivity), as well as improving the vmscan performance
    when under heavy memory pressure (by up to 20x in tests).

    Note: For this enhancement to work, you need CONFIG_PROFILING

    Signed-off-by: San Mehat <san@google.com>


--=20
Arve Hj=F8nnev=E5g

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
