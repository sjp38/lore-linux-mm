Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5DC3E6B0038
	for <linux-mm@kvack.org>; Sun, 12 Apr 2015 03:08:16 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so71117245pdb.0
        for <linux-mm@kvack.org>; Sun, 12 Apr 2015 00:08:16 -0700 (PDT)
Received: from COL004-OMC2S7.hotmail.com (col004-omc2s7.hotmail.com. [65.55.34.81])
        by mx.google.com with ESMTPS id v1si10198214pdg.139.2015.04.12.00.08.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 12 Apr 2015 00:08:15 -0700 (PDT)
Message-ID: <COL130-W77A7613DB3EA1820D92CBABAF80@phx.gbl>
From: ZhangNeil <neilzhang1123@hotmail.com>
Subject: RE: [PATCH v2] mm: show free pages per each migrate type
Date: Sun, 12 Apr 2015 07:08:15 +0000
In-Reply-To: <alpine.DEB.2.10.1504101944440.9879@chino.kir.corp.google.com>
References: 
 <BLU436-SMTP78227860F3E4FAF236A85CBAFB0@phx.gbl>,<alpine.DEB.2.10.1504101944440.9879@chino.kir.corp.google.com>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

=0A=
----------------------------------------=0A=
> Date: Fri=2C 10 Apr 2015 19:50:07 -0700=0A=
> From: rientjes@google.com=0A=
> To: neilzhang1123@hotmail.com=0A=
> CC: linux-mm@kvack.org=3B linux-kernel@vger.kernel.org=3B akpm@linux-foun=
dation.org=0A=
> Subject: Re: [PATCH v2] mm: show free pages per each migrate type=0A=
>=0A=
> On Thu=2C 9 Apr 2015=2C Neil Zhang wrote:=0A=
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
>>=0A=
>> Signed-off-by: Neil Zhang <neilzhang1123@hotmail.com>=0A=
>=0A=
> Sorry=2C this is just way too verbose. This output is emitted to the kern=
el=0A=
> log on oom kill and since we lack a notification mechanism on system oom=
=2C=0A=
> the _only_ way for userspace to detect oom kills that have occurred is by=
=0A=
> scraping the kernel log. This is exactly what we do=2C and we have missed=
=0A=
> oom kill events because they scroll from the ring buffer due to excessive=
=0A=
> output such as this=2C which is why output was limited with the=0A=
> show_free_areas() filter in the first place. Just because oom kill output=
=0A=
> is much less than it has been in the past=2C for precisely this reason=2C=
=0A=
> doesn't mean we can make it excessive again.=0A=
>=0A=
=0A=
Just like you said=2C OOM kill is much less than before=2C but we still nee=
d to analyze it when=A0=0A=
it happens on a mobile device. It can give more detailed info for us when d=
ebugging.=0A=
=A0=0A=
Besides OOM kill=2C we also can check the memory usages in runtime by echo =
'm' to sysRq.=0A=
It can help us to =A0find out code defect sometimes=2C for example=2C we ev=
en found that the NR_FREE_CMA=0A=
memory was not align with the total CMA pages in the free list showed by th=
is patch.=0A=
=0A=
> So nack on this patch=2C and if we really need to have this information (=
I=0A=
> don't know your motivation for adding it since you list none in your=0A=
> changelog)=2C then we need to consider an oom verbosity sysctl or=2C bett=
er=2C=0A=
> an actual system oom notification to userspace based on eventfd() without=
=0A=
> requiring memcg.=0A=
=0A=
Best Regards=2C=0A=
Neil Zhang 		 	   		  =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
