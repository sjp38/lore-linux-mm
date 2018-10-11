Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 81AE66B0003
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 06:04:15 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id f191-v6so3103303vsd.22
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 03:04:15 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w2sor11043997uam.26.2018.10.11.03.04.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Oct 2018 03:04:13 -0700 (PDT)
MIME-Version: 1.0
From: Li Wang <liwang@redhat.com>
Date: Thu, 11 Oct 2018 18:04:12 +0800
Message-ID: <CAEemH2eExK_jwOPZDFBZkwABucpZqh+=s+qpN-tFfMzxwo7cZA@mail.gmail.com>
Subject: s390: runtime warning about pgtables_bytes
Content-Type: multipart/alternative; boundary="000000000000c80ce90577f11747"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>, Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, liwang <liwang@redhat.com>

--000000000000c80ce90577f11747
Content-Type: text/plain; charset="UTF-8"

Hi,

When running s390 system with LTP/cve-2017-17052.c[1], the following BUG is
came out repeatedly.
I remember this warning start from kernel-4.16.0 and now it still exist in
kernel-4.19-rc7.
Can anyone take a look?

[ 2678.991496] BUG: non-zero pgtables_bytes on freeing mm: 16384
[ 2679.001543] BUG: non-zero pgtables_bytes on freeing mm: 16384
[ 2679.002453] BUG: non-zero pgtables_bytes on freeing mm: 16384
[ 2679.003256] BUG: non-zero pgtables_bytes on freeing mm: 16384
[ 2679.013689] BUG: non-zero pgtables_bytes on freeing mm: 16384
[ 2679.024647] BUG: non-zero pgtables_bytes on freeing mm: 16384
[ 2679.064408] BUG: non-zero pgtables_bytes on freeing mm: 16384
[ 2679.133963] BUG: non-zero pgtables_bytes on freeing mm: 16384

[1]:
https://github.com/linux-test-project/ltp/blob/master/testcases/cve/cve-2017-17052.c

-- 
Regards,
Li Wang

--000000000000c80ce90577f11747
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><div dir=3D"ltr"><div dir=3D"ltr"><div cl=
ass=3D"gmail_default">Hi,</div><div class=3D"gmail_default"><br></div><div =
class=3D"gmail_default">When running s390 system with LTP/cve-2017-17052.c[=
1], the following BUG is came out repeatedly.</div><div class=3D"gmail_defa=
ult">I remember this warning start from kernel-4.16.0 and now it still exis=
t in kernel-4.19-rc7.</div><div class=3D"gmail_default">Can anyone take a l=
ook?</div><div class=3D"gmail_default"><pre style=3D"color:rgb(0,0,0);text-=
decoration-style:initial;text-decoration-color:initial;word-wrap:break-word=
;white-space:pre-wrap"><pre style=3D"text-decoration-style:initial;text-dec=
oration-color:initial;word-wrap:break-word">[ 2678.991496] BUG: non-zero pg=
tables_bytes on freeing mm: 16384
[ 2679.001543] BUG: non-zero pgtables_bytes on freeing mm: 16384
[ 2679.002453] BUG: non-zero pgtables_bytes on freeing mm: 16384
[ 2679.003256] BUG: non-zero pgtables_bytes on freeing mm: 16384
[ 2679.013689] BUG: non-zero pgtables_bytes on freeing mm: 16384
[ 2679.024647] BUG: non-zero pgtables_bytes on freeing mm: 16384
[ 2679.064408] BUG: non-zero pgtables_bytes on freeing mm: 16384
[ 2679.133963] BUG: non-zero pgtables_bytes on freeing mm: 16384</pre></pre=
></div><div class=3D"gmail_default">[1]:=C2=A0<a href=3D"https://github.com=
/linux-test-project/ltp/blob/master/testcases/cve/cve-2017-17052.c">https:/=
/github.com/linux-test-project/ltp/blob/master/testcases/cve/cve-2017-17052=
.c</a></div><div><br></div>-- <br><div class=3D"gmail_signature"><div dir=
=3D"ltr"><div>Regards,<br></div><div>Li Wang<br></div></div></div>
</div></div></div></div>

--000000000000c80ce90577f11747--
