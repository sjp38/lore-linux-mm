Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4458C6B0204
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 20:33:25 -0400 (EDT)
Received: by gxk10 with SMTP id 10so2110427gxk.10
        for <linux-mm@kvack.org>; Tue, 13 Apr 2010 17:33:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100414092209.4327e545.kamezawa.hiroyu@jp.fujitsu.com>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
	 <2cb77846a9523201588c5dbf94b23d6ea737ce65.1271171877.git.minchan.kim@gmail.com>
	 <20100414092209.4327e545.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 14 Apr 2010 09:33:22 +0900
Message-ID: <j2p28c262361004131733m98351a5xf994ead1f21289ef@mail.gmail.com>
Subject: Re: [PATCH 5/6] change alloc function in __vmalloc_area_node
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 9:22 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 14 Apr 2010 00:25:02 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> __vmalloc_area_node never pass -1 to alloc_pages_node.
>> It means node's validity check is unnecessary.
>> So we can use alloc_pages_exact_node instead of alloc_pages_node.
>> It could avoid comparison and branch as 6484eb3e2a81807722 tried.
>>
>> Cc: Nick Piggin <npiggin@suse.de>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> But, in another thinking,
>
> - =C2=A0 =C2=A0 =C2=A0 if (node < 0)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D alloc_page(gf=
p_mask);
>
> may be better ;)

I thought it.
but alloc_page is different function with alloc_pages_node in NUMA.
It calls alloc_pages_current.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
