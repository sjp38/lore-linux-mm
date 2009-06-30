Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 967B46B004D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 11:36:59 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id l33so64513rvb.26
        for <linux-mm@kvack.org>; Tue, 30 Jun 2009 08:38:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090630152324.A73A.A69D9226@jp.fujitsu.com>
References: <20090630152324.A73A.A69D9226@jp.fujitsu.com>
Date: Wed, 1 Jul 2009 00:38:08 +0900
Message-ID: <28c262360906300838m778ed5e4s8fe54501b95ccc0c@mail.gmail.com>
Subject: Re: [PATCH] Makes slab pages field in show_free_areas() separate two
	field
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 30, 2009 at 3:25 PM, KOSAKI
Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
> Subject: [PATCH] Makes slab pages field in show_free_areas() separate two=
 field
>
> if OOM happed, We really want to know the number of rest reclaimable page=
s.
> Then, reclaimable slab and unreclaimable slab shouldn't be mixed displain=
g.

Yes. It makes sense to me.

>
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

> ---
> =C2=A0mm/page_alloc.c | =C2=A0 =C2=A07 ++++---
> =C2=A01 file changed, 4 insertions(+), 3 deletions(-)
>
> Index: b/mm/page_alloc.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2119,7 +2119,8 @@ void show_free_areas(void)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0" inactive_file:%l=
u"
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0" unevictable:%lu"
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0" dirty:%lu writeb=
ack:%lu unstable:%lu\n"
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 " free:%lu slab:%lu ma=
pped:%lu pagetables:%lu bounce:%lu\n",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 " free:%lu slab_reclai=
mable:%lu slab_unreclaimable:%lu\n"
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 " mapped:%lu pagetable=
s:%lu bounce:%lu\n",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0global_page_state(=
NR_ACTIVE_ANON),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0global_page_state(=
NR_ACTIVE_FILE),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0global_page_state(=
NR_INACTIVE_ANON),
> @@ -2129,8 +2130,8 @@ void show_free_areas(void)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0global_page_state(=
NR_WRITEBACK),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0global_page_state(=
NR_UNSTABLE_NFS),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0global_page_state(=
NR_FREE_PAGES),
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 global_page_state(NR_S=
LAB_RECLAIMABLE) +
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 global_page_state(NR_SLAB_UNRECLAIMABLE),
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 global_page_state(NR_S=
LAB_RECLAIMABLE),
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 global_page_state(NR_S=
LAB_UNRECLAIMABLE),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0global_page_state(=
NR_FILE_MAPPED),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0global_page_state(=
NR_PAGETABLE),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0global_page_state(=
NR_BOUNCE));
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
