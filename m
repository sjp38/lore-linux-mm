Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 35BF46B004F
	for <linux-mm@kvack.org>; Fri,  6 Jan 2012 01:18:24 -0500 (EST)
Received: by yenq10 with SMTP id q10so640963yen.14
        for <linux-mm@kvack.org>; Thu, 05 Jan 2012 22:18:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F069120.8060300@tao.ma>
References: <1325226961-4271-1-git-send-email-tm@tao.ma> <CAHGf_=qOGy3MQgiFyfeG82+gbDXTBT5KQjgR7JqMfQ7e7RSGpA@mail.gmail.com>
 <4EFD7AE3.8020403@tao.ma> <CAHGf_=pODc6fLGJAEZWzQtUd6fj6v=fV9n6UTwysqRR1SwY++A@mail.gmail.com>
 <4EFD8832.6010905@tao.ma> <CAHGf_=qA3Pnb00n_smhJVKDDCDDr0d-a3E03Rrhnb-S4xK8_fQ@mail.gmail.com>
 <4F069120.8060300@tao.ma>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 6 Jan 2012 01:18:02 -0500
Message-ID: <CAHGf_=qhKbVCeUe+y8Hmb=ke-f417K5EYFo=j4ZODVGwewgh6A@mail.gmail.com>
Subject: Re: [PATCH] mm: do not drain pagevecs for mlock
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tao Ma <tm@tao.ma>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

2012/1/6 Tao Ma <tm@tao.ma>:
> Hi Kosaki,
> On 12/30/2011 06:07 PM, KOSAKI Motohiro wrote:
>>>> Because your test program is too artificial. 20sec/100000times =
>>>> 200usec. And your
>>>> program repeat mlock and munlock the exact same address. so, yes, if
>>>> lru_add_drain_all() is removed, it become near no-op. but it's
>>>> worthless comparision.
>>>> none of any practical program does such strange mlock usage.
>>> yes, I should say it is artificial. But mlock did cause the problem in
>>> our product system and perf shows that the mlock uses the system time
>>> much more than others. That's the reason we created this program to test
>>> whether mlock really sucks. And we compared the result with
>>> rhel5(2.6.18) which runs much much faster.
>>>
>>> And from the commit log you described, we can remove lru_add_drain_all
>>> safely here, so why add it? At least removing it makes mlock much faster
>>> compared to the vanilla kernel.
>>
>> If we remove it, we lose to a test way of mlock. "Memlocked" field of
>> /proc/meminfo
>> show inaccurate number very easily. So, if 200usec is no avoidable,
>> I'll ack you.
>> But I'm not convinced yet.
> Do you find something new for this?

No.

Or more exactly, 200usec is my calculation mistake. your program call mlock
3 times per each iteration. so, correct cost is 66usec.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
