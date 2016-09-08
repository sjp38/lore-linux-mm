Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7AB906B0069
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 20:03:27 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 44so62828400qtf.3
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 17:03:27 -0700 (PDT)
Received: from mail-yw0-x237.google.com (mail-yw0-x237.google.com. [2607:f8b0:4002:c05::237])
        by mx.google.com with ESMTPS id i127si14244925ywb.412.2016.09.07.17.03.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Sep 2016 17:03:26 -0700 (PDT)
Received: by mail-yw0-x237.google.com with SMTP id g192so12907976ywh.0
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 17:03:26 -0700 (PDT)
Date: Wed, 7 Sep 2016 17:03:25 -0700 (PDT)
From: bethelpchalfant@gmail.com
Message-Id: <530585b6-f490-4c8d-803c-5eb94dcb81bf@googlegroups.com>
In-Reply-To: <2a6c69fa-fe05-40c4-b817-15a58ed2666b@googlegroups.com>
References: <1467294357-98002-1-git-send-email-dvyukov@google.com>
 <5775232B.2070607@virtuozzo.com>
 <2a6c69fa-fe05-40c4-b817-15a58ed2666b@googlegroups.com>
Subject: Re: [PATCH] kasan: add newline to messages
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_2_1224761781.1473293005433"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kasan-dev <kasan-dev@googlegroups.com>
Cc: dvyukov@google.com, akpm@linux-foundation.org, glider@google.com, linux-mm@kvack.org, aryabinin@virtuozzo.com, amanda4ray@gmail.com

------=_Part_2_1224761781.1473293005433
Content-Type: multipart/alternative;
	boundary="----=_Part_3_1570453519.1473293005433"

------=_Part_3_1570453519.1473293005433
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit



