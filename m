Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 573406B024D
	for <linux-mm@kvack.org>; Sun, 25 Jul 2010 18:22:47 -0400 (EDT)
Received: by iwn2 with SMTP id 2so2671996iwn.14
        for <linux-mm@kvack.org>; Sun, 25 Jul 2010 15:22:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTimtN9PuvwrB2PAUZMajWzg=TbEP1jeseVM3MST3@mail.gmail.com>
References: <1280066561-8543-1-git-send-email-minchan.kim@gmail.com>
	<AANLkTimtN9PuvwrB2PAUZMajWzg=TbEP1jeseVM3MST3@mail.gmail.com>
Date: Mon, 26 Jul 2010 07:22:45 +0900
Message-ID: <AANLkTi=Vy0dUSsLmqV8Hwd9TT_m+CAMaVUV+ATOVFJFg@mail.gmail.com>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v3
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, Kukjin Kim <kgene.kim@samsung.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Russell King <linux@arm.linux.org.uk>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 26, 2010 at 2:03 AM, Balbir Singh <balbir@linux.vnet.ibm.com> w=
rote:
> On Sun, Jul 25, 2010 at 7:32 PM, Minchan Kim <minchan.kim@gmail.com> wrot=
e:
>> Changelog since v2
>> =A0o Change some function names
>> =A0o Remove mark_memmap_hole in memmap bring up
>> =A0o Change CONFIG_SPARSEMEM with CONFIG_ARCH_HAS_HOLES_MEMORYMODEL
>>
>> I have a plan following as after this patch is acked.
>>
>> TODO:
>> 1) expand pfn_valid to FALTMEM in ARM
>> I think we can enhance pfn_valid of FLATMEM in ARM.
>> Now it is doing binary search and it's expesive.
>> First of all, After we merge this patch, I expand it to FALTMEM of ARM.
>>
>> 2) remove memmap_valid_within
>> We can remove memmap_valid_within by strict pfn_valid's tight check.
>>
>> 3) Optimize hole check in sparsemem
>> In case of spasemem, we can optimize pfn_valid through defining new flag
>> like SECTION_HAS_HOLE of hole mem_section.
>>
>
> Is there an assumption somewhere that assumes that page->private will
> always have MEMMAP_HOLE set when the pfn is invalid, independent of
> the context in which it is invoked? BTW, I'd also recommend moving

zzzzz.... I needed sleep.
Will fix and resend.

> over to using set_page_private() and page_private() wrappers (makes
> the code easier to search)

Okay.
Thanks for pointing me out, Balbir.

>
> Balbir
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
