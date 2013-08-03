Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 62DC86B0031
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 20:44:06 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so1197030pdj.7
        for <linux-mm@kvack.org>; Fri, 02 Aug 2013 17:44:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CANBD6kFf0nyr=AZU6fv-FWOHoAkRkLV4+HyyvXDvfF8=38x-eA@mail.gmail.com>
References: <1375408621-16563-1-git-send-email-iamjoonsoo.kim@lge.com>
	<CANBD6kFf0nyr=AZU6fv-FWOHoAkRkLV4+HyyvXDvfF8=38x-eA@mail.gmail.com>
Date: Sat, 3 Aug 2013 08:44:05 +0800
Message-ID: <CANBD6kF0qBzPXKxA2AqT=xER6kjdQV6B01VsdbxuuO09av5Knw@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm, vmalloc: remove useless variable in vmap_block
From: Yanfei Zhang <zhangyanfei.yes@gmail.com>
Content-Type: multipart/alternative; boundary=047d7bf16282517b7d04e3005f29
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <js1304@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>

--047d7bf16282517b7d04e3005f29
Content-Type: text/plain; charset=UTF-8

On Saturday, August 3, 2013, Yanfei Zhang wrote:

> On Friday, August 2, 2013, Joonsoo Kim wrote:
>
>> vbq in vmap_block isn't used. So remove it.
>>
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
>
> Acked-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.con>
>

Sorry, the mail was wrongly written, it should be :

Acked-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>


>
>
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index 13a5495..d23c432 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -752,7 +752,6 @@ struct vmap_block_queue {
>>  struct vmap_block {
>>         spinlock_t lock;
>>         struct vmap_area *va;
>> -       struct vmap_block_queue *vbq;
>>         unsigned long free, dirty;
>>         DECLARE_BITMAP(dirty_map, VMAP_BBMAP_BITS);
>>         struct list_head free_list;
>> @@ -830,7 +829,6 @@ static struct vmap_block *new_vmap_block(gfp_t
>> gfp_mask)
>>         radix_tree_preload_end();
>>
>>         vbq = &get_cpu_var(vmap_block_queue);
>> -       vb->vbq = vbq;
>>         spin_lock(&vbq->lock);
>>         list_add_rcu(&vb->free_list, &vbq->free);
>>         spin_unlock(&vbq->lock);
>> --
>> 1.7.9.5
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>>
>

--047d7bf16282517b7d04e3005f29
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Saturday, August 3, 2013, Yanfei Zhang  wrote:<br><blockquote class=3D"g=
mail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-l=
eft:1ex">On Friday, August 2, 2013, Joonsoo Kim  wrote:<br><blockquote clas=
s=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;pad=
ding-left:1ex">
vbq in vmap_block isn&#39;t used. So remove it.<br>
<br>
Signed-off-by: Joonsoo Kim &lt;<a>iamjoonsoo.kim@lge.com</a>&gt;</blockquot=
e><div><br></div><div>Acked-by: Zhang Yanfei &lt;zhangyanfei@cn.fujitsu.con=
&gt;<span></span></div></blockquote><div><br></div><div>Sorry, the mail was=
 wrongly written,=C2=A0<span></span>it should be :=C2=A0</div>
<div><br></div><div>Acked-by: Zhang Yanfei &lt;<a href=3D"mailto:zhangyanfe=
i@cn.fujitsu.com">zhangyanfei@cn.fujitsu.com</a>&gt;</div><div><br></div><b=
lockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-le=
ft-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;pad=
ding-left:1ex">
<br></blockquote><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8=
ex;border-left:1px #ccc solid;padding-left:1ex">
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
the body of a message to <a>majordomo@vger.kernel.org</a><br>
More majordomo info at =C2=A0<a href=3D"http://vger.kernel.org/majordomo-in=
fo.html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html</a><b=
r>
Please read the FAQ at =C2=A0<a href=3D"http://www.tux.org/lkml/" target=3D=
"_blank">http://www.tux.org/lkml/</a><br>
</blockquote>
</blockquote>

--047d7bf16282517b7d04e3005f29--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
