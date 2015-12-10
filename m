Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f45.google.com (mail-lf0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5BC4E82F82
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 04:43:01 -0500 (EST)
Received: by lfed137 with SMTP id d137so2103181lfe.3
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 01:43:00 -0800 (PST)
Received: from mail-lf0-x229.google.com (mail-lf0-x229.google.com. [2a00:1450:4010:c07::229])
        by mx.google.com with ESMTPS id g78si7157236lfb.151.2015.12.10.01.42.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 01:43:00 -0800 (PST)
Received: by lfdl133 with SMTP id l133so52470932lfd.2
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 01:42:59 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 10 Dec 2015 09:42:59 +0000
Message-ID: <CAF6XsOeYWvuNm=uuMCM4YD4a2dCoBe6TvimygPKRe4PMiHwQmw@mail.gmail.com>
Subject: Page Cache Monitoring ( Hit/Miss )
From: Allan McAleavy <allan.mcaleavy@gmail.com>
Content-Type: multipart/alternative; boundary=001a114017c645d3bb052688085e
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--001a114017c645d3bb052688085e
Content-Type: text/plain; charset=UTF-8

Hi Folks,

I am working on a rewrite of Brendan Greggs original cachestat (ftrace)
script into bcc. What I was looking for was a steer in the right direction
for what functions to trace. At present I trace the following.

add_to_page_cache_lru
account_page_dirtied
mark_page_accessed
mark_buffer_dirty

Where total = (mark_page_accessed - mark_buffer_dirty) & misses =
(add_to_page_cache_lru - account_page_dirtied), from this I then work out
the hit ratio etc. Is there any other key functions I should be tracing?

Thanks

--001a114017c645d3bb052688085e
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><font face=3D"Menlo" style=3D"font-size:12.8px">Hi Folks,<=
/font><div style=3D"font-size:12.8px"><font face=3D"Menlo"><br></font></div=
><div style=3D"font-size:12.8px"><font face=3D"Menlo">I am working on a rew=
rite of Brendan Greggs original cachestat (ftrace) script into bcc. What I =
was looking for was a steer in the right direction for what functions to tr=
ace. At present I trace the following.=C2=A0</font></div><div style=3D"font=
-size:12.8px"><font face=3D"Menlo"><br></font></div><div style=3D"font-size=
:12.8px"><font face=3D"Menlo">add_to_page_cache_lru</font></div><div style=
=3D"font-size:12.8px"><div style=3D"margin:0px"><span style=3D"font-family:=
Menlo">account_page_dirtied</span></div><div style=3D"margin:0px"><font fac=
e=3D"Menlo">mark_page_accessed</font></div><div style=3D"margin:0px"><span =
style=3D"font-family:Menlo">mark_buffer_dirty</span></div><div style=3D"mar=
gin:0px"><font face=3D"Menlo"><br></font></div></div><div style=3D"font-siz=
e:12.8px;margin:0px"><font face=3D"Menlo">Where total =3D (mark_page_access=
ed - mark_buffer_dirty) &amp; misses =3D (add_to_page_cache_lru - account_p=
age_dirtied), from this I then work out the hit ratio etc. Is there any oth=
er key functions I should be tracing?</font></div><div style=3D"font-size:1=
2.8px;margin:0px"><font face=3D"Menlo"><br></font></div><div style=3D"font-=
size:12.8px;margin:0px"><font face=3D"Menlo">Thanks</font></div></div>

--001a114017c645d3bb052688085e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
