Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 95BD06B13F0
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 03:09:17 -0500 (EST)
Received: by vcbf13 with SMTP id f13so186835vcb.14
        for <linux-mm@kvack.org>; Thu, 09 Feb 2012 00:09:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <op.v9cstne43l0zgt@mpn-glaptop>
References: <1328448800-15794-1-git-send-email-gilad@benyossef.com>
	<1328449722-15959-6-git-send-email-gilad@benyossef.com>
	<op.v9cstne43l0zgt@mpn-glaptop>
Date: Thu, 9 Feb 2012 10:09:15 +0200
Message-ID: <CAOtvUMdo3yx1d5Ghs=GVBHCQGA8t9Vg=PK77h4V=hrLWDPUcUQ@mail.gmail.com>
Subject: Re: [PATCH v8 7/8] mm: only IPI CPUs to drain local pages if they exist
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Metcalf <cmetcalf@tilera.com>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Milton Miller <miltonm@bga.com>

2012/2/8 Michal Nazarewicz <mina86@mina86.com>:
> On Sun, 05 Feb 2012 14:48:41 +0100, Gilad Ben-Yossef <gilad@benyossef.com=
>
> wrote:
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index d2186ec..3ff5aff 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1161,11 +1161,46 @@ void drain_local_pages(void *arg)
...
>> +
>> + =A0 =A0 =A0 /* Allocate in the BSS so we wont require allocation in
>> + =A0 =A0 =A0 =A0* direct reclaim path for CONFIG_CPUMASK_OFFSTACK=3Dy
>> + =A0 =A0 =A0 =A0*/
>
>
> If you are going to send next iteration, this comment should have
> =93/*=94 on its own line just like comment below.

Right, thanks.

Gilad

--=20
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
=A0-- Jean-Baptiste Queru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
