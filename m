Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 645B16B01AC
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 02:38:15 -0400 (EDT)
Received: by iwn2 with SMTP id 2so5425725iwn.14
        for <linux-mm@kvack.org>; Mon, 05 Jul 2010 23:38:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100706150030.CCFA.A69D9226@jp.fujitsu.com>
References: <20100706093529.CCD1.A69D9226@jp.fujitsu.com>
	<AANLkTimk6SwmljTWpIgp_OI_eLP6w8BCWKf-VRUFQ65H@mail.gmail.com>
	<20100706150030.CCFA.A69D9226@jp.fujitsu.com>
Date: Tue, 6 Jul 2010 15:38:09 +0900
Message-ID: <AANLkTimXqmTi9nM8Z10IwU68XTJmrbrie-oxzke8BD40@mail.gmail.com>
Subject: Re: [PATCH 12/14] vmscan: Do not writeback pages in direct reclaim
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 6, 2010 at 3:02 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Tue, Jul 6, 2010 at 9:36 AM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> > Hello,
>> >
>> >> Ok, that's reasonable as I'm still working on that patch. For example=
, the
>> >> patch disabled anonymous page writeback which is unnecessary as the s=
tack
>> >> usage for anon writeback is less than file writeback.
>> >
>> > How do we examine swap-on-file?
>>
>> bool is_swap_on_file(struct page *page)
>> {
>> =C2=A0 =C2=A0 struct swap_info_struct *p;
>> =C2=A0 =C2=A0 swp_entry_entry entry;
>> =C2=A0 =C2=A0 entry.val =3D page_private(page);
>> =C2=A0 =C2=A0 p =3D swap_info_get(entry);
>> =C2=A0 =C2=A0 return !(p->flags & SWP_BLKDEV)
>> }
>
> Well, do you suggested we traverse all pages in lru _before_
> starting vmscan?
>

No. I don't suggest anything.
What I say is just we can do it.
If we have to implement it, Couldn't we do it in write_reclaim_page?



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
