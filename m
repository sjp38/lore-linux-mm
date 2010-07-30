Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9CEE66B02A4
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 05:32:08 -0400 (EDT)
Received: by yxs7 with SMTP id 7so683271yxs.14
        for <linux-mm@kvack.org>; Fri, 30 Jul 2010 02:32:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1280436919.16922.11246.camel@nimitz>
References: <AANLkTinXmkaX38pLjSBCRUS-c84GqpUE7xJQFDDHDLCC@mail.gmail.com>
	<alpine.DEB.2.00.1007281005440.21717@router.home>
	<20100728155617.GA5401@barrios-desktop>
	<alpine.DEB.2.00.1007281158150.21717@router.home>
	<20100728225756.GA6108@barrios-desktop>
	<alpine.DEB.2.00.1007291038100.16510@router.home>
	<20100729161856.GA16420@barrios-desktop>
	<alpine.DEB.2.00.1007291132210.17734@router.home>
	<20100729170313.GB16420@barrios-desktop>
	<alpine.DEB.2.00.1007291222410.17734@router.home>
	<20100729183320.GH18923@n2100.arm.linux.org.uk>
	<1280436919.16922.11246.camel@nimitz>
Date: Fri, 30 Jul 2010 18:32:04 +0900
Message-ID: <AANLkTi=DpH=vmUK84KhvOMgP=KL+YxXD0UhiJE+VRJyg@mail.gmail.com>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 30, 2010 at 5:55 AM, Dave Hansen <dave@linux.vnet.ibm.com> wrot=
e:
> On Thu, 2010-07-29 at 19:33 +0100, Russell King - ARM Linux wrote:
>> And no, setting the sparse section size to 512kB doesn't work - memory i=
s
>> offset by 256MB already, so you need a sparsemem section array of 1024
>> entries just to cover that - with the full 256MB populated, that's 512
>> unused entries followed by 512 used entries. =A0That too is going to was=
te
>> memory like nobodies business.
>
> Sparsemem could use some work in the case where memory doesn't start at
> 0x0. =A0But, it doesn't seem like it would be _too_ oppressive to add.
> It's literally just adding an offset to all of the places where a
> physical address is stuck into the system. =A0It'll make a few of the
> calculations longer, of course, but it should be manageable.
>
> Could you give some full examples of how the memory is laid out on these
> systems? =A0I'm having a bit of a hard time visualizing it.
>
> As Christoph mentioned, SPARSEMEM_EXTREME might be viable here, too.
>
> If you free up parts of the mem_map[] array, how does the buddy
> allocator still work? =A0I thought we required at 'struct page's to be
> contiguous and present for at least 2^MAX_ORDER-1 pages in one go.

I think in that case, arch should define CONFIG_HOLES_IN_ZONE to prevent
crash. But I am not sure hole architectures on ARM have been used it well.
Kujkin's problem happens not buddy but walking whole pfn to echo
min_free_kbytes.

>
> -- Dave
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
