Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 662808D0047
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 01:58:31 -0500 (EST)
Received: by iwl42 with SMTP id 42so1723562iwl.14
        for <linux-mm@kvack.org>; Wed, 09 Mar 2011 22:58:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110309143704.194e8ee1.kamezawa.hiroyu@jp.fujitsu.com>
References: <1299325456-2687-1-git-send-email-avagin@openvz.org>
	<20110305152056.GA1918@barrios-desktop>
	<4D72580D.4000208@gmail.com>
	<20110305155316.GB1918@barrios-desktop>
	<4D7267B6.6020406@gmail.com>
	<20110305170759.GC1918@barrios-desktop>
	<20110307135831.9e0d7eaa.akpm@linux-foundation.org>
	<AANLkTinDhorLusBju=Gn3bh1VsH1jrv0qixbU3SGWiqa@mail.gmail.com>
	<20110309143704.194e8ee1.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 10 Mar 2011 15:58:29 +0900
Message-ID: <AANLkTi=q=YMrT7Uta+wGm47VZ5N6meybAQTgjKGsDWFw@mail.gmail.com>
Subject: Re: [PATCH] mm: check zone->all_unreclaimable in all_unreclaimable()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrew Vagin <avagin@gmail.com>, Andrey Vagin <avagin@openvz.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Kame,

Sorry for late response.
I had a time to test this issue shortly because these day I am very busy.
This issue was interesting to me.
So I hope taking a time for enough testing when I have a time.
I should find out root cause of livelock.

I will answer your comment after it. :)
Thanks!

On Wed, Mar 9, 2011 at 2:37 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 8 Mar 2011 08:45:51 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> On Tue, Mar 8, 2011 at 6:58 AM, Andrew Morton <akpm@linux-foundation.org=
> wrote:
>> > On Sun, 6 Mar 2011 02:07:59 +0900
>> > Minchan Kim <minchan.kim@gmail.com> wrote:
>> > Any alternative proposals? =C2=A0We should get the livelock fixed if p=
ossible..
>> >
>>
>> And we should avoid unnecessary OOM kill if possible.
>>
>> I think the problem is caused by (zone->pages_scanned <
>> zone_reclaimable_pages(zone) * 6). I am not sure (* 6) is a best. It
>> would be rather big on recent big DRAM machines.
>>
>
> It means 3 times full-scan from the highest priority to the lowest
> and cannot freed any pages. I think big memory machine tend to have
> more cpus, so don't think it's big.
>
>> I think it is a trade-off between latency and OOM kill.
>> If we decrease the magic value, maybe we should prevent the almost
>> livelock but happens unnecessary OOM kill.
>>
>
> Hmm, should I support a sacrifice feature 'some signal(SIGINT?) will be s=
ent by
> the kernel when it detects system memory is in short' in cgroup ?
> (For example, if full LRU scan is done in a zone, notifier
> =C2=A0works and SIGINT will be sent.)
>
>> And I think zone_reclaimable not fair.
>> For example, too many scanning makes reclaimable state to
>> unreclaimable state. Maybe it takes a very long time. But just some
>> page free makes unreclaimable state to reclaimabe with very easy. So
>> we need much painful reclaiming for changing reclaimable state with
>> unreclaimabe state. it would affect latency very much.
>>
>> Maybe we need more smart zone_reclaimabe which is adaptive with memory p=
ressure.
>>
> I agree.
>
> Thanks,
> -Kame
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
