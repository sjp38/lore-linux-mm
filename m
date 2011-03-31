Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CF4988D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 15:22:50 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p2VJMldP011683
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 12:22:47 -0700
Received: from qwb7 (qwb7.prod.google.com [10.241.193.71])
	by kpbe19.cbf.corp.google.com with ESMTP id p2VJMjjs027232
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 12:22:45 -0700
Received: by qwb7 with SMTP id 7so1926861qwb.26
        for <linux-mm@kvack.org>; Thu, 31 Mar 2011 12:22:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=_O6nSo=q3bgkhu01p6a-G8Gq_yQ@mail.gmail.com>
References: <20110331110113.a01f7b8b.kamezawa.hiroyu@jp.fujitsu.com>
	<4D944801.3020404@parallels.com>
	<20110331162050.GI12265@random.random>
	<BANLkTin4Zj9HLWy5xobBcP6WQFY1um1JzA@mail.gmail.com>
	<4D94CF4E.5000306@parallels.com>
	<BANLkTi=_O6nSo=q3bgkhu01p6a-G8Gq_yQ@mail.gmail.com>
Date: Thu, 31 Mar 2011 12:22:44 -0700
Message-ID: <BANLkTinqFuLkeSMPhnxHws7Ki9-H8MRDYA@mail.gmail.com>
Subject: Re: [Lsf] [LSF][MM] rough agenda for memcg.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "lsf@lists.linux-foundation.org" <lsf@lists.linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Suleiman Souhlal <suleiman@google.com>

On Thu, Mar 31, 2011 at 12:16 PM, Ying Han <yinghan@google.com> wrote:
> On Thu, Mar 31, 2011 at 12:00 PM, Pavel Emelyanov <xemul@parallels.com> w=
rote:
>>>>>> =A0 a) Kernel memory accounting.
>>>>>
>>>>> This one is very interesting to me.
>>>>
>>>> I expected someone would have been interested into that...
>>>
>>> We are definitely interested in that. We are testing the patch
>>> internally now on kernel slab accounting.
>>
>> I guess this patch sent to linux-mm, so can you give me an url?
>
> Pavel, I don't think we have patch sent out yet (under testing). But
> Suleiman (the author) has the
> proposal at http://permalink.gmane.org/gmane.linux.kernel.mm/58173
>
> Thanks
>
> --Ying
>>
>>> The author won't be in LSF,
>>> but I can help to present our approach in the session w/ Pavel. Also,
>>> I would like to talk a bit on the kernel memory reclaim for few
>>> minutes.
>>>
>>> --Ying
>>
>> Thanks,
>> Pavel
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
