Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 288056B0033
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 11:20:50 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id v187so1660374ybv.23
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 08:20:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j8sor4603312ywm.56.2017.12.04.08.20.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Dec 2017 08:20:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <33f13b1a-494c-67d5-a470-294867c06f9a@virtuozzo.com>
References: <20171201213643.2506-1-paullawrence@google.com>
 <20171201213643.2506-3-paullawrence@google.com> <33f13b1a-494c-67d5-a470-294867c06f9a@virtuozzo.com>
From: Paul Lawrence <paullawrence@google.com>
Date: Mon, 4 Dec 2017 08:20:47 -0800
Message-ID: <CAL=UVf7LO5BDWVEeLXLkrLDBxwV0aO2sLv_htkpcL_Gp7sT07Q@mail.gmail.com>
Subject: Re: [PATCH v3 2/5] kasan/Makefile: Support LLVM style asan parameters.
Content-Type: multipart/alternative; boundary="94eb2c129ab0e9b54a055f86191b"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>

--94eb2c129ab0e9b54a055f86191b
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 4, 2017 at 8:14 AM, Andrey Ryabinin <aryabinin@virtuozzo.com>
wrote:

>
> On 12/02/2017 12:36 AM, Paul Lawrence wrote:
> >
>
> Missing:
>         From: Andrey Ryabinin <aryabinin@virtuozzo.com>
>
> Please, don't change authorship of the patches.


=E2=80=8BSorry - I'll fix this when I next upload.=E2=80=8B

>
> > LLVM doesn't understand GCC-style paramters ("--param asan-foo=3Dbar"),
> > thus we currently we don't use inline/globals/stack instrumentation
> > when building the kernel with clang.
> >
> > Add support for LLVM-style parameters ("-mllvm -asan-foo=3Dbar") to
> > enable all KASAN features.
> >
> > Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> > ---
> >  scripts/Makefile.kasan | 29 ++++++++++++++++++-----------
> >  1 file changed, 18 insertions(+), 11 deletions(-)
> >
> > diff --git a/scripts/Makefile.kasan b/scripts/Makefile.kasan
> > index 1ce7115aa499..7c00be9216f4 100644
> > --- a/scripts/Makefile.kasan
> > +++ b/scripts/Makefile.kasan
> > @@ -10,10 +10,7 @@ KASAN_SHADOW_OFFSET ?=3D $(CONFIG_KASAN_SHADOW_OFFSE=
T)
> >
>
>
>
> > +   # -fasan-shadow-offset fails without -fsanitize
> > +   CFLAGS_KASAN_SHADOW :=3D $(call cc-option, -fsanitize=3Dkernel-addr=
ess \
> > +                     -fasan-shadow-offset=3D$(KASAN_SHADOW_OFFSET), \
> > +                     $(call cc-option, -fsanitize=3Dkernel-address \
> > +                     -mllvm -asan-mapping-offset=3D$(KASAN_
> SHADOW_OFFSET)))
> > +
> > +   ifeq ("$(CFLAGS_KASAN_SHADOW)"," ")
>
> This not how it was in my original patch. Why you changed this?
> Condition is always false now, so it breaks kasan with 4.9.x gcc.
>

=E2=80=8BI had the opposite problem - CFLAGS_KASAN_SHADOW is always at leas=
t a
space, and the
original condition would always be false, which is why I changed it.=E2=80=
=8B On
investigation, I found
that if the line was split it would always be a space -
$(false,whatever,empty-string) would be
truly empty, but if the line was split after the second comma it would be
one space. Is this a
difference in our make systems?


> > +      CFLAGS_KASAN :=3D $(CFLAGS_KASAN_MINIMAL)
> > +   else
> > +      # Now add all the compiler specific options that are valid
> standalone
> > +      CFLAGS_KASAN :=3D $(CFLAGS_KASAN_SHADOW) \
> > +     $(call cc-param,asan-globals=3D1) \
>

