Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 137656B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 00:12:27 -0500 (EST)
Received: by pxi11 with SMTP id 11so83796pxi.22
        for <linux-mm@kvack.org>; Wed, 13 Jan 2010 21:12:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100114084659.D713.A69D9226@jp.fujitsu.com>
References: <20100113171953.B3E5.A69D9226@jp.fujitsu.com>
	 <28c262361001130231k29b933der4022f4d1da80b084@mail.gmail.com>
	 <20100114084659.D713.A69D9226@jp.fujitsu.com>
Date: Thu, 14 Jan 2010 14:12:25 +0900
Message-ID: <28c262361001132112i7f50fd66qcd24dc2ddb4d78d8@mail.gmail.com>
Subject: Re: [PATCH 2/3][v2] vmstat: add anon_scan_ratio field to zoneinfo
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 14, 2010 at 8:50 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi
>
>> Hi, Kosaki.
>>
>> On Wed, Jan 13, 2010 at 5:21 PM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> > Changelog
>> > =C2=A0from v1
>> > =C2=A0- get_anon_scan_ratio don't tak zone->lru_lock anymore
>> > =C2=A0 because zoneinfo_show_print takes zone->lock.
>>
>> When I saw this changelog first, I got confused.
>> That's because there is no relation between lru_lock and lock in zone.
>> You mean zoneinfo is allowed to have a stale data?
>> Tend to agree with it.
>
> Well. zone->lock and zone->lru_lock should be not taked at the same time.

I looked over the code since I am out of office.
I can't find any locking problem zone->lock and zone->lru_lock.
Do you know any locking order problem?
Could you explain it with call graph if you don't mind?

I am out of office by tomorrow so I can't reply quickly.
Sorry for late reponse.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
