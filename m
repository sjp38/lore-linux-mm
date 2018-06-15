Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2BCA46B000A
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 03:18:39 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id p41-v6so5276219oth.5
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 00:18:39 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p62-v6sor2933006ota.161.2018.06.15.00.18.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Jun 2018 00:18:37 -0700 (PDT)
MIME-Version: 1.0
From: Steve Swanson <steves@fusionmemory.com>
Date: Fri, 15 Jun 2018 00:18:36 -0700
Message-ID: <CAJnYoQPCfAtdsosrzbi4D21H5AW_UrcQiuUwBDKiJ50VWvDyTQ@mail.gmail.com>
Subject: Placing DIMMs in self-refresh mode
Content-Type: multipart/alternative; boundary="00000000000043a137056ea90651"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--00000000000043a137056ea90651
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

All,

Summary:  As part of the testing process for a Linux + Xeon 4108-based
system we are developing, we need to explicitly place a DIMM into
self-refresh mode.  Is this possible from within the operating system?  How=
?

Details:

The system we are working on is based on the SuperMicro X11DPi-NT populated
with an Intel Xeon 4108 (Skylake).

I haven=E2=80=99t found anything promising in the kernel source for X86 alt=
hough
there are hints of support on other platforms.  We have also scoured all
the Intel documents and have found references to the Integrated Memory
Controller, which seems like the piece of hardware that would take care of
this, but I haven=E2=80=99t been able to find documentation fro the IMC on =
this
processor.   Another likely spot seems to be Asynchronous DRAM Refresh
(ADR) mechanism, but I'm not able find information about how that
functionality might be used to explicitly turn on self-refresh on a
particular DIMM.

Any pointers would be greatly appreciated.

Thanks.

-steve

--00000000000043a137056ea90651
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div style=3D"color:rgb(0,0,0);font-family:Helvetica;font-=
size:12px;font-weight:normal">All,</div><div style=3D"color:rgb(0,0,0);font=
-family:Helvetica;font-size:12px;font-weight:normal"><br></div><div style=
=3D"color:rgb(0,0,0);font-family:Helvetica;font-size:12px;font-weight:norma=
l">Summary: =C2=A0As part of the testing process for a Linux + Xeon=C2=A041=
08-based system we are developing, we need to explicitly place a DIMM=C2=A0=
into self-refresh mode.=C2=A0 Is this possible from within the operating=C2=
=A0system?=C2=A0 How?</div><div style=3D"color:rgb(0,0,0);font-family:Helve=
tica;font-size:12px;font-weight:normal"><br>Details:<br><br>The system we a=
re working on is based on the SuperMicro X11DPi-NT populated with an Intel =
Xeon 4108 (Skylake).<br><br>I haven=E2=80=99t found anything promising in t=
he kernel source for X86=C2=A0although there are hints of support on other =
platforms.=C2=A0 We have also=C2=A0scoured all the Intel documents and have=
 found references to the=C2=A0Integrated Memory Controller,=C2=A0which seem=
s like the piece of hardware=C2=A0that would take care of this, but I haven=
=E2=80=99t been able to find=C2=A0documentation fro the IMC on this process=
or. =C2=A0 Another likely spot seems=C2=A0to be Asynchronous DRAM Refresh (=
ADR) mechanism,=C2=A0but I&#39;m not able find=C2=A0information about how t=
hat functionality might be used to explicitly=C2=A0turn on self-refresh on =
a particular DIMM.<br></div><div style=3D"color:rgb(0,0,0);font-family:Helv=
etica;font-size:12px;font-weight:normal"><br></div><div style=3D"color:rgb(=
0,0,0);font-family:Helvetica;font-size:12px;font-weight:normal">Any pointer=
s would be greatly appreciated.<br></div><div style=3D"color:rgb(0,0,0);fon=
t-family:Helvetica;font-size:12px;font-weight:normal"><br>Thanks.<br><br>-s=
teve</div><br></div>

--00000000000043a137056ea90651--