--94eb2c129ab0e9b54a055f86191b
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_default" style=3D"font-family:tahoma,s=
ans-serif;font-size:small"><span style=3D"font-family:arial,sans-serif">On =
Mon, Dec 4, 2017 at 8:14 AM, Andrey Ryabinin </span><span dir=3D"ltr" style=
=3D"font-family:arial,sans-serif">&lt;<a href=3D"mailto:aryabinin@virtuozzo=
.com" target=3D"_blank">aryabinin@virtuozzo.com</a>&gt;</span><span style=
=3D"font-family:arial,sans-serif"> wrote:</span><br></div><div class=3D"gma=
il_extra"><div class=3D"gmail_quote"><blockquote class=3D"gmail_quote" styl=
e=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><br>
On 12/02/2017 12:36 AM, Paul Lawrence wrote:<br>
&gt;<br>
<br>
Missing:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 From: Andrey Ryabinin &lt;<a href=3D"mailto:ary=
abinin@virtuozzo.com">aryabinin@virtuozzo.com</a>&gt;<br>
<br>
Please, don&#39;t change authorship of the patches.</blockquote><div><br></=
div><div class=3D"gmail_default" style=3D"font-family:tahoma,sans-serif;fon=
t-size:small">=E2=80=8BSorry - I&#39;ll fix this when I next upload.=E2=80=
=8B</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;borde=
r-left:1px #ccc solid;padding-left:1ex"><span class=3D""><br>
&gt; LLVM doesn&#39;t understand GCC-style paramters (&quot;--param asan-fo=
o=3Dbar&quot;),<br>
&gt; thus we currently we don&#39;t use inline/globals/stack instrumentatio=
n<br>
&gt; when building the kernel with clang.<br>
&gt;<br>
&gt; Add support for LLVM-style parameters (&quot;-mllvm -asan-foo=3Dbar&qu=
ot;) to<br>
&gt; enable all KASAN features.<br>
&gt;<br>
&gt; Signed-off-by: Andrey Ryabinin &lt;<a href=3D"mailto:aryabinin@virtuoz=
zo.com">aryabinin@virtuozzo.com</a>&gt;<br>
&gt; ---<br>
&gt;=C2=A0 scripts/Makefile.kasan | 29 ++++++++++++++++++-----------<br>
&gt;=C2=A0 1 file changed, 18 insertions(+), 11 deletions(-)<br>
&gt;<br>
&gt; diff --git a/scripts/Makefile.kasan b/scripts/Makefile.kasan<br>
&gt; index 1ce7115aa499..7c00be9216f4 100644<br>
&gt; --- a/scripts/Makefile.kasan<br>
&gt; +++ b/scripts/Makefile.kasan<br>
&gt; @@ -10,10 +10,7 @@ KASAN_SHADOW_OFFSET ?=3D $(CONFIG_KASAN_SHADOW_OFFS=
ET)<br>
&gt;<br>
<br>
<br>
<br>
</span><span class=3D"">&gt; +=C2=A0 =C2=A0# -fasan-shadow-offset fails wit=
hout -fsanitize<br>
&gt; +=C2=A0 =C2=A0CFLAGS_KASAN_SHADOW :=3D $(call cc-option, -fsanitize=3D=
kernel-address \<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0-fasan-shadow-offset=3D$(KASAN_<wbr>SHADOW_OFFSET), \<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0$(call cc-option, -fsanitize=3Dkernel-address \<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0-mllvm -asan-mapping-offset=3D$(KASAN_<wbr>SHADOW_OFFSET)))<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0ifeq (&quot;$(CFLAGS_KASAN_SHADOW)&quot;,&quot; &quot;)<=
br>
<br>
</span>This not how it was in my original patch. Why you changed this?<br>
Condition is always false now, so it breaks kasan with 4.9.x gcc.<br></bloc=
kquote><div><br></div><div class=3D"gmail_default" style=3D"font-family:tah=
oma,sans-serif;font-size:small">=E2=80=8BI had the opposite problem - CFLAG=
S_KASAN_SHADOW is always at least a space, and the</div><div class=3D"gmail=
_default" style=3D"font-family:tahoma,sans-serif;font-size:small">original =
condition would always be false, which is why I changed it.=E2=80=8B On inv=
estigation, I found=C2=A0</div><div class=3D"gmail_default" style=3D"font-f=
amily:tahoma,sans-serif;font-size:small">that if the line was split it woul=
d always be a space - $(false,whatever,empty-string) would be</div><div cla=
ss=3D"gmail_default" style=3D"font-family:tahoma,sans-serif;font-size:small=
">truly empty, but if the line was split after the second comma it would be=
 one space. Is this a</div><div class=3D"gmail_default" style=3D"font-famil=
y:tahoma,sans-serif;font-size:small">difference in our make systems?</div><=
div class=3D"gmail_default" style=3D"font-family:tahoma,sans-serif;font-siz=
e:small"><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 =
.8ex;border-left:1px #ccc solid;padding-left:1ex">
<div class=3D"HOEnZb"><div class=3D"h5"><br>
&gt; +=C2=A0 =C2=A0 =C2=A0 CFLAGS_KASAN :=3D $(CFLAGS_KASAN_MINIMAL)<br>
&gt; +=C2=A0 =C2=A0else<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 # Now add all the compiler specific options that=
 are valid standalone<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 CFLAGS_KASAN :=3D $(CFLAGS_KASAN_SHADOW) \<br>
&gt; +=C2=A0 =C2=A0 =C2=A0$(call cc-param,asan-globals=3D1) \<br>
</div></div></blockquote></div><br></div></div>

--94eb2c129ab0e9b54a055f86191b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
