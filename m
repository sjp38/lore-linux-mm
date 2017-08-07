Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id A64276B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 15:16:03 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id n83so18546213ywn.10
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 12:16:03 -0700 (PDT)
Received: from mail-yw0-x22f.google.com (mail-yw0-x22f.google.com. [2607:f8b0:4002:c05::22f])
        by mx.google.com with ESMTPS id l127si1838105ywg.306.2017.08.07.12.16.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 12:16:02 -0700 (PDT)
Received: by mail-yw0-x22f.google.com with SMTP id p68so8658778ywg.0
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 12:16:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJNW5PYacSNrGGnyAxnv4cRuhbo+P9myHP9kcV7hMzhkA@mail.gmail.com>
References: <CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
 <CAGXu5jJhFt8JNFRnB-oiGjNy=Auo4bGx=i=DDtCa__20acANBQ@mail.gmail.com>
 <CAN=P9pj_jbTgGoiECmu-b=s+NOL6uTkPbXDueXLhs8C6PVbLHg@mail.gmail.com>
 <CAGXu5jLRG6Xee-dJGPwmbfcVFLuTP9+5mexJyvZamQQdSaHNtA@mail.gmail.com>
 <1502131739.1803.12.camel@gmail.com> <CAGXu5jKj0M55wK=0WE_uKJpiJ031J5jPVAZR-VA7_O2qJUi=BQ@mail.gmail.com>
 <CAN=P9pj0TSbwTogLAJrm=yszq+86X0EmXNK-0Oq9f7wQCkQRjA@mail.gmail.com>
 <CAGXu5jJOOvv=zgSWnKJOae0edKG8MUV1pto1ipijPiRsOdKr+Q@mail.gmail.com>
 <CAN=P9pgcuXUk=+TvFC83UT7xT66=X2ouvEEWxzVVeM2mC=Tk=g@mail.gmail.com> <CAGXu5jJNW5PYacSNrGGnyAxnv4cRuhbo+P9myHP9kcV7hMzhkA@mail.gmail.com>
From: Kostya Serebryany <kcc@google.com>
Date: Mon, 7 Aug 2017 12:16:01 -0700
Message-ID: <CAN=P9ph4f3S3SwSpmpApKKnQ=ce6JXLcpqHG+oJ8EpmSiur0AA@mail.gmail.com>
Subject: Re: binfmt_elf: use ELF_ET_DYN_BASE only for PIE breaks asan
Content-Type: multipart/alternative; boundary="94eb2c05e1467891b305562ead56"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Daniel Micay <danielmicay@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Reid Kleckner <rnk@google.com>, Peter Collingbourne <pcc@google.com>, Evgeniy Stepanov <eugenis@google.com>

--94eb2c05e1467891b305562ead56
Content-Type: text/plain; charset="UTF-8"

On Mon, Aug 7, 2017 at 12:12 PM, Kees Cook <keescook@google.com> wrote:

> On Mon, Aug 7, 2017 at 12:05 PM, Kostya Serebryany <kcc@google.com> wrote:
> >
> >
> > On Mon, Aug 7, 2017 at 11:59 AM, Kees Cook <keescook@google.com> wrote:
> >>
> >> On Mon, Aug 7, 2017 at 11:56 AM, Kostya Serebryany <kcc@google.com>
> wrote:
> >> > Is it possible to implement some userspace<=>kernel interface that
> will
> >> > allow applications (sanitizers)
> >> > to request *fixed* address ranges from the kernel at startup (so that
> >> > the
> >> > kernel couldn't refuse)?
> >>
> >> Wouldn't building non-PIE accomplish this?
> >
> >
> > Well, many asan users do need PIE.
> > Then, non-PIE only applies to the main executable, all DSOs are still
> > PIC and the old change that moved DSOs from 0x7fff to 0x5555 caused us
> quite
> > a bit of trouble too, even w/o PIE
>
> Hm? You can build non-PIE executables leaving all the DSOs PIC.
>

Yes, but this won't help if the users actually want PIE executables.


>
> If what you want is to entirely disable userspace ASLR under *San, you
> can just set the ADDR_NO_RANDOMIZE personality flag.
>

Mmm. How? Could you please elaborate?
Do you suggest to call personality(ADDR_NO_RANDOMIZE) and re-execute the
process?
Or can I somehow set ADDR_NO_RANDOMIZE at link time?


>
> -Kees
>
> --
> Kees Cook
> Pixel Security
>

--94eb2c05e1467891b305562ead56
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On Mon, Aug 7, 2017 at 12:12 PM, Kees Cook <span dir=3D"ltr">&lt;<a hre=
f=3D"mailto:keescook@google.com" target=3D"_blank">keescook@google.com</a>&=
gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0px =
0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex"><spa=
n class=3D"gmail-">On Mon, Aug 7, 2017 at 12:05 PM, Kostya Serebryany &lt;<=
a href=3D"mailto:kcc@google.com">kcc@google.com</a>&gt; wrote:<br>
&gt;<br>
&gt;<br>
&gt; On Mon, Aug 7, 2017 at 11:59 AM, Kees Cook &lt;<a href=3D"mailto:keesc=
ook@google.com">keescook@google.com</a>&gt; wrote:<br>
&gt;&gt;<br>
&gt;&gt; On Mon, Aug 7, 2017 at 11:56 AM, Kostya Serebryany &lt;<a href=3D"=
mailto:kcc@google.com">kcc@google.com</a>&gt; wrote:<br>
&gt;&gt; &gt; Is it possible to implement some userspace&lt;=3D&gt;kernel i=
nterface that will<br>
&gt;&gt; &gt; allow applications (sanitizers)<br>
&gt;&gt; &gt; to request *fixed* address ranges from the kernel at startup =
(so that<br>
&gt;&gt; &gt; the<br>
&gt;&gt; &gt; kernel couldn&#39;t refuse)?<br>
&gt;&gt;<br>
&gt;&gt; Wouldn&#39;t building non-PIE accomplish this?<br>
&gt;<br>
&gt;<br>
&gt; Well, many asan users do need PIE.<br>
&gt; Then, non-PIE only applies to the main executable, all DSOs are still<=
br>
&gt; PIC and the old change that moved DSOs from 0x7fff to 0x5555 caused us=
 quite<br>
&gt; a bit of trouble too, even w/o PIE<br>
<br>
</span>Hm? You can build non-PIE executables leaving all the DSOs PIC.<br><=
/blockquote><div><br></div><div>Yes, but this won&#39;t help if the users a=
ctually want PIE executables.=C2=A0</div><div>=C2=A0</div><blockquote class=
=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rg=
b(204,204,204);padding-left:1ex">
<br>
If what you want is to entirely disable userspace ASLR under *San, you<br>
can just set the ADDR_NO_RANDOMIZE personality flag.<br></blockquote><div><=
br></div><div>Mmm. How? Could you please elaborate?=C2=A0</div>Do you sugge=
st to call personality(ADDR_NO_RANDOMIZE) and re-execute the process?=C2=A0=
</div><div class=3D"gmail_quote">Or can I somehow set ADDR_NO_RANDOMIZE at =
link time?=C2=A0<br></div><div class=3D"gmail_quote"><div>=C2=A0</div><bloc=
kquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:=
1px solid rgb(204,204,204);padding-left:1ex">
<div class=3D"gmail-HOEnZb"><div class=3D"gmail-h5"><br>
-Kees<br>
<br>
--<br>
Kees Cook<br>
Pixel Security<br>
</div></div></blockquote></div><br></div></div>

--94eb2c05e1467891b305562ead56--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
