Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 588DE6B010E
	for <linux-mm@kvack.org>; Tue,  8 May 2012 04:42:53 -0400 (EDT)
Received: by yenm8 with SMTP id m8so7241728yen.14
        for <linux-mm@kvack.org>; Tue, 08 May 2012 01:42:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201205081640084681980@gmail.com>
References: <201205080931539844949@gmail.com>
	<201205081640084681980@gmail.com>
Date: Tue, 8 May 2012 11:42:51 +0300
Message-ID: <CAOtvUMdpQNHGrWbrYZx2phXkUo2L9aUdxu3d16+3tsr9_TAPaw@mail.gmail.com>
Subject: Re: Re: [PATCH] slub: Using judgement !!c to judge per cpu has obj
 infucntion has_cpu_slab().
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: majianpeng <majianpeng@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On Tue, May 8, 2012 at 11:40 AM, majianpeng <majianpeng@gmail.com> wrote:
> I tested your patch,but the bug is still.
>
> I think the code may be is:
>
> diff --git a/mm/slub.c b/mm/slub.c
> index ffe13fd..d66afc4 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2040,7 +2040,7 @@ static bool has_cpu_slab(int cpu, void *info)
> =A0 =A0 =A0 =A0struct kmem_cache *s =3D info;
> =A0 =A0 =A0 =A0struct kmem_cache_cpu *c =3D per_cpu_ptr(s->cpu_slab, cpu)=
;
>
> - =A0 =A0 =A0 return !!(c->page);
> + =A0 =A0 =A0 return !!(c->page || c->partial);
> =A0}

You are very right. I shouldn't be sending patches before the first
morning coffee...

I take it this last version of the patch fixes the issue? if so it
should should go as a fix into 3.4-rc7

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