On Tuesday, August 30, 2016 at 9:07:23 PM UTC-5, amand...@gmail.com wrote:
>
> On Thursday, June 30, 2016 at 9:47:33 AM UTC-4, Andrey Ryabinin wrote:
> > On 06/30/2016 04:45 PM, Dmitry Vyukov wrote:
> > > Currently GPF messages with KASAN look as follows:
> > > kasan: GPF could be caused by NULL-ptr deref or user memory 
> accessgeneral protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
> > > Add newlines.
> > > 
> > > Signed-off-by: Dmitry Vyukov <dvy...@google.com <javascript:>>
> > 
> > Acked-by: Andrey Ryabinin <arya...@virtuozzo.com <javascript:>>
> > 
> > > ---
> > >  arch/x86/mm/kasan_init_64.c | 4 ++--
> > >  1 file changed, 2 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
> > > index 1b1110f..0493c17 100644
> > > --- a/arch/x86/mm/kasan_init_64.c
> > > +++ b/arch/x86/mm/kasan_init_64.c
> > > @@ -54,8 +54,8 @@ static int kasan_die_handler(struct notifier_block 
> *self,
> > >                               void *data)
> > >  {
> > >          if (val == DIE_GPF) {
> > > -                pr_emerg("CONFIG_KASAN_INLINE enabled");
> > > -                pr_emerg("GPF could be caused by NULL-ptr deref or 
> user memory access");
> > > +                pr_emerg("CONFIG_KASAN_INLINE enabled\n");
> > > +                pr_emerg("GPF could be caused by NULL-ptr deref or 
> user memory access\n");
> > >          }
> > >          return NOTIFY_OK;
> > >  }
> > >
>
> On Thursday, June 30, 2016 at 9:47:33 AM UTC-4, Andrey Ryabinin wrote:
> > On 06/30/2016 04:45 PM, Dmitry Vyukov wrote:
> > > Currently GPF messages with KASAN look as follows:
> > > kasan: GPF could be caused by NULL-ptr deref or user memory 
> accessgeneral protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
> > > Add newlines.
> > > 
> > > Signed-off-by: Dmitry Vyukov <dvy...@google.com <javascript:>>
> > 
> > Acked-by: Andrey Ryabinin <arya...@virtuozzo.com <javascript:>>
> > 
> > > ---
> > >  arch/x86/mm/kasan_init_64.c | 4 ++--
> > >  1 file changed, 2 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
> > > index 1b1110f..0493c17 100644
> > > --- a/arch/x86/mm/kasan_init_64.c
> > > +++ b/arch/x86/mm/kasan_init_64.c
> > > @@ -54,8 +54,8 @@ static int kasan_die_handler(struct notifier_block 
> *self,
> > >                               void *data)
> > >  {
> > >          if (val == DIE_GPF) {
> > > -                pr_emerg("CONFIG_KASAN_INLINE enabled");
> > > -                pr_emerg("GPF could be caused by NULL-ptr deref or 
> user memory access");
> > > +                pr_emerg("CONFIG_KASAN_INLINE enabled\n");
> > > +                pr_emerg("GPF could be caused by NULL-ptr deref or 
> user memory access\n");
> > >          }
> > >          return NOTIFY_OK;
> > >  }
> > >
>
>
------=_Part_3_1570453519.1473293005433
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><br>On Tuesday, August 30, 2016 at 9:07:23 PM UTC-5, a=
mand...@gmail.com wrote:<blockquote class=3D"gmail_quote" style=3D"margin: =
0;margin-left: 0.8ex;border-left: 1px #ccc solid;padding-left: 1ex;">On Thu=
rsday, June 30, 2016 at 9:47:33 AM UTC-4, Andrey Ryabinin wrote:<br>&gt; On=
 06/30/2016 04:45 PM, Dmitry Vyukov wrote:<br>&gt; &gt; Currently GPF messa=
ges with KASAN look as follows:<br>&gt; &gt; kasan: GPF could be caused by =
NULL-ptr deref or user memory accessgeneral protection fault: 0000 [#1] SMP=
 DEBUG_PAGEALLOC KASAN<br>&gt; &gt; Add newlines.<br>&gt; &gt; <br>&gt; &gt=
; Signed-off-by: Dmitry Vyukov &lt;<a href=3D"javascript:" target=3D"_blank=
" gdf-obfuscated-mailto=3D"bBwRNW_LAgAJ" rel=3D"nofollow" onmousedown=3D"th=
is.href=3D&#39;javascript:&#39;;return true;" onclick=3D"this.href=3D&#39;j=
avascript:&#39;;return true;">dvy...@google.com</a>&gt;<br>&gt; <br>&gt; Ac=
ked-by: Andrey Ryabinin &lt;<a href=3D"javascript:" target=3D"_blank" gdf-o=
bfuscated-mailto=3D"bBwRNW_LAgAJ" rel=3D"nofollow" onmousedown=3D"this.href=
=3D&#39;javascript:&#39;;return true;" onclick=3D"this.href=3D&#39;javascri=
pt:&#39;;return true;">arya...@virtuozzo.com</a>&gt;<br>&gt; <br>&gt; &gt; =
---<br>&gt; &gt; =C2=A0arch/x86/mm/kasan_init_64.c | 4 ++--<br>&gt; &gt; =
=C2=A01 file changed, 2 insertions(+), 2 deletions(-)<br>&gt; &gt; <br>&gt;=
 &gt; diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.=
c<br>&gt; &gt; index 1b1110f..0493c17 100644<br>&gt; &gt; --- a/arch/x86/mm=
/kasan_init_64.c<br>&gt; &gt; +++ b/arch/x86/mm/kasan_init_64.c<br>&gt; &gt=
; @@ -54,8 +54,8 @@ static int kasan_die_handler(struct notifier_block *sel=
f,<br>&gt; &gt; =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 =C2=A0 =C2=A0 void *data)<br>&gt; &gt; =C2=A0{<br>&gt; &=
gt; =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (val =3D=3D DI=
E_GPF) {<br>&gt; &gt; -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0pr_emerg(&quot;<wbr>CONFIG_KAS=
AN_INLINE enabled&quot;);<br>&gt; &gt; -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0pr_emerg(&qu=
ot;GPF could be caused by NULL-ptr deref or user memory access&quot;);<br>&=
gt; &gt; +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0pr_emerg(&quot;<wbr>CONFIG_KASAN_INLINE en=
abled\n&quot;);<br>&gt; &gt; +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0pr_emerg(&quot;GPF could=
 be caused by NULL-ptr deref or user memory access\n&quot;);<br>&gt; &gt; =
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0}<br>&gt; &gt; =C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0return NOTIFY_OK;<br>&gt; &=
gt; =C2=A0}<br>&gt; &gt;<p>On Thursday, June 30, 2016 at 9:47:33 AM UTC-4, =
Andrey Ryabinin wrote:<br>&gt; On 06/30/2016 04:45 PM, Dmitry Vyukov wrote:=
<br>&gt; &gt; Currently GPF messages with KASAN look as follows:<br>&gt; &g=
t; kasan: GPF could be caused by NULL-ptr deref or user memory accessgenera=
l protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN<br>&gt; &gt; Add ne=
wlines.<br>&gt; &gt; <br>&gt; &gt; Signed-off-by: Dmitry Vyukov &lt;<a href=
=3D"javascript:" target=3D"_blank" gdf-obfuscated-mailto=3D"bBwRNW_LAgAJ" r=
el=3D"nofollow" onmousedown=3D"this.href=3D&#39;javascript:&#39;;return tru=
e;" onclick=3D"this.href=3D&#39;javascript:&#39;;return true;">dvy...@googl=
e.com</a>&gt;<br>&gt; <br>&gt; Acked-by: Andrey Ryabinin &lt;<a href=3D"jav=
ascript:" target=3D"_blank" gdf-obfuscated-mailto=3D"bBwRNW_LAgAJ" rel=3D"n=
ofollow" onmousedown=3D"this.href=3D&#39;javascript:&#39;;return true;" onc=
lick=3D"this.href=3D&#39;javascript:&#39;;return true;">arya...@virtuozzo.c=
om</a>&gt;<br>&gt; <br>&gt; &gt; ---<br>&gt; &gt; =C2=A0arch/x86/mm/kasan_i=
nit_64.c | 4 ++--<br>&gt; &gt; =C2=A01 file changed, 2 insertions(+), 2 del=
etions(-)<br>&gt; &gt; <br>&gt; &gt; diff --git a/arch/x86/mm/kasan_init_64=
.c b/arch/x86/mm/kasan_init_64.c<br>&gt; &gt; index 1b1110f..0493c17 100644=
<br>&gt; &gt; --- a/arch/x86/mm/kasan_init_64.c<br>&gt; &gt; +++ b/arch/x86=
/mm/kasan_init_64.c<br>&gt; &gt; @@ -54,8 +54,8 @@ static int kasan_die_han=
dler(struct notifier_block *self,<br>&gt; &gt; =C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0 =C2=A0 void *data)<=
br>&gt; &gt; =C2=A0{<br>&gt; &gt; =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0if (val =3D=3D DIE_GPF) {<br>&gt; &gt; -=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0pr_emerg(&quot;<wbr>CONFIG_KASAN_INLINE enabled&quot;);<br>&gt; &gt; -=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0pr_emerg(&quot;GPF could be caused by NULL-ptr deref o=
r user memory access&quot;);<br>&gt; &gt; +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0pr_emerg(=
&quot;<wbr>CONFIG_KASAN_INLINE enabled\n&quot;);<br>&gt; &gt; +=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0pr_emerg(&quot;GPF could be caused by NULL-ptr deref or user memor=
y access\n&quot;);<br>&gt; &gt; =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0}<br>&gt; &gt; =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0return NOTIFY_OK;<br>&gt; &gt; =C2=A0}<br>&gt; &gt;</p><p></p><p></p>=
</blockquote></div>
------=_Part_3_1570453519.1473293005433--

------=_Part_2_1224761781.1473293005433--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
