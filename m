Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C15BB6B004F
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 13:46:06 -0400 (EDT)
Received: by vwj42 with SMTP id 42so2417396vwj.12
        for <linux-mm@kvack.org>; Sun, 05 Jul 2009 07:16:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090705182337.08F9.A69D9226@jp.fujitsu.com>
References: <20090705181400.08F1.A69D9226@jp.fujitsu.com>
	 <20090705182337.08F9.A69D9226@jp.fujitsu.com>
Date: Sun, 5 Jul 2009 23:16:27 +0900
Message-ID: <28c262360907050716x28671070of7ab21556213b337@mail.gmail.com>
Subject: Re: [PATCH 2/5] add buffer cache information to show_free_areas()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, Jul 5, 2009 at 6:24 PM, KOSAKI
Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
> Subject: [PATCH] add buffer cache information to show_free_areas()
>
> When administrator analysis memory shortage reason from OOM log, They
> often need to know rest number of cache like pages.
>
> Then, show_free_areas() shouldn't only display page cache, but also it
> should display buffer cache.
>
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
> =C2=A0mm/page_alloc.c | =C2=A0 =C2=A03 ++-
> =C2=A01 file changed, 2 insertions(+), 1 deletion(-)
>
> Index: b/mm/page_alloc.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2118,7 +2118,7 @@ void show_free_areas(void)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0printk("Active_anon:%lu active_file:%lu inacti=
ve_anon:%lu\n"
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0" inactive_file:%l=
u"
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0" unevictable:%lu"
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 " dirty:%lu writeback:=
%lu unstable:%lu\n"
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 " dirty:%lu writeback:=
%lu buffer:%lu unstable:%lu\n"
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0" free:%lu slab_re=
claimable:%lu slab_unreclaimable:%lu\n"
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0" mapped:%lu paget=
ables:%lu bounce:%lu\n",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0global_page_state(=
NR_ACTIVE_ANON),
> @@ -2128,6 +2128,7 @@ void show_free_areas(void)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0global_page_state(=
NR_UNEVICTABLE),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0global_page_state(=
NR_FILE_DIRTY),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0global_page_state(=
NR_WRITEBACK),
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 K(nr_blockdev_pages())=
,

Why do you show the number with kilobyte unit ?
Others are already number of pages.

Do you have any reason ?


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
