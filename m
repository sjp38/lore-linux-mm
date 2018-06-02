Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id CAC386B0008
	for <linux-mm@kvack.org>; Sat,  2 Jun 2018 07:22:43 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id z144-v6so3859696lff.2
        for <linux-mm@kvack.org>; Sat, 02 Jun 2018 04:22:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w4-v6sor3033710ljw.103.2018.06.02.04.22.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 02 Jun 2018 04:22:42 -0700 (PDT)
MIME-Version: 1.0
References: <CAHCio2hrYo6f35cT69+xa5BwUXpwYXXm76GppUBB2WTrKonaFQ@mail.gmail.com>
 <20180602111940.GA31754@bombadil.infradead.org>
In-Reply-To: <20180602111940.GA31754@bombadil.infradead.org>
From: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Date: Sat, 2 Jun 2018 19:22:23 +0800
Message-ID: <CAHCio2iHGd6BF2jBHWWAbvtu38OY=Hs2EikWdESzELW_h47EoA@mail.gmail.com>
Subject: Re: [PATCH v7 1/2] Add an array of const char and enum oom_constraint
 in memcontrol.h
Content-Type: multipart/alternative; boundary="0000000000003baa15056da6ebcf"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

--0000000000003baa15056da6ebcf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Mattew
Please discard this email, and I will send another email again.

Thanks

Matthew Wilcox <willy@infradead.org> =E4=BA=8E2018=E5=B9=B46=E6=9C=882=E6=
=97=A5=E5=91=A8=E5=85=AD =E4=B8=8B=E5=8D=887:19=E5=86=99=E9=81=93=EF=BC=9A

> On Sat, Jun 02, 2018 at 07:06:44PM +0800, =E7=A6=B9=E8=88=9F=E9=94=AE wro=
te:
> > From: yuzhoujian <yuzhoujian@didichuxing.com>
> >
> > This patch will make some preparation for the follow-up patch: Refactor
> > part of the oom report in dump_header. It puts enum oom_constraint in
> > memcontrol.h and adds an array of const char for each constraint.
>
> This patch is whitespace damaged.  See the instructions for using git
> send-email with gmail: https://git-scm.com/docs/git-send-email
>
> > +static const char * const oom_constraint_text[] =3D {
> > + [CONSTRAINT_NONE] =3D "CONSTRAINT_NONE",
> > + [CONSTRAINT_CPUSET] =3D "CONSTRAINT_CPUSET",
> > + [CONSTRAINT_MEMORY_POLICY] =3D "CONSTRAINT_MEMORY_POLICY",
> > + [CONSTRAINT_MEMCG] =3D "CONSTRAINT_MEMCG",
> > +};
> > +
>
> Um, isn't this going to put the strings in every file which includes
> memcontrol.h?
>

--0000000000003baa15056da6ebcf
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Mattew<div>Please discard this email, and I will send a=
nother email again.=C2=A0</div><div><br></div><div>Thanks</div></div><br><d=
iv class=3D"gmail_quote"><div dir=3D"ltr">Matthew Wilcox &lt;<a href=3D"mai=
lto:willy@infradead.org">willy@infradead.org</a>&gt; =E4=BA=8E2018=E5=B9=B4=
6=E6=9C=882=E6=97=A5=E5=91=A8=E5=85=AD =E4=B8=8B=E5=8D=887:19=E5=86=99=E9=
=81=93=EF=BC=9A<br></div><blockquote class=3D"gmail_quote" style=3D"margin:=
0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">On Sat, Jun 02, 201=
8 at 07:06:44PM +0800, =E7=A6=B9=E8=88=9F=E9=94=AE wrote:<br>
&gt; From: yuzhoujian &lt;<a href=3D"mailto:yuzhoujian@didichuxing.com" tar=
get=3D"_blank">yuzhoujian@didichuxing.com</a>&gt;<br>
&gt; <br>
&gt; This patch will make some preparation for the follow-up patch: Refacto=
r<br>
&gt; part of the oom report in dump_header. It puts enum oom_constraint in<=
br>
&gt; memcontrol.h and adds an array of const char for each constraint.<br>
<br>
This patch is whitespace damaged.=C2=A0 See the instructions for using git<=
br>
send-email with gmail: <a href=3D"https://git-scm.com/docs/git-send-email" =
rel=3D"noreferrer" target=3D"_blank">https://git-scm.com/docs/git-send-emai=
l</a><br>
<br>
&gt; +static const char * const oom_constraint_text[] =3D {<br>
&gt; + [CONSTRAINT_NONE] =3D &quot;CONSTRAINT_NONE&quot;,<br>
&gt; + [CONSTRAINT_CPUSET] =3D &quot;CONSTRAINT_CPUSET&quot;,<br>
&gt; + [CONSTRAINT_MEMORY_POLICY] =3D &quot;CONSTRAINT_MEMORY_POLICY&quot;,=
<br>
&gt; + [CONSTRAINT_MEMCG] =3D &quot;CONSTRAINT_MEMCG&quot;,<br>
&gt; +};<br>
&gt; +<br>
<br>
Um, isn&#39;t this going to put the strings in every file which includes<br=
>
memcontrol.h?<br>
</blockquote></div>

--0000000000003baa15056da6ebcf--
