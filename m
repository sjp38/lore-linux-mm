Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EC9CE6B004F
	for <linux-mm@kvack.org>; Sat, 29 Aug 2009 11:32:37 -0400 (EDT)
Received: by ywh33 with SMTP id 33so4093835ywh.18
        for <linux-mm@kvack.org>; Sat, 29 Aug 2009 08:32:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090829122217.GA17448@cmpxchg.org>
References: <Pine.LNX.4.64.0908282034240.19475@sister.anvils>
	 <2f11576a0908290300h155596e1y730c355ade7a671e@mail.gmail.com>
	 <20090829122217.GA17448@cmpxchg.org>
Date: Sun, 30 Aug 2009 00:32:36 +0900
Message-ID: <2f11576a0908290832l7ec0c88dl14431e8a2e1d1189@mail.gmail.com>
Subject: Re: [PATCH mmotm] vmscan move pgdeactivate modification to
	shrink_active_list fix
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2009/8/29 Johannes Weiner <hannes@cmpxchg.org>:
> On Sat, Aug 29, 2009 at 07:00:47PM +0900, KOSAKI Motohiro wrote:
>> Hi Hugh
>>
>> 2009/8/29 Hugh Dickins <hugh.dickins@tiscali.co.uk>:
>> > mmotm 2009-08-27-16-51 lets the OOM killer loose on my loads even
>> > quicker than last time: one bug fixed but another bug introduced.
>> > vmscan-move-pgdeactivate-modification-to-shrink_active_list.patch
>> > forgot to add NR_LRU_BASE to lru index to make zone_page_state index.
>> >
>> > Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
>>
>> Can I use your test case?
>> Currently LRU_BASE is 0. it mean
>>
>> LRU_BASE =3D=3D NR_INACTIVE_ANON =3D=3D 0
>> LRU_ACTIVE =3D=3D NR_ACTIVE_ANON =3D=3D 1
>
> The zone counters are
>
> =A0 =A0 =A0 =A0NR_FREE_PAGES =3D 0
> =A0 =A0 =A0 =A0NR_INACTIVE_ANON =3D NR_LRU_BASE =3D 1
> =A0 =A0 =A0 =A0NR_ACTIVE_ANON =3D 2
> =A0 =A0 =A0 =A0...,
>
> and NR_LRU_BASE is the offset of the LRU items within the zone stat
> items. =A0You missed this offset, so accounting to LRU_BASE + 0 *
> LRU_FILE actually accounts to NR_FREE_PAGES, not to NR_INACTIVE_ANON.

/me slapt self. thank you correct me ;)


> I get the feeling we should make this thing more robust...

I agree your perfectly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
