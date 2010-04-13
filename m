Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 65A546B01F2
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 19:40:18 -0400 (EDT)
Received: by iwn14 with SMTP id 14so5366495iwn.22
        for <linux-mm@kvack.org>; Tue, 13 Apr 2010 16:40:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1004131437140.8617@chino.kir.corp.google.com>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
	 <8b348d9cc1ea4960488b193b7e8378876918c0d4.1271171877.git.minchan.kim@gmail.com>
	 <alpine.DEB.2.00.1004131437140.8617@chino.kir.corp.google.com>
Date: Wed, 14 Apr 2010 08:40:16 +0900
Message-ID: <u2o28c262361004131640zd034a692s4b46ee77c08e1ccd@mail.gmail.com>
Subject: Re: [PATCH 3/6] change alloc function in alloc_slab_page
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 6:37 AM, David Rientjes <rientjes@google.com> wrote=
:
> On Wed, 14 Apr 2010, Minchan Kim wrote:
>
>> alloc_slab_page never calls alloc_pages_node with -1.
>> It means node's validity check is unnecessary.
>> So we can use alloc_pages_exact_node instead of alloc_pages_node.
>> It could avoid comparison and branch as 6484eb3e2a81807722 tried.
>>
>> Cc: Christoph Lameter <cl@linux-foundation.org>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> ---
>> =C2=A0mm/slub.c | =C2=A0 =C2=A02 +-
>> =C2=A01 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/slub.c b/mm/slub.c
>> index b364844..9984165 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -1084,7 +1084,7 @@ static inline struct page *alloc_slab_page(gfp_t f=
lags, int node,
>> =C2=A0 =C2=A0 =C2=A0 if (node =3D=3D -1)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return alloc_pages(flag=
s, order);
>> =C2=A0 =C2=A0 =C2=A0 else
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return alloc_pages_node(node=
, flags, order);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return alloc_pages_exact_nod=
e(node, flags, order);
>> =C2=A0}
>>
>> =C2=A0static struct page *allocate_slab(struct kmem_cache *s, gfp_t flag=
s, int node)
>
> Slub changes need to go through its maintainer, Pekka Enberg
> <penberg@cs.helsinki.fi>.

Thanks, David. It was by mistake.

Pekka.

This changlog is bad.
I will change it with following as when I send v2.

"alloc_slab_page always checks nid =3D=3D -1, so alloc_page_node can't be
called with -1.
 It means node's validity check in alloc_pages_node is unnecessary.
 So we can use alloc_pages_exact_node instead of alloc_pages_node.
 It could avoid comparison and branch as 6484eb3e2a81807722 tried."

Thanks.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
