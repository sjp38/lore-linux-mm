Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 83D858E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 07:43:13 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id t10-v6so1633739lji.12
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 04:43:13 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q4-v6sor1879739lfj.31.2018.09.28.04.43.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Sep 2018 04:43:11 -0700 (PDT)
MIME-Version: 1.0
References: <1538079759.qxp8zh3nwh.astroid@alex-archsus.none>
 <CALZtONA9r6=gnK-5a++tjaReqEnRzrBb3hzYMTFNXZ13z+UOWQ@mail.gmail.com>
 <153808275043.724.15980761008814866300@pink.alxu.ca> <1538082779.246sm0vb2p.astroid@alex-archsus.none>
 <CALZtONBUR2X8hLG59=JitZqAr0aOO+TWkf6Reke9DHkVu-9_wQ@mail.gmail.com>
In-Reply-To: <CALZtONBUR2X8hLG59=JitZqAr0aOO+TWkf6Reke9DHkVu-9_wQ@mail.gmail.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Fri, 28 Sep 2018 13:42:58 +0200
Message-ID: <CAMJBoFPHK1i1TpYDoH4R5_ZC97xQomy6XSkJJK5w7LU88pcxeQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm: fix z3fold warnings on CONFIG_SMP=n
Content-Type: multipart/alternative; boundary="000000000000c360350576ecf5c0"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: alex_y_xu@yahoo.ca, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

--000000000000c360350576ecf5c0
Content-Type: text/plain; charset="UTF-8"

Den fre 28 sep. 2018 kl 13:31 skrev Dan Streetman <ddstreet@ieee.org>:

> On Thu, Sep 27, 2018 at 5:15 PM Alex Xu (Hello71) <alex_y_xu@yahoo.ca>
> wrote:
> >
> > Spinlocks are always lockable on UP systems, even if they were just
> > locked.
> >
> > Cc: Dan Streetman <ddstreet@ieee.org>
>
> I cc'ed Vitaly also, as this code is from him, but the change
> certainly looks correct to me.
>
> Acked-by: Dan Streetman <ddstreet@ieee.org>
>

Acked-by: Vitaly Wool <vitalywool@gmail.com>

