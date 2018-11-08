Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 165556B0585
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 22:08:53 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id r14-v6so21499030ioc.7
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 19:08:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u19-v6sor1301708ioc.24.2018.11.07.19.08.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Nov 2018 19:08:52 -0800 (PST)
MIME-Version: 1.0
References: <20181107100247.13359-1-rainccrun@gmail.com> <20181107102549.GB27423@dhcp22.suse.cz>
 <20181107135421.GA5638@rapoport-lnx> <20181107141306.GF27423@dhcp22.suse.cz>
 <20181107143703.GB5638@rapoport-lnx> <20181107150312.GH27423@dhcp22.suse.cz>
In-Reply-To: <20181107150312.GH27423@dhcp22.suse.cz>
From: cc <rainccrun@gmail.com>
Date: Thu, 8 Nov 2018 11:08:39 +0800
Message-ID: <CAHOjbkHpUurp_Ca+163F6JVtRbfc8SRbMssvah9EVTxgNPCGJA@mail.gmail.com>
Subject: Re: [PATCH] mm: Fix a typo in __next_mem_pfn_range() comments.
Content-Type: multipart/alternative; boundary="000000000000e7785f057a1e8df6"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: rppt@linux.ibm.com, akpm@linux-foundation.org, rppt@linux.vnet.ibm.com, pasha.tatashin@oracle.com, Jonathan Corbet <corbet@lwn.net>, stefan@agner.ch, malat@debian.org, neelx@redhat.com, andriy.shevchenko@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--000000000000e7785f057a1e8df6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Thanks for all your replies=EF=BC=8Ci am a newbie here.

Michal Hocko <mhocko@suse.com> =E4=BA=8E2018=E5=B9=B411=E6=9C=887=E6=97=A5=
=E5=91=A8=E4=B8=89 =E4=B8=8B=E5=8D=8811:03=E5=86=99=E9=81=93=EF=BC=9A

> On Wed 07-11-18 16:37:05, Mike Rapoport wrote:
> > On Wed, Nov 07, 2018 at 03:13:06PM +0100, Michal Hocko wrote:
> > > On Wed 07-11-18 15:54:22, Mike Rapoport wrote:
> > > > On Wed, Nov 07, 2018 at 11:25:49AM +0100, Michal Hocko wrote:
> > > > > On Wed 07-11-18 18:02:47, Chen Chang wrote:
> > > > > > mm: Fix a typo in __next_mem_pfn_range() comments.
> > > > >
> > > > > those two names are just too similar. And I wouldn't be surprised
> if
> > > > > there was a considerable overlap in functionality which just asks
> for
> > > > > a unification. In a separate patch of course.
> > > >
> > > > There is an overlap, but I'm not sure if the unification is straigh=
t
> > > > forward. The for_each_mem_pfn_range() is really simple iterator,
> while
> > > > for_each_mem_range() has additional logic based on memblock flags.
> > >
> > > Is there any reason we cannot emulate the former by later by type_b =
=3D
> > > NULL and flags=3D0?
> >
> > Mostly. There's a hotplug related check:
> >
> >       /* skip hotpluggable memory regions if needed */
> >       if (movable_node_is_enabled() && memblock_is_hotpluggable(m))
> >               continue;
> >
> > in __next_mem_range() that is not related to flags and type_b and I don=
't
> > understand hotplug enough to tell.
> >
> > Maybe this check can become
> >
> >       /* skip hotpluggable memory regions if needed */
> >         if ((flags & MEMBLOCK_HOTPLUG) && movable_node_is_enabled() &&
> >            memblock_is_hotpluggable(m))
> >                 continue;
> >
> > and then using flags=3D0 and type_b=3DNULL would be possible.
>
> OK, let's discuss this in a separate thread. A simlification in this
> area is always welcome ;)
>
> --
> Michal Hocko
> SUSE Labs
>

--000000000000e7785f057a1e8df6
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr">Thanks for all your replies=EF=BC=8Ci am =
a newbie here.</div></div><br><div class=3D"gmail_quote"><div dir=3D"ltr">M=
ichal Hocko &lt;<a href=3D"mailto:mhocko@suse.com">mhocko@suse.com</a>&gt; =
=E4=BA=8E2018=E5=B9=B411=E6=9C=887=E6=97=A5=E5=91=A8=E4=B8=89 =E4=B8=8B=E5=
=8D=8811:03=E5=86=99=E9=81=93=EF=BC=9A<br></div><blockquote class=3D"gmail_=
quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1=
ex">On Wed 07-11-18 16:37:05, Mike Rapoport wrote:<br>
&gt; On Wed, Nov 07, 2018 at 03:13:06PM +0100, Michal Hocko wrote:<br>
&gt; &gt; On Wed 07-11-18 15:54:22, Mike Rapoport wrote:<br>
&gt; &gt; &gt; On Wed, Nov 07, 2018 at 11:25:49AM +0100, Michal Hocko wrote=
:<br>
&gt; &gt; &gt; &gt; On Wed 07-11-18 18:02:47, Chen Chang wrote:<br>
&gt; &gt; &gt; &gt; &gt; mm: Fix a typo in __next_mem_pfn_range() comments.=
<br>
&gt; &gt; &gt; &gt; <br>
&gt; &gt; &gt; &gt; those two names are just too similar. And I wouldn&#39;=
t be surprised if<br>
&gt; &gt; &gt; &gt; there was a considerable overlap in functionality which=
 just asks for<br>
&gt; &gt; &gt; &gt; a unification. In a separate patch of course.<br>
&gt; &gt; &gt; <br>
&gt; &gt; &gt; There is an overlap, but I&#39;m not sure if the unification=
 is straight<br>
&gt; &gt; &gt; forward. The for_each_mem_pfn_range() is really simple itera=
tor, while<br>
&gt; &gt; &gt; for_each_mem_range() has additional logic based on memblock =
flags.<br>
&gt; &gt; <br>
&gt; &gt; Is there any reason we cannot emulate the former by later by type=
_b =3D<br>
&gt; &gt; NULL and flags=3D0?<br>
&gt; <br>
&gt; Mostly. There&#39;s a hotplug related check:<br>
&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0/* skip hotpluggable memory regions if neede=
d */<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0if (movable_node_is_enabled() &amp;&amp; mem=
block_is_hotpluggable(m))<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0continue;<br>
&gt; <br>
&gt; in __next_mem_range() that is not related to flags and type_b and I do=
n&#39;t<br>
&gt; understand hotplug enough to tell.<br>
&gt; <br>
&gt; Maybe this check can become<br>
&gt; <br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0/* skip hotpluggable memory regions if neede=
d */<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((flags &amp; MEMBLOCK_HOTPLUG) &a=
mp;&amp; movable_node_is_enabled() &amp;&amp;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memblock_is_hotpluggable(m))<=
br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0continue;=
<br>
&gt; <br>
&gt; and then using flags=3D0 and type_b=3DNULL would be possible.<br>
<br>
OK, let&#39;s discuss this in a separate thread. A simlification in this<br=
>
area is always welcome ;)<br>
<br>
-- <br>
Michal Hocko<br>
SUSE Labs<br>
</blockquote></div>

--000000000000e7785f057a1e8df6--
