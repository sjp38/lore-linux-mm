Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id C68C06B0038
	for <linux-mm@kvack.org>; Fri, 10 Apr 2015 00:16:16 -0400 (EDT)
Received: by pddn5 with SMTP id n5so9716921pdd.2
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 21:16:16 -0700 (PDT)
Received: from COL004-OMC1S19.hotmail.com (col004-omc1s19.hotmail.com. [65.55.34.29])
        by mx.google.com with ESMTPS id yl2si1112120pbc.118.2015.04.09.21.16.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 09 Apr 2015 21:16:15 -0700 (PDT)
Message-ID: <COL130-W536B434DEADC19798C2A9FBAFA0@phx.gbl>
From: ZhangNeil <neilzhang1123@hotmail.com>
Subject: RE: [PATCH v2] mm: show free pages per each migrate type
Date: Fri, 10 Apr 2015 04:16:15 +0000
In-Reply-To: <20150409134701.5903cb5217f5742bbacc73da@linux-foundation.org>
References: 
 <BLU436-SMTP78227860F3E4FAF236A85CBAFB0@phx.gbl>,<20150409134701.5903cb5217f5742bbacc73da@linux-foundation.org>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

=0A=
=0A=
----------------------------------------=0A=
> Date: Thu=2C 9 Apr 2015 13:47:01 -0700=0A=
> From: akpm@linux-foundation.org=0A=
> To: neilzhang1123@hotmail.com=0A=
> CC: linux-mm@kvack.org=3B linux-kernel@vger.kernel.org=0A=
> Subject: Re: [PATCH v2] mm: show free pages per each migrate type=0A=
>=0A=
> On Thu=2C 9 Apr 2015 10:19:10 +0800 Neil Zhang <neilzhang1123@hotmail.com=
> wrote:=0A=
>=0A=
>> show detailed free pages per each migrate type in show_free_areas.=0A=
>>=0A=
>> After apply this patch=2C the log printed out will be changed from=0A=
>>=0A=
>> [ 558.212844@0] Normal: 218*4kB (UEMC) 207*8kB (UEMC) 126*16kB (UEMC) 21=
*32kB (UC) 5*64kB (C) 3*128kB (C) 1*256kB (C) 1*512kB (C) 0*1024kB 0*2048kB=
 1*4096kB (R) =3D 10784kB=0A=
>> [ 558.227840@0] HighMem: 3*4kB (UMR) 3*8kB (UMR) 2*16kB (UM) 3*32kB (UMR=
) 0*64kB 1*128kB (M) 1*256kB (R) 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 548=
kB=0A=
>>=0A=
>> to=0A=
>>=0A=
>> [ 806.506450@1] Normal: 8969*4kB 4370*8kB 2*16kB 3*32kB 2*64kB 3*128kB 3=
*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB =3D 74804kB=0A=
>> [ 806.517456@1] orders: 0 1 2 3 4 5 6 7 8 9 10=0A=
>> [ 806.527077@1] Unmovable: 8287 4370 0 0 0 0 0 0 0 0 0=0A=
>> [ 806.536699@1] Reclaimable: 681 0 0 0 0 0 0 0 0 0 0=0A=
>> [ 806.546321@1] Movable: 1 0 0 0 0 0 0 0 0 0 0=0A=
>> [ 806.555942@1] Reserve: 0 0 2 3 2 3 3 1 0 1 0=0A=
>> [ 806.565564@1] CMA: 0 0 0 0 0 0 0 0 0 0 0=0A=
>> [ 806.575187@1] Isolate: 0 0 0 0 0 0 0 0 0 0 0=0A=
>> [ 806.584810@1] HighMem: 80*4kB 15*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*25=
6kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 440kB=0A=
>> [ 806.595383@1] orders: 0 1 2 3 4 5 6 7 8 9 10=0A=
>> [ 806.605004@1] Unmovable: 12 0 0 0 0 0 0 0 0 0 0=0A=
>> [ 806.614626@1] Reclaimable: 0 0 0 0 0 0 0 0 0 0 0=0A=
>> [ 806.624248@1] Movable: 11 15 0 0 0 0 0 0 0 0 0=0A=
>> [ 806.633869@1] Reserve: 57 0 0 0 0 0 0 0 0 0 0=0A=
>> [ 806.643491@1] CMA: 0 0 0 0 0 0 0 0 0 0 0=0A=
>> [ 806.653113@1] Isolate: 0 0 0 0 0 0 0 0 0 0 0=0A=
>=0A=
> Thanks. The proposed output does indeed look a lot better.=0A=
>=0A=
> The columns don't line up=2C but I guess we can live with that =3B)=0A=
>=0A=
=0A=
Thanks Andrew.=0A=
=0A=
>=0A=
>> --- a/mm/page_alloc.c=0A=
>> +++ b/mm/page_alloc.c=0A=
>> @@ -3327=2C7 +3313=2C7 @@ void show_free_areas(unsigned int filter)=0A=
>>=0A=
>> for_each_populated_zone(zone) {=0A=
>> unsigned long nr[MAX_ORDER]=2C flags=2C order=2C total =3D 0=3B=0A=
>> - unsigned char types[MAX_ORDER]=3B=0A=
>> + unsigned long nr_free[MAX_ORDER][MIGRATE_TYPES]=2C mtype=3B=0A=
>>=0A=
>> if (skip_free_areas_node(filter=2C zone_to_nid(zone)))=0A=
>> continue=3B=0A=
>=0A=
> nr_free[][] is an 8x11 array of 8=2C I think? That's 704 bytes of stack=
=2C=0A=
> and show_free_areas() is called from very deep call stacks - from the=0A=
> oom-killer=2C for example. We shouldn't do this.=0A=
>=0A=
> I think we can eliminate nr_free[][]:=0A=
=0A=
what about make it as global=A0variable?=0A=
=0A=
>=0A=
>> + for (mtype =3D 0=3B mtype < MIGRATE_TYPES=3B mtype++) {=0A=
>> + printk("%12s: "=2C migratetype_names[mtype])=3B=0A=
>> + for (order =3D 0=3B order < MAX_ORDER=3B order++)=0A=
>> + printk("%6lu "=2C nr_free[order][mtype])=3B=0A=
>> + printk("\n")=3B=0A=
>> + }=0A=
>=0A=
> In the above loop=2C take zone->lock and calculate the nr_free for this=
=0A=
> particular order/mtype=2C then release zone->lock.=0A=
>=0A=
> That will be slower=2C but show_free_areas() doesn't need to be fast.=0A=
=0A=
Yes=2C it mainly be called in oom killer.=0A=
=0A=
Best Regards=2C=0A=
Neil Zhang=0A=
=0A=
 		 	   		  =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
