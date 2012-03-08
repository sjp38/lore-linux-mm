Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 747C86B007E
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 11:32:55 -0500 (EST)
Received: by obbta14 with SMTP id ta14so1128011obb.14
        for <linux-mm@kvack.org>; Thu, 08 Mar 2012 08:32:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120308161318.GA9904@gmail.com>
References: <xr93haxzo59m.fsf@gthelen.mtv.corp.google.com>
	<20120308161318.GA9904@gmail.com>
Date: Fri, 9 Mar 2012 00:32:54 +0800
Message-ID: <CAC8teKUqOa=qoct86xfbnUXxwuOsDDw0YiAOHPv3wqa22EPfTw@mail.gmail.com>
Subject: Re: Control page reclaim granularity
From: Zhu Yanhai <zhu.yanhai@gmail.com>
Content-Type: multipart/alternative; boundary=14dae93b590ef6607704babdd389
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, gnehzuil gnehzuil <gnehzuil@gmail.com>

--14dae93b590ef6607704babdd389
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

How about we provide a interface to make you able to specify which pages
should be charged to which cgroup, then you may create two cgroups for the
two files, set each of them to the desired size which you want the cache of
the file to be.  By that way you can control them as exactly as you want.
The current memcg allows a group which has not any processes but still
pages in soft limit tree (hope I'm not wrong) so you dont' have to put any
of you worker process into the groups either.

-zyh

=E5=9C=A8 2012=E5=B9=B43=E6=9C=889=E6=97=A5=E6=98=9F=E6=9C=9F=E4=BA=94=EF=
=BC=8CZheng Liu <gnehzuil.liu@gmail.com> =E5=86=99=E9=81=93=EF=BC=9A
> Hi Greg,
>
> Sorry, I forgot to say that I don't subscribe linux-mm and linux-kernel
> mailing list.  So please Cc me.
>
> I am glad to receive your reply and I am very interesting for your
> approach.  Actually I am not very familiar with CGroup.  So would you
> please send your patch to me if you can?  Thank you all the same.
>
> Regards,
> Zheng
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

--=20
Sent from Gmail Mobile

--14dae93b590ef6607704babdd389
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

How about we provide a interface to make you able to specify which pages sh=
ould be charged to which cgroup, then you may create two cgroups for the tw=
o files, set each of them to the desired size which you want the cache of t=
he file to be. =C2=A0By that way you can control them as exactly as you wan=
t.<br>
The current memcg allows a group which has not any processes but still page=
s in soft limit tree (hope I&#39;m not wrong) so you dont&#39; have to put =
any of you worker process into the groups either.<br><br>-zyh<br><br>=E5=9C=
=A8 2012=E5=B9=B43=E6=9C=889=E6=97=A5=E6=98=9F=E6=9C=9F=E4=BA=94=EF=BC=8CZh=
eng Liu &lt;<a href=3D"mailto:gnehzuil.liu@gmail.com">gnehzuil.liu@gmail.co=
m</a>&gt; =E5=86=99=E9=81=93=EF=BC=9A<br>
&gt; Hi Greg,<br>&gt;<br>&gt; Sorry, I forgot to say that I don&#39;t subsc=
ribe linux-mm and linux-kernel<br>&gt; mailing list. =C2=A0So please Cc me.=
<br>&gt;<br>&gt; I am glad to receive your reply and I am very interesting =
for your<br>
&gt; approach. =C2=A0Actually I am not very familiar with CGroup. =C2=A0So =
would you<br>&gt; please send your patch to me if you can? =C2=A0Thank you =
all the same.<br>&gt;<br>&gt; Regards,<br>&gt; Zheng<br>&gt; --<br>&gt; To =
unsubscribe from this list: send the line &quot;unsubscribe linux-kernel&qu=
ot; in<br>
&gt; the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org">=
majordomo@vger.kernel.org</a><br>&gt; More majordomo info at =C2=A0<a href=
=3D"http://vger.kernel.org/majordomo-info.html">http://vger.kernel.org/majo=
rdomo-info.html</a><br>
&gt; Please read the FAQ at =C2=A0<a href=3D"http://www.tux.org/lkml/">http=
://www.tux.org/lkml/</a><br>&gt;<br><br>-- <br>Sent from Gmail Mobile<br>

--14dae93b590ef6607704babdd389--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
