Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 2E2936B00EF
	for <linux-mm@kvack.org>; Tue,  8 May 2012 11:02:12 -0400 (EDT)
Received: by faap21 with SMTP id p21so1728faa.14
        for <linux-mm@kvack.org>; Tue, 08 May 2012 08:02:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1205080909490.25669@router.home>
References: <201205080931539844949@gmail.com>
	<CAOtvUMctgcCrB_kCoKZki45_2i9XKzp-XLyfmNTxYwdFWSKYNQ@mail.gmail.com>
	<alpine.DEB.2.00.1205080909490.25669@router.home>
Date: Tue, 8 May 2012 18:02:09 +0300
Message-ID: <CAOtvUMd6vJoZrtNTy8-cfOha0dqg1auUuhOkMWMG9umcwrNEzA@mail.gmail.com>
Subject: Re: [PATCH] slub: Using judgement !!c to judge per cpu has obj in
 fucntion has_cpu_slab().
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: majianpeng <majianpeng@gmail.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

On Tue, May 8, 2012 at 5:11 PM, Christoph Lameter <cl@linux.com> wrote:
> On Tue, 8 May 2012, Gilad Ben-Yossef wrote:
>
>> diff --git a/mm/slub.c b/mm/slub.c
>> index ffe13fd..d66afc4 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -2040,7 +2040,7 @@ static bool has_cpu_slab(int cpu, void *info)
>> =A0 =A0 =A0 struct kmem_cache *s =3D info;
>> =A0 =A0 =A0 struct kmem_cache_cpu *c =3D per_cpu_ptr(s->cpu_slab, cpu);
>>
>> - =A0 =A0 return !!(c->page);
>> + =A0 =A0 return !!(c->page && c->partial);
>
> &&? Should this not be || ? W#e can also drop the !! now I think.
>
> =A0 =A0 =A0 =A0return c->page || c->partial
>
>

Yes, it should. My mind  is mush in the mornings...

I'm waiting for Majianpeng to confirm this indeed works.

Thanks,
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
