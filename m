Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 14F8A6B0023
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 11:19:34 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p4so1322860wrf.17
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 08:19:34 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l3sor1926521wri.66.2018.03.28.08.19.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Mar 2018 08:19:32 -0700 (PDT)
MIME-Version: 1.0
From: Po-Hao Su <supohaosu@gmail.com>
Date: Wed, 28 Mar 2018 23:19:30 +0800
Message-ID: <CAD5U=y8Q-9G+6n9bRs1BbirwhAJ5z0-CS7sG1q8ypqLaDyyHgQ@mail.gmail.com>
Subject: do_mmap Function Issue Report
Content-Type: multipart/mixed; boundary="089e0820f540a91b6105687a88d3"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--089e0820f540a91b6105687a88d3
Content-Type: multipart/alternative; boundary="089e0820f540a91b5d05687a88d1"

--089e0820f540a91b5d05687a88d1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Dear Memory Management Maintainer,

I am Po-Hao Su, a graduate student from the Operating Systems and Embedded
Systems Lab at National Cheng Kung University in Taiwan.

I am writing in reference to report a bug in *do_mmap(...)* function.
Recently, I found that there seems a bug after *get_unmapped_area(...)
*function
is return.
*do_mmap(...) *function will check the *addr *parameter is aligned on a
page boundary or not after *get_unmapped_area(...)* function is return.
But it will return *addr *parameter, not an error(probably to *-EINVAL*)
while address not aligned on a page boundary.
Therefore, I think address not aligned on a page boundary should be an
error(*-EINVAL*).

I also discussed this issue with others when the meeting of my lab, others
views are consistent with me.
In view of this, I report the issue. Attached is the patch for this.

If this is a wrong report, I am sorry, and please show me why kernel do it,
if convenient. Thank you.
I look forward to hearing from you.

Best regards,

=E8=98=87=E6=9F=8F=E8=B1=AA, =E7=A0=94=E7=A9=B6=E7=94=9F
=E4=BD=9C=E6=A5=AD=E7=B3=BB=E7=B5=B1=E8=88=87=E5=B5=8C=E5=85=A5=E5=BC=8F=E7=
=B3=BB=E7=B5=B1=E5=AF=A6=E9=A9=97=E5=AE=A4,
=E5=9C=8B=E7=AB=8B=E6=88=90=E5=8A=9F=E5=A4=A7=E5=AD=B8=E8=B3=87=E8=A8=8A=E5=
=B7=A5=E7=A8=8B=E5=AD=B8=E7=B3=BB
Email: supohaosu@gmail.com

Po-Hao Su, Graduate Student
Operating Systems and Embedded Systems Lab,
Department of Computer Science and Information Engineering
National Cheng Kung University, Taiwan
Email: supohaosu@gmail.com

--089e0820f540a91b5d05687a88d1
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Dear Memory Management Maintainer,<br><br>I am Po-Hao Su, =
a graduate student from the Operating Systems and Embedded Systems Lab at N=
ational Cheng Kung University in Taiwan.<br><br>I am writing in reference t=
o report a bug in <i>do_mmap(...)</i> function.<br>Recently, I found that t=
here seems a bug after <i>get_unmapped_area(...) </i>function is return.<br=
><i>do_mmap(...) </i>function will check the <i>addr </i>parameter is align=
ed on a page boundary or not after <i>get_unmapped_area(...)</i> function i=
s return.<br>But it will return <i>addr </i>parameter, not an error(probabl=
y to <i>-EINVAL</i>) while address not aligned on a page boundary.<br>There=
fore, I think address not aligned on a page boundary should be an error(<i>=
-EINVAL</i>).<br><br>I also discussed this issue with others when the meeti=
ng of my lab, others views are consistent with me.<br>In view of this, I re=
port the issue. Attached is the patch for this.<br><br>If this is a wrong r=
eport, I am sorry, and please show me why kernel do it, if convenient. Than=
k you.<br>I look forward to hearing from you.<br><br>
<div>Best regards,<br></div><div><font size=3D"2"><br>
<font size=3D"2"> <font size=3D"2"><font size=3D"2">=E8=98=87=E6=9F=8F=E8=
=B1=AA</font></font>, =E7=A0=94=E7=A9=B6=E7=94=9F</font><br>=E4=BD=9C=E6=A5=
=AD=E7=B3=BB=E7=B5=B1=E8=88=87=E5=B5=8C=E5=85=A5=E5=BC=8F=E7=B3=BB=E7=B5=B1=
=E5=AF=A6=E9=A9=97=E5=AE=A4, <br>=E5=9C=8B=E7=AB=8B=E6=88=90=E5=8A=9F=E5=A4=
=A7=E5=AD=B8=E8=B3=87=E8=A8=8A=E5=B7=A5=E7=A8=8B=E5=AD=B8=E7=B3=BB<br>Email=
:=C2=A0<a href=3D"mailto:supohaosu@gmail.com" style=3D"color:rgb(17,85,204)=
" target=3D"_blank">supohaosu@gmail.com</a><br><br>
<font size=3D"2"> <font size=3D"2"><font size=3D"2">Po-Hao Su</font></font>=
, Graduate Student=C2=A0</font> <br>Operating Systems and Embedded Systems =
Lab,<br>Department of Computer Science and Information Engineering<br>Natio=
nal Cheng Kung University, Taiwan<br>Email:=C2=A0<a href=3D"mailto:supohaos=
u@gmail.com" style=3D"color:rgb(17,85,204)" target=3D"_blank">supohaosu@gma=
il.com</a></font></div>

<br></div>

--089e0820f540a91b5d05687a88d1--

--089e0820f540a91b6105687a88d3
Content-Type: application/octet-stream; name="linux-4.15.13-patch-pohao"
Content-Disposition: attachment; filename="linux-4.15.13-patch-pohao"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_jfb8d2u40

ZGlmZiAtTnJ1IGxpbnV4LTQuMTUuMTMvbW0vbW1hcC5jIGxpbnV4LTQuMTUuMTMtcG9oYW8vbW0v
bW1hcC5jCi0tLSBsaW51eC00LjE1LjEzL21tL21tYXAuYwkyMDE4LTAzLTI0IDE4OjAyOjUzLjAw
MDAwMDAwMCArMDgwMAorKysgbGludXgtNC4xNS4xMy1wb2hhby9tbS9tbWFwLmMJMjAxOC0wMy0y
OCAyMjowODoxOC43NjgwODk0MzEgKzA4MDAKQEAgLTEzNjMsNyArMTM2Myw3IEBACiAJICovCiAJ
YWRkciA9IGdldF91bm1hcHBlZF9hcmVhKGZpbGUsIGFkZHIsIGxlbiwgcGdvZmYsIGZsYWdzKTsK
IAlpZiAob2Zmc2V0X2luX3BhZ2UoYWRkcikpCi0JCXJldHVybiBhZGRyOworCQlyZXR1cm4gLUVJ
TlZBTDsKIAogCWlmIChwcm90ID09IFBST1RfRVhFQykgewogCQlwa2V5ID0gZXhlY3V0ZV9vbmx5
X3BrZXkobW0pOwo=
--089e0820f540a91b6105687a88d3--
