Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3519D600365
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 06:01:16 -0400 (EDT)
Received: by iwn2 with SMTP id 2so4336252iwn.14
        for <linux-mm@kvack.org>; Tue, 27 Jul 2010 03:01:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100727171351.98d5fb60.kamezawa.hiroyu@jp.fujitsu.com>
References: <1280159163-23386-1-git-send-email-minchan.kim@gmail.com>
	<alpine.DEB.2.00.1007261136160.5438@router.home>
	<pfn.valid.v4.reply.1@mdm.bga.com>
	<AANLkTimtTVvorrR9pDVTyPKj0HbYOYY3aR7B-QWGhTei@mail.gmail.com>
	<pfn.valid.v4.reply.2@mdm.bga.com>
	<20100727171351.98d5fb60.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 27 Jul 2010 19:01:14 +0900
Message-ID: <AANLkTikCsGHshU8v86SQiuO+UZBCbdjOKN=GyJFPb7rY@mail.gmail.com>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Milton Miller <miltonm@bga.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

Hi, Kame.

On Tue, Jul 27, 2010 at 5:13 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com>
>> Perhaps the mem_section array. =A0Using a symbol that is part of
>> the model pre-checks can remove a global symbol lookup and has the side
>> effect of making sure our pfn_valid is for the right model.
>>
>
> But yes, maybe it's good to make use of a fixed-(magic)-value.

fixed-magic-value?
Yes. It can be good for some debugging.
But as Christoph pointed out, we need some strict check(ex,
PG_reserved) for preventing unlucky valid using of magic value in
future.
But in fact I have a concern to use PG_reserved since it can be used
afterward pfn_valid normally to check hole in non-hole system. So I
think it's redundant.

Hmm..

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
