Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E81366B0096
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 22:43:53 -0500 (EST)
Received: by pxi2 with SMTP id 2so191043pxi.11
        for <linux-mm@kvack.org>; Thu, 10 Dec 2009 19:43:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B21BA54.1090103@redhat.com>
References: <20091210185626.26f9828a@cuia.bos.redhat.com>
	 <28c262360912101803i7b43db78se8cf9ec61d92ee0f@mail.gmail.com>
	 <4B21BA54.1090103@redhat.com>
Date: Fri, 11 Dec 2009 12:43:50 +0900
Message-ID: <28c262360912101943l49580d9chb19a00af246f5adb@mail.gmail.com>
Subject: Re: [PATCH] vmscan: limit concurrent reclaimers in shrink_zone
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: lwoodman@redhat.com, kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, Dec 11, 2009 at 12:19 PM, Rik van Riel <riel@redhat.com> wrote:
> On 12/10/2009 09:03 PM, Minchan Kim wrote:
>
>>> +The default value is 8.
>>> +
>>> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>
>> I like this. but why do you select default value as constant 8?
>> Do you have any reason?
>>
>> I think it would be better to select the number proportional to NR_CPU.
>> ex) NR_CPU * 2 or something.
>>
>> Otherwise looks good to me.
>
> Pessimistically, I assume that the pageout code spends maybe
> 10% of its time on locking (we have seen far, far worse than
> this with thousands of processes in the pageout code). =C2=A0That
> means if we have more than 10 threads in the pageout code,
> we could end up spending more time on locking and less doing
> real work - slowing everybody down.

Thanks for giving precious information to me. :

We always have a question magic value with no comment.

Actually I don't want to add another magic value without comment.
so I would like to add the your good explanation in change log
or as comment on code.

>
> I rounded it down to the closest power of 2 to come up with
> an arbitrary number that looked safe :)
>
> However, this number is per zone - I imagine that really large
> systems will have multiple memory zones, so they can run with
> more than 8 processes in the pageout code simultaneously.
>
>> Reviewed-by: Minchan Kim<minchan.kim@gmail.com>
>
> Thank you.

Thanks for quick reply. :)

> --
> All rights reversed.
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
