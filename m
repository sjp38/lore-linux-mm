Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B561E8D0030
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 09:11:04 -0400 (EDT)
Received: by iwn38 with SMTP id 38so2834827iwn.14
        for <linux-mm@kvack.org>; Fri, 29 Oct 2010 06:11:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101029103154.GA10823@gargoyle.fritz.box>
References: <20101026190042.57f30338.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTim4fFXQKqmFCeR8pvi0SZPXpjDqyOkbV6PYJYkR@mail.gmail.com>
	<op.vlbywq137p4s8u@pikus>
	<20101029103154.GA10823@gargoyle.fritz.box>
Date: Fri, 29 Oct 2010 22:11:03 +0900
Message-ID: <AANLkTin2Q-qQSnzc9sZnP_inf+5SEgG5cXYA8f-0goYG@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/3] big chunk memory allocator v2
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi.kleen@intel.com>
Cc: =?ISO-8859-2?Q?Micha=B3_Nazarewicz?= <m.nazarewicz@samsung.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "fujita.tomonori@lab.ntt.co.jp" <fujita.tomonori@lab.ntt.co.jp>, "felipe.contreras@gmail.com" <felipe.contreras@gmail.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Russell King <linux@arm.linux.org.uk>, Pawel Osciak <pawel@osciak.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

2010/10/29 Andi Kleen <andi.kleen@intel.com>:
>> When I was posting CMA, it had been suggested to create a new migration =
type
>> dedicated to contiguous allocations. =A0I think I already did that and t=
hanks to
>> this new migration type we have (i) an area of memory that only accepts =
movable
>> and reclaimable pages and
>
> Aka highmem next generation :-(

I lost the road. What is highmem next generation?
Could you point it to me?

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
