Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id DCA026B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 15:05:42 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id c13so18811517ywa.2
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 12:05:42 -0700 (PDT)
Received: from mail-yw0-x22a.google.com (mail-yw0-x22a.google.com. [2607:f8b0:4002:c05::22a])
        by mx.google.com with ESMTPS id w7si1710221ybw.658.2017.08.07.12.05.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 12:05:42 -0700 (PDT)
Received: by mail-yw0-x22a.google.com with SMTP id s143so8430453ywg.1
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 12:05:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJOOvv=zgSWnKJOae0edKG8MUV1pto1ipijPiRsOdKr+Q@mail.gmail.com>
References: <CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
 <CAGXu5jJhFt8JNFRnB-oiGjNy=Auo4bGx=i=DDtCa__20acANBQ@mail.gmail.com>
 <CAN=P9pj_jbTgGoiECmu-b=s+NOL6uTkPbXDueXLhs8C6PVbLHg@mail.gmail.com>
 <CAGXu5jLRG6Xee-dJGPwmbfcVFLuTP9+5mexJyvZamQQdSaHNtA@mail.gmail.com>
 <1502131739.1803.12.camel@gmail.com> <CAGXu5jKj0M55wK=0WE_uKJpiJ031J5jPVAZR-VA7_O2qJUi=BQ@mail.gmail.com>
 <CAN=P9pj0TSbwTogLAJrm=yszq+86X0EmXNK-0Oq9f7wQCkQRjA@mail.gmail.com> <CAGXu5jJOOvv=zgSWnKJOae0edKG8MUV1pto1ipijPiRsOdKr+Q@mail.gmail.com>
From: Kostya Serebryany <kcc@google.com>
Date: Mon, 7 Aug 2017 12:05:40 -0700
Message-ID: <CAN=P9pgcuXUk=+TvFC83UT7xT66=X2ouvEEWxzVVeM2mC=Tk=g@mail.gmail.com>
Subject: Re: binfmt_elf: use ELF_ET_DYN_BASE only for PIE breaks asan
Content-Type: multipart/alternative; boundary="001a114dd15e76999405562e88c9"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Daniel Micay <danielmicay@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Reid Kleckner <rnk@google.com>, Peter Collingbourne <pcc@google.com>, Evgeniy Stepanov <eugenis@google.com>

--001a114dd15e76999405562e88c9
Content-Type: text/plain; charset="UTF-8"

On Mon, Aug 7, 2017 at 11:59 AM, Kees Cook <keescook@google.com> wrote:

> On Mon, Aug 7, 2017 at 11:56 AM, Kostya Serebryany <kcc@google.com> wrote:
> > Is it possible to implement some userspace<=>kernel interface that will
> > allow applications (sanitizers)
> > to request *fixed* address ranges from the kernel at startup (so that the
> > kernel couldn't refuse)?
>
> Wouldn't building non-PIE accomplish this?
>

Well, many asan users do need PIE.
Then, non-PIE only applies to the main executable, all DSOs are still
PIC and the old change that moved DSOs from 0x7fff to 0x5555 caused us
quite a bit of trouble too, even w/o PIE


>
> -Kees
>
> --
> Kees Cook
> Pixel Security
>

--001a114dd15e76999405562e88c9
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On Mon, Aug 7, 2017 at 11:59 AM, Kees Cook <span dir=3D"ltr">&lt;<a hre=
f=3D"mailto:keescook@google.com" target=3D"_blank">keescook@google.com</a>&=
gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 =
0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><span class=3D"">On Mon=
, Aug 7, 2017 at 11:56 AM, Kostya Serebryany &lt;<a href=3D"mailto:kcc@goog=
le.com">kcc@google.com</a>&gt; wrote:<br>
&gt; Is it possible to implement some userspace&lt;=3D&gt;kernel interface =
that will<br>
&gt; allow applications (sanitizers)<br>
&gt; to request *fixed* address ranges from the kernel at startup (so that =
the<br>
&gt; kernel couldn&#39;t refuse)?<br>
<br>
</span>Wouldn&#39;t building non-PIE accomplish this?<br></blockquote><div>=
<br></div><div>Well, many asan users do need PIE.=C2=A0</div><div>Then, non=
-PIE only applies to the main executable, all DSOs are still=C2=A0</div><di=
v>PIC and the old change that moved DSOs from 0x7fff to 0x5555 caused us qu=
ite a bit of trouble too, even w/o PIE</div><div>=C2=A0</div><blockquote cl=
ass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;p=
adding-left:1ex">
<div class=3D"HOEnZb"><div class=3D"h5"><br>
-Kees<br>
<br>
--<br>
Kees Cook<br>
Pixel Security<br>
</div></div></blockquote></div><br></div></div>

--001a114dd15e76999405562e88c9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
