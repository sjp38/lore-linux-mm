Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id D84566B0007
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 20:01:13 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id y13-v6so2142352iop.3
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 17:01:13 -0700 (PDT)
Received: from sonic308-12.consmr.mail.ne1.yahoo.com (sonic308-12.consmr.mail.ne1.yahoo.com. [66.163.187.35])
        by mx.google.com with ESMTPS id l18-v6si1677770jak.48.2018.07.17.17.01.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 17:01:12 -0700 (PDT)
Date: Wed, 18 Jul 2018 00:01:10 +0000 (UTC)
From: David Frank <david_frank95@yahoo.com>
Message-ID: <1485529317.61381.1531872070328@mail.yahoo.com>
In-Reply-To: <3b40325e-a75e-017d-920e-83e090153621@oracle.com>
References: <115606142.5883850.1531854314452.ref@mail.yahoo.com> <115606142.5883850.1531854314452@mail.yahoo.com> <3b40325e-a75e-017d-920e-83e090153621@oracle.com>
Subject: Re: mmap with huge page
MIME-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_Part_61380_437181951.1531872070327"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kernelnewbies <kernelnewbies@kernelnewbies.org>, Linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>

------=_Part_61380_437181951.1531872070327
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

 Thanks Mike.=C2=A0 I read the doc, which is not explicit on the non used f=
ile taking up huge page count=C2=A0
    On Tuesday, July 17, 2018, 4:57:04 PM PDT, Mike Kravetz <mike.kravetz@o=
racle.com> wrote: =20
=20
 On 07/17/2018 12:05 PM, David Frank wrote:
> Hi,
> According to the instruction, I have to mount a huge directory to hugetlb=
fs and create file in the huge directory to use the mmap huge page feature.=
 But the issue is that, the files in the huge directory takes up the huge p=
ages configured through
> vm.nr_hugepages =3D
>=20
> even the files are not used.
>=20
> When the total size of the files in the huge directory =3D vm.nr_hugepage=
s * huge page size, then mmap would fail with 'can not allocate memory' if =
the file to be=C2=A0 mapped is in the huge dir or the call has HUGEPAGETLB =
flag.
>=20
> Basically, I have to move the files off of the huge directory to free up =
huge pages.
>=20
> Am I missing anything here?
>=20

No, that is working as designed.

hugetlbfs filesystems are generally pre-allocated with nr_hugepages
huge pages.=C2=A0 That is the upper limit of huge pages available.=C2=A0 Yo=
u can
use overcommit/surplus pages to try and exceed the limit, but that
comes with a whole set of potential issues.

If you have not done so already, please see Documentation/vm/hugetlbpage.tx=
t
in the kernel source tree.
--=20
Mike Kravetz
 =20
------=_Part_61380_437181951.1531872070327
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<html><head></head><body><div style=3D"font-family:Helvetica Neue, Helvetic=
a, Arial, sans-serif;font-size:16px;"><div style=3D"font-family:Helvetica N=
eue, Helvetica, Arial, sans-serif;font-size:16px;"><div></div>
        <div>Thanks Mike.&nbsp; I read the doc, which is not explicit on th=
e non used file taking up huge page count&nbsp;</div><div><br></div>
       =20
        <div id=3D"ydp9a441918yahoo_quoted_2048059283" class=3D"ydp9a441918=
yahoo_quoted">
            <div style=3D"font-family:'Helvetica Neue', Helvetica, Arial, s=
ans-serif;font-size:13px;color:#26282a;">
               =20
                <div>
                    On Tuesday, July 17, 2018, 4:57:04 PM PDT, Mike Kravetz=
 &lt;mike.kravetz@oracle.com&gt; wrote:
                </div>
                <div><br></div>
                <div><br></div>
                <div><div dir=3D"ltr">On 07/17/2018 12:05 PM, David Frank w=
rote:<div class=3D"ydp9a441918yqt3201060868" id=3D"ydp9a441918yqtfd93097"><=
br clear=3D"none">&gt; Hi,<br clear=3D"none">&gt; According to the instruct=
ion, I have to mount a huge directory to hugetlbfs and create file in the h=
uge directory to use the mmap huge page feature. But the issue is that, the=
 files in the huge directory takes up the huge pages configured through<br =
clear=3D"none">&gt; vm.nr_hugepages =3D<br clear=3D"none">&gt; <br clear=3D=
"none">&gt; even the files are not used.<br clear=3D"none">&gt; <br clear=
=3D"none">&gt; When the total size of the files in the huge directory =3D v=
m.nr_hugepages * huge page size, then mmap would fail with 'can not allocat=
e memory' if the file to be&nbsp; mapped is in the huge dir or the call has=
 HUGEPAGETLB flag.<br clear=3D"none">&gt; <br clear=3D"none">&gt; Basically=
, I have to move the files off of the huge directory to free up huge pages.=
<br clear=3D"none">&gt; <br clear=3D"none">&gt; Am I missing anything here?=
</div><br clear=3D"none">&gt; <br clear=3D"none"><br clear=3D"none">No, tha=
t is working as designed.<br clear=3D"none"><br clear=3D"none">hugetlbfs fi=
lesystems are generally pre-allocated with nr_hugepages<br clear=3D"none">h=
uge pages.&nbsp; That is the upper limit of huge pages available.&nbsp; You=
 can<br clear=3D"none">use overcommit/surplus pages to try and exceed the l=
imit, but that<br clear=3D"none">comes with a whole set of potential issues=
.<br clear=3D"none"><br clear=3D"none">If you have not done so already, ple=
ase see Documentation/vm/hugetlbpage.txt<br clear=3D"none">in the kernel so=
urce tree.<br clear=3D"none">-- <br clear=3D"none">Mike Kravetz<div class=
=3D"ydp9a441918yqt3201060868" id=3D"ydp9a441918yqtfd43949"><br clear=3D"non=
e"></div></div></div>
            </div>
        </div></div></div></body></html>
------=_Part_61380_437181951.1531872070327--
