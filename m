Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id B5A216B0038
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 18:02:02 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id x63so1207377ioe.18
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 15:02:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u35sor160007iou.218.2017.11.28.15.02.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Nov 2017 15:02:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+aRGC9vVaHCXmeEiL5ywjQRTK+yNn+TAWKPLB3Gpd4U_A@mail.gmail.com>
References: <1511841842-3786-1-git-send-email-zhouzhouyi@gmail.com>
 <CAABZP2zEup53ZcNKOEUEMx_aRMLONZdYCLd7s5J4DLTccPxC-A@mail.gmail.com>
 <CACT4Y+YE5POWUoDj2sUv2NDKeimTRyxCpg1yd7VpZnqeYJ+Qcg@mail.gmail.com>
 <CAABZP2zB8vKswQXicYq5r8iNOKz21CRyw1cUiB2s9O+ZMb+JvQ@mail.gmail.com>
 <CACT4Y+YkVbkwAm0h7UJH08woiohJT9EYObhxpE33dP0A4agtkw@mail.gmail.com>
 <CAABZP2zjoSDTNkn_qMqi+NCHOzzQZSj-LvfCjPy_tg-FZeUWZg@mail.gmail.com>
 <CACT4Y+ah6q-xoakyPL7v-+Knp8ZaFbnRRk_Ki6Wsmz3C8Pe8XQ@mail.gmail.com>
 <CAABZP2yS524XEiyu=kkVx7ff1ySTtE=WWETNDrZ_toEm0mwqyQ@mail.gmail.com>
 <CACT4Y+aAhHSW=qBFLy7S1wWLsJsjW83y8uC4nQy0N9Hf8HoMKQ@mail.gmail.com>
 <CAABZP2wxDxAHJ_f022Ha7gyffukgo0PPOv2uJQphwFXGO_fL1w@mail.gmail.com>
 <CACT4Y+bprRRzTD5DjSTZt8oobhYcD-eTOT_VwWwcTZBhRH1KUg@mail.gmail.com> <CACT4Y+aRGC9vVaHCXmeEiL5ywjQRTK+yNn+TAWKPLB3Gpd4U_A@mail.gmail.com>
From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Date: Wed, 29 Nov 2017 07:02:01 +0800
Message-ID: <CAABZP2xvWFOXZMGgNrnx5fDJGrXybrM3DXFEdymXf1RLD7STJA@mail.gmail.com>
Subject: Re: [PATCH 1/1] kasan: fix livelock in qlist_move_cache
Content-Type: multipart/alternative; boundary="001a113f08a8bb69c8055f130195"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

--001a113f08a8bb69c8055f130195
Content-Type: text/plain; charset="UTF-8"

hi,
     I will prepare the environment to let the phenonmenon reappear today
right after I reached my company.
Cheers

On Wednesday, November 29, 2017, Dmitry Vyukov <dvyukov@google.com> wrote:

> On Tue, Nov 28, 2017 at 6:56 PM, Dmitry Vyukov <dvyukov@google.com
> <javascript:;>> wrote:
> > On Tue, Nov 28, 2017 at 12:30 PM, Zhouyi Zhou <zhouzhouyi@gmail.com
> <javascript:;>> wrote:
> >> Hi,
> >>    By using perf top, qlist_move_cache occupies 100% cpu did really
> >> happen in my environment yesterday, or I
> >> won't notice the kasan code.
> >>    Currently I have difficulty to let it reappear because the frontend
> >> guy modified some user mode code.
> >>    I can repeat again and again now is
> >> kgdb_breakpoint () at kernel/debug/debug_core.c:1073
> >> 1073 wmb(); /* Sync point after breakpoint */
> >> (gdb) p quarantine_batch_size
> >> $1 = 3601946
> >>    And by instrument code, maximum
> >> global_quarantine[quarantine_tail].bytes reached is 6618208.
> >
> > On second thought, size does not matter too much because there can be
> > large objects. Quarantine always quantize by objects, we can't part of
> > an object into one batch, and another part of the object into another
> > object. But it's not a problem, because overhead per objects is O(1).
> > We can push a single 4MB object and overflow target size by 4MB and
> > that will be fine.
> > Either way, 6MB is not terribly much too. Should take milliseconds to
> process.
> >
> >
> >
> >
> >>    I do think drain quarantine right in quarantine_put is a better
> >> place to drain because cache_free is fine in
> >> that context. I am willing do it if you think it is convenient :-)
>
>
> Andrey, do you know of any problems with draining quarantine in push?
> Do you have any objections?
>
> But it's still not completely clear to me what problem we are solving.
>

