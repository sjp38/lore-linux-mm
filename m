Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 60E3E6B2A6F
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 03:21:49 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 143so2083358pgc.3
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 00:21:49 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n11sor9640289pfk.44.2018.11.22.00.21.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Nov 2018 00:21:48 -0800 (PST)
From: =?utf-8?B?5q6154aK5pil?= <duanxiongchun@bytedance.com>
Message-Id: <692C7BC2-F27A-40D9-8957-A97E16654603@bytedance.com>
Content-Type: multipart/alternative;
	boundary="Apple-Mail=_07E6A933-DD2D-43DF-965F-1D95DDF06C9D"
Mime-Version: 1.0 (Mac OS X Mail 12.1 \(3445.101.1\))
Subject: Re: [Bug 201699] New: kmemleak in memcg_create_kmem_cache
Date: Thu, 22 Nov 2018 16:21:43 +0800
In-Reply-To: <20181122073420.GB18011@dhcp22.suse.cz>
References: <20181116175005.3dcfpyhuj57oaszm@esperanza>
 <433c2924.f6c.16724466cd8.Coremail.bauers@126.com>
 <20181119083045.m5rhvbsze4h5l6jq@esperanza>
 <6185b79c.9161.1672bd49ed1.Coremail.bauers@126.com>
 <375ca28a.7433.16735734d98.Coremail.bauers@126.com>
 <20181121091041.GM12932@dhcp22.suse.cz>
 <5fa306b3.7c7c.1673593d0d8.Coremail.bauers@126.com>
 <556CF326-C3ED-44A7-909B-780531A8D4FF@bytedance.com>
 <20181121162747.GR12932@dhcp22.suse.cz>
 <7348A2DF-87E8-4F88-B270-7FB71DB5C8CB@bytedance.com>
 <20181122073420.GB18011@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: dong <bauers@126.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>


--Apple-Mail=_07E6A933-DD2D-43DF-965F-1D95DDF06C9D
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8

4.9 and 4.14

OK, I had check  the code  did not  have  __GFP_ACCOUNT flag.

I will  double check on the latest version.

Maybe there something I do not know.=20

Thanks for replying

bytedance.net
=E6=AE=B5=E7=86=8A=E6=98=A5
duanxiongchun@bytedance.com




> On Nov 22, 2018, at 3:34 PM, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> On Thu 22-11-18 10:56:04, =E6=AE=B5=E7=86=8A=E6=98=A5 wrote:
>> After long time dig, we find their lots of offline but not release =
memcg object in memory eating lots of memory.
>> Why this memcg not release? Because the inode pagecache use  some =
page which is charged to those memcg,
>=20
> As already explained these objects should be reclaimed under memory
> pressure. If they are not then there is a bug. And Roman has fixed =
some
> of those recently.
>=20
> Which kernel version are you using?
> --=20
> Michal Hocko
> SUSE Labs


--Apple-Mail=_07E6A933-DD2D-43DF-965F-1D95DDF06C9D
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=utf-8

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html; =
charset=3Dutf-8"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; line-break: after-white-space;" class=3D"">4.9 =
and 4.14<div class=3D""><br class=3D""><div class=3D""><div class=3D"">OK,=
 I had check &nbsp;the code &nbsp;did not &nbsp;have &nbsp;__GFP_ACCOUNT =
flag.</div><div class=3D""><br class=3D""></div><div class=3D"">I will =
&nbsp;double check on the latest version.</div><div class=3D""><br =
class=3D""></div><div class=3D"">Maybe there something I do not =
know.&nbsp;</div><div class=3D""><br class=3D""></div><div =
class=3D"">Thanks for replying</div><div class=3D""><br =
class=3D""></div><div class=3D""><div class=3D"">
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
class=3D"">On Nov 22, 2018, at 3:34 PM, Michal Hocko &lt;<a =
href=3D"mailto:mhocko@kernel.org" class=3D"">mhocko@kernel.org</a>&gt; =
wrote:</div><br class=3D"Apple-interchange-newline"><div class=3D""><div =
class=3D"">On Thu 22-11-18 10:56:04, =E6=AE=B5=E7=86=8A=E6=98=A5 =
wrote:<br class=3D""><blockquote type=3D"cite" class=3D"">After long =
time dig, we find their lots of offline but not release memcg object in =
memory eating lots of memory.<br class=3D"">Why this memcg not release? =
Because the inode pagecache use &nbsp;some page which is charged to =
those memcg,<br class=3D""></blockquote><br class=3D"">As already =
explained these objects should be reclaimed under memory<br =
class=3D"">pressure. If they are not then there is a bug. And Roman has =
fixed some<br class=3D"">of those recently.<br class=3D""><br =
class=3D"">Which kernel version are you using?<br class=3D"">-- <br =
class=3D"">Michal Hocko<br class=3D"">SUSE Labs<br =
class=3D""></div></div></blockquote></div><br =
class=3D""></div></div></div></body></html>=

--Apple-Mail=_07E6A933-DD2D-43DF-965F-1D95DDF06C9D--
