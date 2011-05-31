Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 14A436B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 23:19:04 -0400 (EDT)
Received: by yib18 with SMTP id 18so2032566yib.14
        for <linux-mm@kvack.org>; Mon, 30 May 2011 20:19:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DE45119.9040108@jp.fujitsu.com>
References: <1306774744.4061.5.camel@localhost.localdomain>
	<4DE45119.9040108@jp.fujitsu.com>
Date: Tue, 31 May 2011 09:19:03 +0600
Message-ID: <BANLkTinX0+i=QS_0uL8R-b=-TgzAYEtcEA@mail.gmail.com>
Subject: Re: [PATCH] mm, vmstat: Use cond_resched only when !CONFIG_PREEMPT
From: Rakib Mullick <rakib.mullick@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie

On Tue, May 31, 2011 at 8:23 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> diff --git a/mm/vmstat.c b/mm/vmstat.c
>> index 20c18b7..72cf857 100644
>> --- a/mm/vmstat.c
>> +++ b/mm/vmstat.c
>> @@ -461,7 +461,11 @@ void refresh_cpu_vm_stats(int cpu)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p->expire =
=3D 3;
>> =A0#endif
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>> +#ifndef CONFIG_PREEMPT
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 cond_resched();
>> +#endif
>> +
>
> In general, we should avoid #ifdef CONFIG_PREEMPT for maintainancebility =
as far as possible.
> Is there any observable benefit? Can you please demonstrate it?
>
On my system I'm not sure whether it shows demonstratable benefit or
not. Although, I try. It will be helpful if you give me a hint about
how to measure its benefit.

Thanks,
Rakib
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
