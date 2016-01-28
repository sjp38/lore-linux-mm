Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA806B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 07:37:36 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id 128so8684415wmz.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 04:37:36 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id dh8si15112335wjb.102.2016.01.28.04.37.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 04:37:35 -0800 (PST)
Received: by mail-wm0-x231.google.com with SMTP id p63so22605744wmp.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 04:37:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160128074442.GB15426@js1304-P5Q-DELUXE>
References: <cover.1453918525.git.glider@google.com>
	<7f497e194053c25e8a3debe3e1e738a187e38c16.1453918525.git.glider@google.com>
	<20160128074442.GB15426@js1304-P5Q-DELUXE>
Date: Thu, 28 Jan 2016 13:37:34 +0100
Message-ID: <CAG_fn=W_17XMtCmLRHHccJmzPaJTk1Jc4uCa4T_n4E5NwRR9Mg@mail.gmail.com>
Subject: Re: [PATCH v1 2/8] mm, kasan: SLAB support
From: Alexander Potapenko <glider@google.com>
Content-Type: multipart/alternative; boundary=001a11c1ba62dbf62f052a642e97
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: kasan-dev@googlegroups.com, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, dvyukov@google.com, ryabinin.a.a@gmail.com, linux-mm@kvack.org, adech.fo@gmail.com, akpm@linux-foundation.org, rostedt@goodmis.org

--001a11c1ba62dbf62f052a642e97
Content-Type: text/plain; charset=UTF-8

On Jan 28, 2016 8:44 AM, "Joonsoo Kim" <iamjoonsoo.kim@lge.com> wrote:
>
> On Wed, Jan 27, 2016 at 07:25:07PM +0100, Alexander Potapenko wrote:
> > This patch adds KASAN hooks to SLAB allocator.
> >
> > This patch is based on the "mm: kasan: unified support for SLUB and
> > SLAB allocators" patch originally prepared by Dmitry Chernenkov.
> >
> > Signed-off-by: Alexander Potapenko <glider@google.com>
> > ---
> >  Documentation/kasan.txt  |  5 ++-
>
> ...
>
> > +#ifdef CONFIG_SLAB
> > +struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
> > +                                     const void *object)
> > +{
> > +     return (void *)object + cache->kasan_info.alloc_meta_offset;
> > +}
> > +
> > +struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
> > +                                   const void *object)
> > +{
> > +     return (void *)object + cache->kasan_info.free_meta_offset;
> > +}
> > +#endif
>
> I cannot find the place to store stack info for free. get_free_info()
> isn't used except print_object(). Plese let me know where.

This is covered by other patches in this patchset.

> Thanks.

--001a11c1ba62dbf62f052a642e97
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
On Jan 28, 2016 8:44 AM, &quot;Joonsoo Kim&quot; &lt;<a href=3D"mailto:iamj=
oonsoo.kim@lge.com">iamjoonsoo.kim@lge.com</a>&gt; wrote:<br>
&gt;<br>
&gt; On Wed, Jan 27, 2016 at 07:25:07PM +0100, Alexander Potapenko wrote:<b=
r>
&gt; &gt; This patch adds KASAN hooks to SLAB allocator.<br>
&gt; &gt;<br>
&gt; &gt; This patch is based on the &quot;mm: kasan: unified support for S=
LUB and<br>
&gt; &gt; SLAB allocators&quot; patch originally prepared by Dmitry Chernen=
kov.<br>
&gt; &gt;<br>
&gt; &gt; Signed-off-by: Alexander Potapenko &lt;<a href=3D"mailto:glider@g=
oogle.com">glider@google.com</a>&gt;<br>
&gt; &gt; ---<br>
&gt; &gt;=C2=A0 Documentation/kasan.txt=C2=A0 |=C2=A0 5 ++-<br>
&gt;<br>
&gt; ...<br>
&gt;<br>
&gt; &gt; +#ifdef CONFIG_SLAB<br>
&gt; &gt; +struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache=
,<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const =
void *object)<br>
&gt; &gt; +{<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0return (void *)object + cache-&gt;kasan_info=
.alloc_meta_offset;<br>
&gt; &gt; +}<br>
&gt; &gt; +<br>
&gt; &gt; +struct kasan_free_meta *get_free_info(struct kmem_cache *cache,<=
br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const void *o=
bject)<br>
&gt; &gt; +{<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0return (void *)object + cache-&gt;kasan_info=
.free_meta_offset;<br>
&gt; &gt; +}<br>
&gt; &gt; +#endif<br>
&gt;<br>
&gt; I cannot find the place to store stack info for free. get_free_info()<=
br>
&gt; isn&#39;t used except print_object(). Plese let me know where.</p>
<p dir=3D"ltr">This is covered by other patches in this patchset.</p>
<p dir=3D"ltr">&gt; Thanks.<br>
</p>

--001a11c1ba62dbf62f052a642e97--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
