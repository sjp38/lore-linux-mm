Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4A78B8D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 22:40:48 -0400 (EDT)
Received: by iyf13 with SMTP id 13so224701iyf.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:40:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110314192834.8ffeda55.akpm@linux-foundation.org>
References: <1299735019.2337.63.camel@sli10-conroe>
	<20110314144540.GC11699@barrios-desktop>
	<1300154014.2337.74.camel@sli10-conroe>
	<AANLkTin2h0YFe70vYj7cExAJbbPS+oDjvfunfGPNZfB1@mail.gmail.com>
	<20110314192834.8ffeda55.akpm@linux-foundation.org>
Date: Tue, 15 Mar 2011 11:40:46 +0900
Message-ID: <AANLkTimWH34vcJsykrtDq1Tb8W5qt+Os_FUtQO3+1qBX@mail.gmail.com>
Subject: Re: [PATCH 2/2 v4]mm: batch activate_page() to reduce lock contention
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shaohua.li@intel.com>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Mar 15, 2011 at 11:28 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 15 Mar 2011 11:12:37 +0900 Minchan Kim <minchan.kim@gmail.com> wr=
ote:
>
>> >> I can't understand why we should hanlde activate_page_pvecs specially=
.
>> >> Please, enlighten me.
>> > Not it's special. akpm asked me to do it this time. Reducing little
>> > memory is still worthy anyway, so that's it. We can do it for other
>> > pvecs too, in separate patch.
>>
>> Understandable but I don't like code separation by CONFIG_SMP for just
>> little bit enhance of memory usage. In future, whenever we use percpu,
>> do we have to implement each functions for both SMP and non-SMP?
>> Is it desirable?
>> Andrew, Is it really valuable?
>
> It's a little saving of text footprint. =C2=A0It's also probably faster t=
his way -
> putting all the pages into a pagevec then later processing them won't
> be very L1 cache friendly.
>
>

I am not sure how much effective it is in UP. But if L1 cache friendly
is important concern, we should not use per-cpu about hot operation.
I think more important thing in embedded (normal UP), it is a lock latency.
I don't want to hold/release the lock per page.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
