Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id C038A6B0031
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 20:38:26 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p11so1200563pdj.18
        for <linux-mm@kvack.org>; Fri, 02 Aug 2013 17:38:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1375408621-16563-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375408621-16563-1-git-send-email-iamjoonsoo.kim@lge.com>
Date: Sat, 3 Aug 2013 08:38:25 +0800
Message-ID: <CANBD6kFf0nyr=AZU6fv-FWOHoAkRkLV4+HyyvXDvfF8=38x-eA@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm, vmalloc: remove useless variable in vmap_block
From: Yanfei Zhang <zhangyanfei.yes@gmail.com>
Content-Type: multipart/alternative; boundary=047d7bd76ec412aee004e3004b71
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <js1304@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>

--047d7bd76ec412aee004e3004b71
Content-Type: text/plain; charset=UTF-8

On Friday, August 2, 2013, Joonsoo Kim wrote:

> vbq in vmap_block isn't used. So remove it.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com <javascript:;>>


Acked-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.con>


> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 13a5495..d23c432 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -752,7 +752,6 @@ struct vmap_block_queue {
>  struct vmap_block {
>         spinlock_t lock;
>         struct vmap_area *va;
> -       struct vmap_block_queue *vbq;
>         unsigned long free, dirty;
>         DECLARE_BITMAP(dirty_map, VMAP_BBMAP_BITS);
>         struct list_head free_list;
> @@ -830,7 +829,6 @@ static struct vmap_block *new_vmap_block(gfp_t
> gfp_mask)
>         radix_tree_preload_end();
>
>         vbq = &get_cpu_var(vmap_block_queue);
> -       vb->vbq = vbq;
>         spin_lock(&vbq->lock);
>         list_add_rcu(&vb->free_list, &vbq->free);
>         spin_unlock(&vbq->lock);
> --
> 1.7.9.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org <javascript:;>
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

--047d7bd76ec412aee004e3004b71
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Friday, August 2, 2013, Joonsoo Kim  wrote:<br><blockquote class=3D"gmai=
l_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left=
:1ex">vbq in vmap_block isn&#39;t used. So remove it.<br>
<br>
Signed-off-by: Joonsoo Kim &lt;<a href=3D"javascript:;" onclick=3D"_e(event=
, &#39;cvml&#39;, &#39;iamjoonsoo.kim@lge.com&#39;)">iamjoonsoo.kim@lge.com=
</a>&gt;</blockquote><div><br></div><div>Acked-by: Zhang Yanfei &lt;zhangya=
nfei@cn.fujitsu.con&gt;<span></span></div>
<div><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex=
;border-left:1px #ccc solid;padding-left:1ex">
<br>
diff --git a/mm/vmalloc.c b/mm/vmalloc.c<br>
index 13a5495..d23c432 100644<br>
--- a/mm/vmalloc.c<br>
+++ b/mm/vmalloc.c<br>
@@ -752,7 +752,6 @@ struct vmap_block_queue {<br>
=C2=A0struct vmap_block {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 spinlock_t lock;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct vmap_area *va;<br>
- =C2=A0 =C2=A0 =C2=A0 struct vmap_block_queue *vbq;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long free, dirty;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 DECLARE_BITMAP(dirty_map, VMAP_BBMAP_BITS);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct list_head free_list;<br>
@@ -830,7 +829,6 @@ static struct vmap_block *new_vmap_block(gfp_t gfp_mask=
)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 radix_tree_preload_end();<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 vbq =3D &amp;get_cpu_var(vmap_block_queue);<br>
- =C2=A0 =C2=A0 =C2=A0 vb-&gt;vbq =3D vbq;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock(&amp;vbq-&gt;lock);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 list_add_rcu(&amp;vb-&gt;free_list, &amp;vbq-&g=
t;free);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock(&amp;vbq-&gt;lock);<br>
--<br>
1.7.9.5<br>
<br>
--<br>
To unsubscribe from this list: send the line &quot;unsubscribe linux-kernel=
&quot; in<br>
the body of a message to <a href=3D"javascript:;" onclick=3D"_e(event, &#39=
;cvml&#39;, &#39;majordomo@vger.kernel.org&#39;)">majordomo@vger.kernel.org=
</a><br>
More majordomo info at =C2=A0<a href=3D"http://vger.kernel.org/majordomo-in=
fo.html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html</a><b=
r>
Please read the FAQ at =C2=A0<a href=3D"http://www.tux.org/lkml/" target=3D=
"_blank">http://www.tux.org/lkml/</a><br>
</blockquote>

--047d7bd76ec412aee004e3004b71--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
