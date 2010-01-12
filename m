Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D23986B007B
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 23:48:37 -0500 (EST)
Received: by pzk34 with SMTP id 34so14162644pzk.11
        for <linux-mm@kvack.org>; Mon, 11 Jan 2010 20:48:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100112042116.GA26035@localhost>
References: <1263184634-15447-4-git-send-email-shijie8@gmail.com>
	 <1263191277-30373-1-git-send-email-shijie8@gmail.com>
	 <20100111153802.f3150117.minchan.kim@barrios-desktop>
	 <20100112094708.d09b01ea.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100112022708.GA21621@localhost>
	 <28c262361001112005s745e5ecj9fd6ae3d0d997477@mail.gmail.com>
	 <20100112042116.GA26035@localhost>
Date: Tue, 12 Jan 2010 13:48:36 +0900
Message-ID: <28c262361001112048n5e03670fx68dbc94209dbf3db@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm/page_alloc : relieve zone->lock's pressure for
	memory free
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Huang Shijie <shijie8@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 12, 2010 at 1:21 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
>> Hmm. It's not atomic as Kame pointed out.
>>
>> Now, zone->flags have several bit.
>> =C2=A0* ZONE_ALL_UNRECLAIMALBE
>> =C2=A0* ZONE_RECLAIM_LOCKED
>> =C2=A0* ZONE_OOM_LOCKED.
>>
>> I think this flags are likely to race when the memory pressure is high.
>> If we don't prevent race, concurrent reclaim and killing could be happen=
ed.
>> So I think reset zone->flags outside of zone->lock would make our effort=
s which
>> prevent current reclaim and killing invalidate.
>
> zone_set_flag()/zone_clear_flag() calls set_bit()/clear_bit() which is
> atomic. Do you mean more high level exclusion?

No. I was wrong. I though it's not atomic operation.
I confused it with __set_bit. :)
Sorry for the noise.
Thanks, Wu. :)




--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
