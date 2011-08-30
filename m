Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1754D900137
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 01:19:26 -0400 (EDT)
Received: by vwm42 with SMTP id 42so6925646vwm.14
        for <linux-mm@kvack.org>; Mon, 29 Aug 2011 22:19:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJ8eaTz_zYYwG5HqTgU4=mbPwh=4rT9L-awJ-zO5QTsmP+GjOQ@mail.gmail.com>
References: <CAJ8eaTyeQj5_EAsCFDMmDs3faiVptuccmq3VJLjG-QnYG038=A@mail.gmail.com>
	<CAJ8eaTw=dKUNE8h-HD7RWxXHcTEuxJH4AfcOO44RSF7QdC5arQ@mail.gmail.com>
	<CAHKQLBH2d-DzzMfP9QOUmz6brT7BfPdwY6JfEUUYxzaTDTo=wg@mail.gmail.com>
	<CAJ8eaTxmZm6yw1YWhdfaxwuf0mF+sOfX6RUPfcu-qiHYu+D4CA@mail.gmail.com>
	<CAJ8eaTz_zYYwG5HqTgU4=mbPwh=4rT9L-awJ-zO5QTsmP+GjOQ@mail.gmail.com>
Date: Tue, 30 Aug 2011 10:49:25 +0530
Message-ID: <CAFPAmTQoVt+rg+2KHuu-Pi3t_RCx-14xFeMOamguMQMZFV==Jg@mail.gmail.com>
Subject: Re: Kernel panic in 2.6.35.12 kernel
From: Kautuk Consul <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: naveen yadav <yad.naveen@gmail.com>
Cc: Steve Chen <schen@mvista.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

Hi Steve,

I too have noticed this strange behaviour on my Linux ARM board.

I also have 2.6.35.12 installed and I see a similar crash when
parallel OOMs are triggerred.

I am executing multiple instances of a similar test application which
allocates a lot of anonymous memory.
OOM then starts kicking in parallel and this eventualy results in a
hang situation.

Can anyone tell me what patch to apply to solve this problem ?

Thanks,
Kautuk.


On Tue, Aug 30, 2011 at 10:12 AM, naveen yadav <yad.naveen@gmail.com> wrote=
:
> ---------- Forwarded message ----------
> From: naveen yadav <yad.naveen@gmail.com>
> Date: Fri, Aug 26, 2011 at 10:38 AM
> Subject: Re: Kernel panic in 2.6.35.12 kernel
> To: Steve Chen <schen@mvista.com>
> Cc: linux-arm-kernel@lists.infradead.org, linux-mm <linux-mm@kvack.org>
>
>
> Hi Steve.
>
> Pls find attached code for stress application. The test code is very
> simple. Just alloc memory.
> we got this issue on embedded Target.
> After analysis we found that most of task(stress_application) is in D
> for uninterruptible sleep.
> application =A0 =A0 =A0 =A0 =A0 state
>
> stress =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x
> stress =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0D
> stress =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x
> stress =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0D
> stress =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x
> stress =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0D
> stress =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x
> sleep =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 D
>
> Thanks
>
>
>
>
> On Thu, Aug 25, 2011 at 7:27 PM, Steve Chen <schen@mvista.com> wrote:
>> On Thu, Aug 25, 2011 at 1:06 AM, naveen yadav <yad.naveen@gmail.com> wro=
te:
>>> I am paste only small crash log due to size problem.
>>>
>>>
>>>
>>>
>>>> Hi All,
>>>>
>>>> We are running one malloc testprogram using below script.
>>>>
>>>> while true
>>>> do
>>>> ./stress &
>>>> sleep 1
>>>> done
>>>>
>>>>
>>>>
>>>>
>>>> After 10-15 min we observe following crash in kernel
>>>>
>>>>
>>>> =A0Kernel panic - not syncing: Out of memory and no killable processes=
...
>>>>
>>>> attaching log also.
>>>>
>>>> Thanks
>>>>
>>>
>>> _______________________________________________
>>> linux-arm-kernel mailing list
>>> linux-arm-kernel@lists.infradead.org
>>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>>>
>>>
>>
>> Can you share the code in ./stress?
>>
>> Thanks,
>>
>> Steve
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
