Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 97C526008D8
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 02:52:40 -0400 (EDT)
Received: by ywo7 with SMTP id 7so3100701ywo.14
        for <linux-mm@kvack.org>; Mon, 23 Aug 2010 23:52:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <8E31CE28A1354C43BBAD0BDEFA10494E@rainbow>
References: <20100818154130.GC9431@localhost>
	<565A4EE71DAC4B1A820B2748F56ABF73@rainbow>
	<20100819160006.GG6805@barrios-desktop>
	<AA3F2D89535A431DB91FE3032EDCB9EA@rainbow>
	<20100820053447.GA13406@localhost>
	<20100820093558.GG19797@csn.ul.ie>
	<AANLkTimVmoomDjGMCfKvNrS+v-mMnfeq6JDZzx7fjZi+@mail.gmail.com>
	<20100822153121.GA29389@barrios-desktop>
	<20100822232316.GA339@localhost>
	<20100823171416.GA2216@barrios-desktop>
	<20100824002753.GB6568@localhost>
	<8E31CE28A1354C43BBAD0BDEFA10494E@rainbow>
Date: Tue, 24 Aug 2010 15:52:37 +0900
Message-ID: <AANLkTikTu3jx5WyYEDZY2mk99V+w7kxL5k7xJDS+QZ+m@mail.gmail.com>
Subject: Re: compaction: trying to understand the code
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Iram Shahzad <iram.shahzad@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 24, 2010 at 2:07 PM, Iram Shahzad
<iram.shahzad@jp.fujitsu.com> wrote:
>> One question is, why kswapd won't proceed after isolating all the pages?
>> If it has done with the isolated pages, we'll see growing inactive_anon
>> numbers.
>>
>> /proc/vmstat should give more clues on any possible page reclaim
>> activities. Iram, would you help post it?
>
> I am not sure which point of time are you interested in, so I am
> attaching /proc/vmstat log of 3 points.
>
> too_many_isolated_vmstat_before_frag.txt
> =A0This one is taken before I ran my test app which attempts
> =A0to make fragmentation
> too_many_isolated_vmstat_before_compaction.txt
> =A0This one is taken after running the test app and before
> =A0running compaction.
> too_many_isolated_vmstat_during_compaction.txt
> =A0This one is taken a few minutes after running compaction.
> =A0To take this I ran compaction in background.
>
> Thanks
> Iram
>

Hmm.. Never happens reclaim. Strange.
In addtion, pgpgin is always 4.

pgpgin 4
pgpgout 0

Is it possible?
What kinds of filesystem do you use?
Do you boot from NFS?
Do your system have any non-mainline(ie, doesn't merged into linux
kernel tree) driver, file system or any feature?

Maybe your config file can answer this questions.
Thanks.
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