>
> > Signed-off-by: Alex Xu (Hello71) <alex_y_xu@yahoo.ca>
> > ---
> >  mm/z3fold.c | 6 +++---
> >  1 file changed, 3 insertions(+), 3 deletions(-)
> >
> > diff --git a/mm/z3fold.c b/mm/z3fold.c
> > index 4b366d181..2e8d268ac 100644
> > --- a/mm/z3fold.c
> > +++ b/mm/z3fold.c
> > @@ -277,7 +277,7 @@ static void release_z3fold_page_locked(struct kref
> *ref)
> >  {
> >         struct z3fold_header *zhdr = container_of(ref, struct
> z3fold_header,
> >                                                 refcount);
> > -       WARN_ON(z3fold_page_trylock(zhdr));
> > +       WARN_ON_SMP(z3fold_page_trylock(zhdr));
> >         __release_z3fold_page(zhdr, true);
> >  }
> >
> > @@ -289,7 +289,7 @@ static void release_z3fold_page_locked_list(struct
> kref *ref)
> >         list_del_init(&zhdr->buddy);
> >         spin_unlock(&zhdr->pool->lock);
> >
> > -       WARN_ON(z3fold_page_trylock(zhdr));
> > +       WARN_ON_SMP(z3fold_page_trylock(zhdr));
> >         __release_z3fold_page(zhdr, true);
> >  }
> >
> > @@ -403,7 +403,7 @@ static void do_compact_page(struct z3fold_header
> *zhdr, bool locked)
> >
> >         page = virt_to_page(zhdr);
> >         if (locked)
> > -               WARN_ON(z3fold_page_trylock(zhdr));
> > +               WARN_ON_SMP(z3fold_page_trylock(zhdr));
> >         else
> >                 z3fold_page_lock(zhdr);
> >         if (WARN_ON(!test_and_clear_bit(NEEDS_COMPACTING,
> &page->private))) {
> > --
> > 2.19.0
> >
>

--000000000000c360350576ecf5c0
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><br><div class=3D"gmail_quote"><div dir=3D"ltr">Den fr=
e 28 sep. 2018 kl 13:31 skrev Dan Streetman &lt;<a href=3D"mailto:ddstreet@=
ieee.org">ddstreet@ieee.org</a>&gt;:<br></div><blockquote class=3D"gmail_qu=
ote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex=
">On Thu, Sep 27, 2018 at 5:15 PM Alex Xu (Hello71) &lt;<a href=3D"mailto:a=
lex_y_xu@yahoo.ca" target=3D"_blank">alex_y_xu@yahoo.ca</a>&gt; wrote:<br>
&gt;<br>
&gt; Spinlocks are always lockable on UP systems, even if they were just<br=
>
&gt; locked.<br>
&gt;<br>
&gt; Cc: Dan Streetman &lt;<a href=3D"mailto:ddstreet@ieee.org" target=3D"_=
blank">ddstreet@ieee.org</a>&gt;<br>
<br>
I cc&#39;ed Vitaly also, as this code is from him, but the change<br>
certainly looks correct to me.<br>
<br>
Acked-by: Dan Streetman &lt;<a href=3D"mailto:ddstreet@ieee.org" target=3D"=
_blank">ddstreet@ieee.org</a>&gt;<br></blockquote><div><br></div><div>Acked=
-by: Vitaly Wool &lt;<a href=3D"mailto:vitalywool@gmail.com">vitalywool@gma=
il.com</a>&gt; <br></div><blockquote class=3D"gmail_quote" style=3D"margin:=
0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<br>
&gt; Signed-off-by: Alex Xu (Hello71) &lt;<a href=3D"mailto:alex_y_xu@yahoo=
.ca" target=3D"_blank">alex_y_xu@yahoo.ca</a>&gt;<br>
&gt; ---<br>
&gt;=C2=A0 mm/z3fold.c | 6 +++---<br>
&gt;=C2=A0 1 file changed, 3 insertions(+), 3 deletions(-)<br>
&gt;<br>
&gt; diff --git a/mm/z3fold.c b/mm/z3fold.c<br>
&gt; index 4b366d181..2e8d268ac 100644<br>
&gt; --- a/mm/z3fold.c<br>
&gt; +++ b/mm/z3fold.c<br>
&gt; @@ -277,7 +277,7 @@ static void release_z3fold_page_locked(struct kref=
 *ref)<br>
&gt;=C2=A0 {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct z3fold_header *zhdr =3D contai=
ner_of(ref, struct z3fold_header,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0refcount);<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0WARN_ON(z3fold_page_trylock(zhdr));<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0WARN_ON_SMP(z3fold_page_trylock(zhdr));<br=
>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__release_z3fold_page(zhdr, true);<br=
>
&gt;=C2=A0 }<br>
&gt;<br>
&gt; @@ -289,7 +289,7 @@ static void release_z3fold_page_locked_list(struct=
 kref *ref)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_del_init(&amp;zhdr-&gt;buddy);<b=
r>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&amp;zhdr-&gt;pool-&gt;lo=
ck);<br>
&gt;<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0WARN_ON(z3fold_page_trylock(zhdr));<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0WARN_ON_SMP(z3fold_page_trylock(zhdr));<br=
>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__release_z3fold_page(zhdr, true);<br=
>
&gt;=C2=A0 }<br>
&gt;<br>
&gt; @@ -403,7 +403,7 @@ static void do_compact_page(struct z3fold_header *=
zhdr, bool locked)<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D virt_to_page(zhdr);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (locked)<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0WARN_ON(z3fold=
_page_trylock(zhdr));<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0WARN_ON_SMP(z3=
fold_page_trylock(zhdr));<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0else<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0z3fold_pa=
ge_lock(zhdr);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (WARN_ON(!test_and_clear_bit(NEEDS=
_COMPACTING, &amp;page-&gt;private))) {<br>
&gt; --<br>
&gt; 2.19.0<br>
&gt;<br>
</blockquote></div></div>

--000000000000c360350576ecf5c0--
