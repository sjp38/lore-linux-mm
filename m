Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id D6F4C6B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 15:40:22 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id t139so19709245ywg.6
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 12:40:22 -0700 (PDT)
Received: from mail-yw0-x22c.google.com (mail-yw0-x22c.google.com. [2607:f8b0:4002:c05::22c])
        by mx.google.com with ESMTPS id a65si2225505ybb.41.2017.08.07.12.40.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 12:40:21 -0700 (PDT)
Received: by mail-yw0-x22c.google.com with SMTP id l82so8944344ywc.2
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 12:40:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jKD0Z=BKxKLDtjKq6sLgoa36bJZmc88k4QRPOHyRQp3BQ@mail.gmail.com>
References: <CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
 <CAGXu5jJhFt8JNFRnB-oiGjNy=Auo4bGx=i=DDtCa__20acANBQ@mail.gmail.com>
 <CAN=P9pj_jbTgGoiECmu-b=s+NOL6uTkPbXDueXLhs8C6PVbLHg@mail.gmail.com>
 <CAGXu5jLRG6Xee-dJGPwmbfcVFLuTP9+5mexJyvZamQQdSaHNtA@mail.gmail.com>
 <1502131739.1803.12.camel@gmail.com> <CAGXu5jKj0M55wK=0WE_uKJpiJ031J5jPVAZR-VA7_O2qJUi=BQ@mail.gmail.com>
 <CAN=P9pj0TSbwTogLAJrm=yszq+86X0EmXNK-0Oq9f7wQCkQRjA@mail.gmail.com>
 <CAGXu5jJOOvv=zgSWnKJOae0edKG8MUV1pto1ipijPiRsOdKr+Q@mail.gmail.com>
 <CAN=P9pgcuXUk=+TvFC83UT7xT66=X2ouvEEWxzVVeM2mC=Tk=g@mail.gmail.com>
 <CAGXu5jJNW5PYacSNrGGnyAxnv4cRuhbo+P9myHP9kcV7hMzhkA@mail.gmail.com>
 <CAN=P9ph4f3S3SwSpmpApKKnQ=ce6JXLcpqHG+oJ8EpmSiur0AA@mail.gmail.com>
 <CAGXu5j+x=vFrd7Owu=CgQcF7YtFAgPxUVo6G=Jzk6fo6mOQZqg@mail.gmail.com>
 <CAN=P9pg25a80so+RFxpUkm1=JAVtOj_T6CaO3GSZc2+A-PPk6A@mail.gmail.com> <CAGXu5jKD0Z=BKxKLDtjKq6sLgoa36bJZmc88k4QRPOHyRQp3BQ@mail.gmail.com>
From: Kostya Serebryany <kcc@google.com>
Date: Mon, 7 Aug 2017 12:40:20 -0700
Message-ID: <CAN=P9pi+8ufOFQJbKFDeAqHeBzBzvxsuG-dFD=_TpmRyU0vqmQ@mail.gmail.com>
Subject: Re: binfmt_elf: use ELF_ET_DYN_BASE only for PIE breaks asan
Content-Type: multipart/alternative; boundary="001a1147cb6c6fee2e05562f04c5"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Daniel Micay <danielmicay@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Reid Kleckner <rnk@google.com>, Peter Collingbourne <pcc@google.com>, Evgeniy Stepanov <eugenis@google.com>

--001a1147cb6c6fee2e05562f04c5
Content-Type: text/plain; charset="UTF-8"

On Mon, Aug 7, 2017 at 12:34 PM, Kees Cook <keescook@google.com> wrote:

> (To be clear, this subthread is for dealing with _future_ changes; I'm
> already preparing the revert, which is in the other subthread.)
>
> On Mon, Aug 7, 2017 at 12:26 PM, Kostya Serebryany <kcc@google.com> wrote:
> > Oh, a launcher (e.g. just using setarch) would be a huge pain to deploy.
>
> Would loading the executable into the mmap region work?


This is beyond my knowledge. :(
Could you explain?

If we can do this w/o a launcher (and w/o re-executing), we should try.



> We could find
> a way to mark executables that want this treatment.
>
> --
> Kees Cook
> Pixel Security
>

--001a1147cb6c6fee2e05562f04c5
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On Mon, Aug 7, 2017 at 12:34 PM, Kees Cook <span dir=3D"ltr">&lt;<a hre=
f=3D"mailto:keescook@google.com" target=3D"_blank">keescook@google.com</a>&=
gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 =
0 .8ex;border-left:1px #ccc solid;padding-left:1ex">(To be clear, this subt=
hread is for dealing with _future_ changes; I&#39;m<br>
already preparing the revert, which is in the other subthread.)<br>
<span class=3D""><br>
On Mon, Aug 7, 2017 at 12:26 PM, Kostya Serebryany &lt;<a href=3D"mailto:kc=
c@google.com">kcc@google.com</a>&gt; wrote:<br>
&gt; Oh, a launcher (e.g. just using setarch) would be a huge pain to deplo=
y.<br>
<br>
</span>Would loading the executable into the mmap region work? </blockquote=
><div><br></div><div>This is beyond my knowledge. :(=C2=A0</div><div>Could =
you explain?=C2=A0</div><div><br></div><div>If we can do this w/o a launche=
r (and w/o re-executing), we should try.=C2=A0</div><div><br></div><div>=C2=
=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;borde=
r-left:1px #ccc solid;padding-left:1ex">We could find<br>
a way to mark executables that want this treatment.<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br>
--<br>
Kees Cook<br>
Pixel Security<br>
</div></div></blockquote></div><br></div></div>

--001a1147cb6c6fee2e05562f04c5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
