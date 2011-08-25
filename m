Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 400DC6B0169
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 02:38:17 -0400 (EDT)
Received: by bkbzt4 with SMTP id zt4so2050814bkb.14
        for <linux-mm@kvack.org>; Wed, 24 Aug 2011 23:38:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJ8eaTw=dKUNE8h-HD7RWxXHcTEuxJH4AfcOO44RSF7QdC5arQ@mail.gmail.com>
References: <CAJ8eaTyeQj5_EAsCFDMmDs3faiVptuccmq3VJLjG-QnYG038=A@mail.gmail.com>
	<CAJ8eaTw=dKUNE8h-HD7RWxXHcTEuxJH4AfcOO44RSF7QdC5arQ@mail.gmail.com>
Date: Thu, 25 Aug 2011 12:08:12 +0530
Message-ID: <CAJ8eaTyaiFzAnKB-P9EJT5UxxmpgTpw=Yk_Ee8qJUVKFjfHtKQ@mail.gmail.com>
Subject: Re: Kernel panic in 2.6.35.12 kernel
From: naveen yadav <yad.naveen@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm <linux-mm@kvack.org>

adding to mm mailing list

On Thu, Aug 25, 2011 at 11:36 AM, naveen yadav <yad.naveen@gmail.com> wrote=
:
> I am paste only small crash log due to size problem.
>
>
>
>
>> Hi All,
>>
>> We are running one malloc testprogram using below script.
>>
>> while true
>> do
>> ./stress &
>> sleep 1
>> done
>>
>>
>>
>>
>> After 10-15 min we observe following crash in kernel
>>
>>
>> =A0Kernel panic - not syncing: Out of memory and no killable processes..=
.
>>
>> attaching log also.
>>
>> Thanks
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
