Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 69BA78E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 03:55:04 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id g4so7142609otl.14
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 00:55:04 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d132sor6784751oia.8.2018.12.17.00.55.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Dec 2018 00:55:03 -0800 (PST)
MIME-Version: 1.0
References: <CAKhyrx-gbHjzWyeUERrXhH2CGMEMZeFX66Q-POD7Q+hKwWA1kw@mail.gmail.com>
 <20181217084836.GA22890@rapoport-lnx>
In-Reply-To: <20181217084836.GA22890@rapoport-lnx>
From: vijay nag <vijunag@gmail.com>
Date: Mon, 17 Dec 2018 14:24:49 +0530
Message-ID: <CAKhyrx8E+43Ddqq7eBD3eomKp-GYeqehmo_G7ZO=d+oAi7GOqQ@mail.gmail.com>
Subject: Re: Cgroups support for THP
Content-Type: multipart/alternative; boundary="000000000000c94a0f057d33efc8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.ibm.com
Cc: linux-mm@kvack.org

--000000000000c94a0f057d33efc8
Content-Type: text/plain; charset="UTF-8"

On Mon, Dec 17, 2018 at 2:18 PM Mike Rapoport <rppt@linux.ibm.com> wrote:

> On Mon, Dec 17, 2018 at 01:56:40PM +0530, vijay nag wrote:
> > Hello Linux-MM,
> >
> > My containerized application which is suppose to have a very low RSS(by
> default
> > containers patterns are to have low memory footprint) seems to be
> getting its
> > BSS segment RSS bloated due to THPs. Although there is a huge zero page
> > support, the overhead seems to be at-least 2MB even when a byte is
> dirtied.
> > Also there are tune-able to disable this feature,  but this seems to be a
> > system wide setting. Is there a plan to make this setting cgroup aware ?
>
> It's possible to control THP on per-mapping using madvise(MADV_NOHUGEPAGE)
> and per-process using prctl(PR_SET_THP_DISABLE).
>
> > Thanks,
> > Vijay Nag
>
> --
> Sincerely yours,
> Mike.
>
> Thanks for letting me know of this setting. However, there could be a
third party daemons/processes that have THP in them. Do you think it is a
good idea to make it cgroup aware ?

--000000000000c94a0f057d33efc8
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><br><div class=3D"gmail_quote"><div dir=3D"ltr">On Mon=
, Dec 17, 2018 at 2:18 PM Mike Rapoport &lt;<a href=3D"mailto:rppt@linux.ib=
m.com">rppt@linux.ibm.com</a>&gt; wrote:<br></div><blockquote class=3D"gmai=
l_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,20=
4,204);padding-left:1ex">On Mon, Dec 17, 2018 at 01:56:40PM +0530, vijay na=
g wrote:<br>
&gt; Hello Linux-MM,<br>
&gt; <br>
&gt; My containerized application which is suppose to have a very low RSS(b=
y default<br>
&gt; containers patterns are to have low memory footprint) seems to be gett=
ing its<br>
&gt; BSS segment RSS bloated due to THPs. Although there is a huge zero pag=
e<br>
&gt; support, the overhead seems to be at-least 2MB even when a byte is dir=
tied.<br>
&gt; Also there are tune-able to disable this feature,=C2=A0 but this seems=
 to be a<br>
&gt; system wide setting. Is there a plan to make this setting cgroup aware=
 ?<br>
<br>
It&#39;s possible to control THP on per-mapping using madvise(MADV_NOHUGEPA=
GE)<br>
and per-process using prctl(PR_SET_THP_DISABLE). <br>
<br>
&gt; Thanks,<br>
&gt; Vijay Nag<br>
<br>
-- <br>
Sincerely yours,<br>
Mike.<br>
<br></blockquote><div>Thanks for letting me know of this setting. However, =
there could be a third party daemons/processes that have THP in them. Do yo=
u think it is a good idea to make it cgroup aware ? <br></div></div></div>

--000000000000c94a0f057d33efc8--
