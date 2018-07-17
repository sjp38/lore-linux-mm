Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2AFDE6B0266
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 15:05:18 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id u140-v6so359937itc.3
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:05:18 -0700 (PDT)
Received: from sonic307-11.consmr.mail.ne1.yahoo.com (sonic307-11.consmr.mail.ne1.yahoo.com. [66.163.190.34])
        by mx.google.com with ESMTPS id h4-v6si185198ith.105.2018.07.17.12.05.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 12:05:17 -0700 (PDT)
Date: Tue, 17 Jul 2018 19:05:14 +0000 (UTC)
From: David Frank <david_frank95@yahoo.com>
Message-ID: <115606142.5883850.1531854314452@mail.yahoo.com>
Subject: mmap with huge page
MIME-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_Part_5883849_1141935688.1531854314451"
References: <115606142.5883850.1531854314452.ref@mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kernelnewbies <kernelnewbies@kernelnewbies.org>, Linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

------=_Part_5883849_1141935688.1531854314451
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi,According to the instruction, I have to mount a huge directory to hugetl=
bfs and create file in the huge directory to use the mmap huge page feature=
. But the issue is that, the files in the huge directory takes up the huge =
pages configured throughvm.nr_hugepages =3D=20

even the files are not used.
When the total size of the files in the huge directory =3D vm.nr_hugepages =
* huge page size, then mmap would fail with 'can not allocate memory' if th=
e file to be=C2=A0 mapped is in the huge dir or the call has HUGEPAGETLB fl=
ag.
Basically, I have to move the files off of the huge directory to free up hu=
ge pages.
Am I missing anything here?
Thanks,
David

------=_Part_5883849_1141935688.1531854314451
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<html><head></head><body><div style=3D"font-family:Helvetica Neue, Helvetic=
a, Arial, sans-serif;font-size:13px;"><div style=3D"font-family:Helvetica N=
eue, Helvetica, Arial, sans-serif;font-size:13px;">Hi,</div><div style=3D"f=
ont-family:Helvetica Neue, Helvetica, Arial, sans-serif;font-size:13px;">Ac=
cording to the instruction, I have to mount a huge directory to hugetlbfs a=
nd create file in the huge directory to use the mmap huge page feature. But=
 the issue is that, the files in the huge directory takes up the huge pages=
 configured through</div><div style=3D"font-family:Helvetica Neue, Helvetic=
a, Arial, sans-serif;font-size:13px;">vm.nr_hugepages =3D <br></div><div st=
yle=3D"font-family:Helvetica Neue, Helvetica, Arial, sans-serif;font-size:1=
3px;"><br></div><div style=3D"font-family:Helvetica Neue, Helvetica, Arial,=
 sans-serif;font-size:13px;">even the files are not used.</div><div style=
=3D"font-family:Helvetica Neue, Helvetica, Arial, sans-serif;font-size:13px=
;"><br></div><div style=3D"font-family:Helvetica Neue, Helvetica, Arial, sa=
ns-serif;font-size:13px;">When the total size of the files in the huge dire=
ctory =3D vm.nr_hugepages * huge page size, then mmap would fail with 'can =
not allocate memory' if the file to be&nbsp; mapped is in the huge dir or t=
he call has HUGEPAGETLB flag.</div><div style=3D"font-family:Helvetica Neue=
, Helvetica, Arial, sans-serif;font-size:13px;"><br></div><div style=3D"fon=
t-family:Helvetica Neue, Helvetica, Arial, sans-serif;font-size:13px;">Basi=
cally, I have to move the files off of the huge directory to free up huge p=
ages.</div><div style=3D"font-family:Helvetica Neue, Helvetica, Arial, sans=
-serif;font-size:13px;"><br></div><div style=3D"font-family:Helvetica Neue,=
 Helvetica, Arial, sans-serif;font-size:13px;">Am I missing anything here?<=
/div><div style=3D"font-family:Helvetica Neue, Helvetica, Arial, sans-serif=
;font-size:13px;"><br></div><div style=3D"font-family:Helvetica Neue, Helve=
tica, Arial, sans-serif;font-size:13px;">Thanks,</div><div style=3D"font-fa=
mily:Helvetica Neue, Helvetica, Arial, sans-serif;font-size:13px;"><br></di=
v><div style=3D"font-family:Helvetica Neue, Helvetica, Arial, sans-serif;fo=
nt-size:13px;">David<br></div></div></body></html>
------=_Part_5883849_1141935688.1531854314451--
