Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B50D6B2586
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 04:36:59 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 89so7081419ple.19
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 01:36:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a5sor53116188pgk.84.2018.11.21.01.36.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Nov 2018 01:36:57 -0800 (PST)
Content-Type: multipart/alternative;
	boundary="Apple-Mail=_C5B43EB3-8830-4F15-94A3-55DE627B3B01"
Mime-Version: 1.0 (Mac OS X Mail 12.1 \(3445.101.1\))
Subject: Re: [Bug 201699] New: kmemleak in memcg_create_kmem_cache
From: =?utf-8?B?5q6154aK5pil?= <duanxiongchun@bytedance.com>
In-Reply-To: <5fa306b3.7c7c.1673593d0d8.Coremail.bauers@126.com>
Date: Wed, 21 Nov 2018 17:36:51 +0800
Message-Id: <556CF326-C3ED-44A7-909B-780531A8D4FF@bytedance.com>
References: <bug-201699-27@https.bugzilla.kernel.org/>
 <20181115130646.6de1029eb1f3b8d7276c3543@linux-foundation.org>
 <20181116175005.3dcfpyhuj57oaszm@esperanza>
 <433c2924.f6c.16724466cd8.Coremail.bauers@126.com>
 <20181119083045.m5rhvbsze4h5l6jq@esperanza>
 <6185b79c.9161.1672bd49ed1.Coremail.bauers@126.com>
 <375ca28a.7433.16735734d98.Coremail.bauers@126.com>
 <20181121091041.GM12932@dhcp22.suse.cz>
 <5fa306b3.7c7c.1673593d0d8.Coremail.bauers@126.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dong <bauers@126.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>


--Apple-Mail=_C5B43EB3-8830-4F15-94A3-55DE627B3B01
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8

hi all=EF=BC=9A

In same case=EF=BC=8C I think it=E2=80=99s may be a problem=E3=80=82

if I create a virtual netdev device under mem cgroup(like ip link add =
ve_A type veth peer name ve_B).after that ,I destroy this mem cgroup=E3=80=
=82

I find that may the object  net_device, will be hold by the kernel until =
I run command (ip link del ). And the memory pages which container the =
object won=E2=80=99t be uncharge. mem_cgroup object  also will be not =
free.=20

Anothers may think kernel just hold sizeof(struct netdev_device) memory =
size. But,it=E2=80=99s not really,it=E2=80=99s much bigger than they =
think.

It=E2=80=99s maybe a problems, I am not very sure about that.

 Thanks

bytedance.net
=E6=AE=B5=E7=86=8A=E6=98=A5
duanxiongchun@bytedance.com




> On Nov 21, 2018, at 5:22 PM, dong <bauers@126.com> wrote:
>=20
> Thanks for replying, Michal.
>=20
> cc to duanxiongchun
>=20
>=20
>=20
>=20
>=20
>=20
> At 2018-11-21 17:10:41, "Michal Hocko" <mhocko@kernel.org> wrote:
> >On Wed 21-11-18 16:46:48, dong wrote:
> >> The last question: If I alloc many small pages and not free them, =
will
> >> I exhaust the memory ( because every page contains `mem_cgroup` )?
> >
> >No, the memory will get reclaimed on the memory pressure or for
> >anonymous one (malloc) when the process allocating it terminates,
> >--=20
> >Michal Hocko
> >SUSE Labs
>=20
>=20
> =20


--Apple-Mail=_C5B43EB3-8830-4F15-94A3-55DE627B3B01
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=utf-8

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html; =
charset=3Dutf-8"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; line-break: after-white-space;" class=3D"">hi =
all=EF=BC=9A<div class=3D""><br class=3D""></div><div class=3D"">In same =
case=EF=BC=8C I think it=E2=80=99s may be a problem=E3=80=82</div><div =
class=3D""><br class=3D""></div><div class=3D"">if I create a virtual =
netdev device under mem cgroup(like ip link add ve_A type veth peer name =
ve_B).after that ,I destroy this mem cgroup=E3=80=82</div><div =
class=3D""><br class=3D""></div><div class=3D"">I find that may the =
object &nbsp;net_device, will be hold by the kernel until I run command =
(ip link del ). And the memory pages which container the object won=E2=80=99=
t be uncharge. mem_cgroup object &nbsp;also will be not =
free.&nbsp;</div><div class=3D""><br class=3D""></div><div =
class=3D"">Anothers may think kernel just hold sizeof(struct =
netdev_device) memory size. But,it=E2=80=99s not really,it=E2=80=99s =
much bigger than they think.</div><div class=3D""><br =
class=3D""></div><div class=3D"">It=E2=80=99s maybe a problems, I am not =
very sure about that.</div><div class=3D""><br class=3D""></div><div =
class=3D"">&nbsp;Thanks</div><div class=3D""><br class=3D""><div =
class=3D"">
<div dir=3D"auto" style=3D"word-wrap: break-word; -webkit-nbsp-mode: =
space; line-break: after-white-space;" class=3D""><div =
style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;"><a href=3D"http://bytedance.net" class=3D"">bytedance.net</a><br =
class=3D"">=E6=AE=B5=E7=86=8A=E6=98=A5<br =
class=3D"">duanxiongchun@bytedance.com<br class=3D""><br =
class=3D""></div><br class=3D"Apple-interchange-newline"></div><br =
class=3D"Apple-interchange-newline">
</div>
<div><br class=3D""><blockquote type=3D"cite" class=3D""><div =
class=3D"">On Nov 21, 2018, at 5:22 PM, dong &lt;<a =
href=3D"mailto:bauers@126.com" class=3D"">bauers@126.com</a>&gt; =
wrote:</div><br class=3D"Apple-interchange-newline"><div class=3D""><div =
style=3D"line-height: 1.7; font-size: 14px; font-family: Arial;" =
class=3D""><div class=3D"">Thanks for replying,&nbsp;<span =
style=3D"font-family: arial; white-space: pre-wrap;" =
class=3D"">Michal</span>.</div><div class=3D""><br class=3D""></div><div =
class=3D"">cc to duanxiongchun</div><br class=3D""><br class=3D""><br =
class=3D""><br class=3D""><div style=3D"position:relative;zoom:1" =
class=3D""></div><div id=3D"divNeteaseMailCard" class=3D""></div><br =
class=3D""><pre class=3D""><br class=3D"">At 2018-11-21 17:10:41, =
"Michal Hocko" &lt;<a href=3D"mailto:mhocko@kernel.org" =
class=3D"">mhocko@kernel.org</a>&gt; wrote:
&gt;On Wed 21-11-18 16:46:48, dong wrote:
&gt;&gt; The last question: If I alloc many small pages and not free =
them, will
&gt;&gt; I exhaust the memory ( because every page contains `mem_cgroup` =
)?
&gt;
&gt;No, the memory will get reclaimed on the memory pressure or for
&gt;anonymous one (malloc) when the process allocating it terminates,
&gt;--=20
&gt;Michal Hocko
&gt;SUSE Labs
</pre></div><br class=3D""><br class=3D""><span title=3D"neteasefooter" =
class=3D""><div class=3D"">&nbsp;<br =
class=3D"webkit-block-placeholder"></div></span></div></blockquote></div><=
br class=3D""></div></body></html>=

--Apple-Mail=_C5B43EB3-8830-4F15-94A3-55DE627B3B01--
