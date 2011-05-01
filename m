Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D7963900113
	for <linux-mm@kvack.org>; Sun,  1 May 2011 11:10:13 -0400 (EDT)
Received: by qyk2 with SMTP id 2so1154960qyk.14
        for <linux-mm@kvack.org>; Sun, 01 May 2011 08:10:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110501221459.75E4.A69D9226@jp.fujitsu.com>
References: <BANLkTik2FTKgSSYkyP4XT4pkhOYvpjgSTA@mail.gmail.com>
	<20110428084500.GG12437@cmpxchg.org>
	<20110501221459.75E4.A69D9226@jp.fujitsu.com>
Date: Mon, 2 May 2011 00:10:12 +0900
Message-ID: <BANLkTikr+nW=9a9B=HN9PBir=cpKjXnwLA@mail.gmail.com>
Subject: Re: [RFC 4/8] Make clear description of putback_lru_page
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Sun, May 1, 2011 at 10:13 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Thu, Apr 28, 2011 at 08:20:32AM +0900, Minchan Kim wrote:
>> > On Wed, Apr 27, 2011 at 5:11 PM, KAMEZAWA Hiroyuki
>> > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > > On Wed, 27 Apr 2011 01:25:21 +0900
>> > > Minchan Kim <minchan.kim@gmail.com> wrote:
>> > >
>> > >> Commonly, putback_lru_page is used with isolated_lru_page.
>> > >> The isolated_lru_page picks the page in middle of LRU and
>> > >> putback_lru_page insert the lru in head of LRU.
>> > >> It means it could make LRU churning so we have to be very careful.
>> > >> Let's clear description of putback_lru_page.
>> > >>
>> > >> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> > >> Cc: Mel Gorman <mgorman@suse.de>
>> > >> Cc: Rik van Riel <riel@redhat.com>
>> > >> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> > >> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> > >
>> > > seems good...
>> > > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> > >
>> > > But is there consensus which side of LRU is tail? head?
>> >
>> > I don't know. I used to think it's head.
>> > If other guys raise a concern as well, let's talk about it. :)
>> > Thanks
>>
>> I suppose we add new pages to the head of the LRU and reclaim old
>> pages from the tail.
>>
>> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
>
> So, It would be better if isolate_lru_page() also have "LRU tail blah bla=
h blah"
> comments.

Okay. I will try it.

>
> anyway,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@=
jp.fujitsu.com>
>

Thanks.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
