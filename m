Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 35070900001
	for <linux-mm@kvack.org>; Sun,  8 May 2011 04:21:23 -0400 (EDT)
Received: by wyf19 with SMTP id 19so4360069wyf.14
        for <linux-mm@kvack.org>; Sun, 08 May 2011 01:21:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1105061547150.2451@chino.kir.corp.google.com>
References: <BANLkTi=S_gSvnQimgqrMmq9eWJYDCDRVmA@mail.gmail.com>
	<alpine.DEB.2.00.1105061547150.2451@chino.kir.corp.google.com>
Date: Sun, 8 May 2011 16:21:20 +0800
Message-ID: <BANLkTi=WORnf0PrQZQ79ZpqFv2NaC-dPUg@mail.gmail.com>
Subject: Re: [Question] how to detect mm leaker and kill?
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Yong Zhang <yong.zhang0@gmail.com>

On Sat, May 7, 2011 at 6:48 AM, David Rientjes <rientjes@google.com> wrote:
> On Fri, 6 May 2011, Hillf Danton wrote:
>
>> Hi
>>
>> In the scenario that 2GB =C2=A0physical RAM is available, and there is a
>> database application that eats 1.4GB RAM without leakage already
>> running, another leaker who leaks 4KB an hour is also running, could
>> the leaker be detected and killed in mm/oom_kill.c with default
>> configure when oom happens?
>>
>
> Yes, if you know the database application is going to use 70% of your
> system RAM and you wish to discount that from its memory use when being
> considered for oom kill, set its /proc/pid/oom_score_adj to -700.
>
> This is only possible on 2.6.36 and later kernels when oom_score_adj was
> introduced.
>
> If you'd like to completely disable oom killing, set
> /proc/pid/oom_score_adj to -1000.
>

Thank you very much, David, for cool answer to my question.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