--001a113f08a8bb69c8055f130195
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

hi,<div>=C2=A0 =C2=A0 =C2=A0I will prepare the environment to let the pheno=
nmenon reappear today right after I reached my company.</div><div>Cheers<br=
><br>On Wednesday, November 29, 2017, Dmitry Vyukov &lt;<a href=3D"mailto:d=
vyukov@google.com">dvyukov@google.com</a>&gt; wrote:<br><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex">On Tue, Nov 28, 2017 at 6:56 PM, Dmitry Vyukov &lt;<a href=3D=
"javascript:;" onclick=3D"_e(event, &#39;cvml&#39;, &#39;dvyukov@google.com=
&#39;)">dvyukov@google.com</a>&gt; wrote:<br>
&gt; On Tue, Nov 28, 2017 at 12:30 PM, Zhouyi Zhou &lt;<a href=3D"javascrip=
t:;" onclick=3D"_e(event, &#39;cvml&#39;, &#39;zhouzhouyi@gmail.com&#39;)">=
zhouzhouyi@gmail.com</a>&gt; wrote:<br>
&gt;&gt; Hi,<br>
&gt;&gt;=C2=A0 =C2=A0 By using perf top, qlist_move_cache occupies 100% cpu=
 did really<br>
&gt;&gt; happen in my environment yesterday, or I<br>
&gt;&gt; won&#39;t notice the kasan code.<br>
&gt;&gt;=C2=A0 =C2=A0 Currently I have difficulty to let it reappear becaus=
e the frontend<br>
&gt;&gt; guy modified some user mode code.<br>
&gt;&gt;=C2=A0 =C2=A0 I can repeat again and again now is<br>
&gt;&gt; kgdb_breakpoint () at kernel/debug/debug_core.c:1073<br>
&gt;&gt; 1073 wmb(); /* Sync point after breakpoint */<br>
&gt;&gt; (gdb) p quarantine_batch_size<br>
&gt;&gt; $1 =3D 3601946<br>
&gt;&gt;=C2=A0 =C2=A0 And by instrument code, maximum<br>
&gt;&gt; global_quarantine[quarantine_<wbr>tail].bytes reached is 6618208.<=
br>
&gt;<br>
&gt; On second thought, size does not matter too much because there can be<=
br>
&gt; large objects. Quarantine always quantize by objects, we can&#39;t par=
t of<br>
&gt; an object into one batch, and another part of the object into another<=
br>
&gt; object. But it&#39;s not a problem, because overhead per objects is O(=
1).<br>
&gt; We can push a single 4MB object and overflow target size by 4MB and<br=
>
&gt; that will be fine.<br>
&gt; Either way, 6MB is not terribly much too. Should take milliseconds to =
process.<br>
&gt;<br>
&gt;<br>
&gt;<br>
&gt;<br>
&gt;&gt;=C2=A0 =C2=A0 I do think drain quarantine right in quarantine_put i=
s a better<br>
&gt;&gt; place to drain because cache_free is fine in<br>
&gt;&gt; that context. I am willing do it if you think it is convenient :-)=
<br>
<br>
<br>
Andrey, do you know of any problems with draining quarantine in push?<br>
Do you have any objections?<br>
<br>
But it&#39;s still not completely clear to me what problem we are solving.<=
br>
</blockquote></div>

--001a113f08a8bb69c8055f130195--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
