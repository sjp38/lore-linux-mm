Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 3F3946B007E
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 02:57:37 -0500 (EST)
Received: by vbip1 with SMTP id p1so4941036vbi.14
        for <linux-mm@kvack.org>; Sun, 19 Feb 2012 23:57:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120217142806.07a97347.akpm@linux-foundation.org>
References: <1328257256-1296-1-git-send-email-geunsik.lim@gmail.com>
	<20120217142806.07a97347.akpm@linux-foundation.org>
Date: Mon, 20 Feb 2012 16:57:35 +0900
Message-ID: <CAGFP0LJhqC9xqn=BmoOyRL_wJX8=KU=Z4+k=t=C3MLhWYqWLnQ@mail.gmail.com>
Subject: Re: [PATCH] Fix potentially derefencing uninitialized 'r'.
From: Geunsik Lim <geunsik.lim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "H. Peter Anvin" <hpa@linux.intel.com>, Yinghai Lu <yinghai@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Sat, Feb 18, 2012 at 7:28 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, =C2=A03 Feb 2012 17:20:56 +0900
> Geunsik Lim <geunsik.lim@gmail.com> wrote:
>
>> struct memblock_region 'r' will not be initialized potentially
>> because of while statement's condition in __next_mem_pfn_range()function=
.
>> Initialize struct memblock_region data structure by default.
>>
>> Signed-off-by: Geunsik Lim <geunsik.lim@samsung.com>
>> ---
>> =C2=A0mm/memblock.c | =C2=A0 =C2=A02 +-
>> =C2=A01 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/memblock.c b/mm/memblock.c
>> index 77b5f22..867f5a2 100644
>> --- a/mm/memblock.c
>> +++ b/mm/memblock.c
>> @@ -671,7 +671,7 @@ void __init_memblock __next_mem_pfn_range(int *idx, =
int nid,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long *out_end_pfn, int *out_nid=
)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 struct memblock_type *type =3D &memblock.memory;
>> - =C2=A0 =C2=A0 struct memblock_region *r;
>> + =C2=A0 =C2=A0 struct memblock_region *r =3D &type->regions[*idx];
>>
>> =C2=A0 =C2=A0 =C2=A0 while (++*idx < type->cnt) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 r =3D &type->regions[*i=
dx];
>
> The following `if' test prevents any such dereference.
>
> Maybe you saw a compilation warning (I didn't). =C2=A0If so,
> unintialized_var() is one way of suppressing it.
Yepp. This patch is  for solving compilation warning as you commented.
>
> A better way is to reorganise the code (nicely). =C2=A0Often that option
> isn't available.
I will post patch again after reorganizing the code with better way.
Thanks.
>
>



--=20
----
Best regards,
Geunsik Lim, Samsung Electronics
http://leemgs.fedorapeople.org
----
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.html
Please read the FAQ at =C2=A0http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
