Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 514406B0003
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 03:02:02 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id q85so14462363vkb.4
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 00:02:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m77sor1394649vka.151.2018.04.26.00.02.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Apr 2018 00:02:00 -0700 (PDT)
MIME-Version: 1.0
From: Li Wang <liwang@redhat.com>
Date: Thu, 26 Apr 2018 15:02:00 +0800
Message-ID: <CAEemH2enj4MUFRc03CLzuHzqJGJFESeQvj5oitZ2Am+Ww=jVYA@mail.gmail.com>
Subject: LTP cve-2017-5754 test fails on kernel-v4.17-rc2
Content-Type: multipart/alternative; boundary="001a114353c2cd751b056abaf6bb"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, ltp@lists.linux.it
Cc: pboldin@cloudlinux.com, dave.hansen@linux.intel.com, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

--001a114353c2cd751b056abaf6bb
Content-Type: text/plain; charset="UTF-8"

Hi LKML & LTP,

LTP/meltdown.c fails on upstream kernel-v4.17-rc2 with both kvm and
bare-metal system. Please attention!!!

kernel-v4.17-rc2 FAIL
kernel-v4.17-rc1 PASS


=======================

Kernel Version: 4.17.0-rc2
Machine Architecture: x86_64

tst_test.c:1015: INFO: Timeout per run is 0h 50m 00s
meltdown.c:259: INFO: access time: cached = 51, uncached = 343, threshold = 132
meltdown.c:309: INFO: linux_proc_banner is at ffffffff8ba00060
meltdown.c:332: INFO: read ffffffff8ba00060 = 0x25 %
meltdown.c:332: INFO: read ffffffff8ba00061 = 0x73 s
meltdown.c:332: INFO: read ffffffff8ba00062 = 0x20
meltdown.c:332: INFO: read ffffffff8ba00063 = 0x76 v
meltdown.c:332: INFO: read ffffffff8ba00064 = 0x65 e
meltdown.c:332: INFO: read ffffffff8ba00065 = 0x72 r
meltdown.c:332: INFO: read ffffffff8ba00066 = 0x73 s
meltdown.c:332: INFO: read ffffffff8ba00067 = 0x69 i
meltdown.c:332: INFO: read ffffffff8ba00068 = 0x6f o
meltdown.c:332: INFO: read ffffffff8ba00069 = 0x6e n
meltdown.c:332: INFO: read ffffffff8ba0006a = 0x20
meltdown.c:332: INFO: read ffffffff8ba0006b = 0x25 %
meltdown.c:332: INFO: read ffffffff8ba0006c = 0x73 s
meltdown.c:342: FAIL: I was able to read your kernel memory!!!

Summary:
passed   0
failed   1
skipped  0
warnings 0


# lscpu
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                2
On-line CPU(s) list:   0,1
Thread(s) per core:    1
Core(s) per socket:    1
Socket(s):             2
NUMA node(s):          1
Vendor ID:             GenuineIntel
CPU family:            6
Model:                 13
Model name:            QEMU Virtual CPU version (cpu64-rhel6)
Stepping:              3
CPU MHz:               2892.748
BogoMIPS:              5785.49
Hypervisor vendor:     KVM
Virtualization type:   full
L1d cache:             32K
L1i cache:             32K
L2 cache:              4096K
NUMA node0 CPU(s):     0,1
Flags:                 fpu de pse tsc msr pae mce cx8 apic mtrr pge mca
cmov pse36 clflush mmx fxsr sse sse2 syscall nx lm nopl cpuid pni cx16
hypervisor lahf_lm pti


-- 
Li Wang
liwang@redhat.com

--001a114353c2cd751b056abaf6bb
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_default" style=3D"font-family:arial,he=
lvetica,sans-serif">Hi LKML &amp; LTP,</div><div class=3D"gmail_default" st=
yle=3D"font-family:arial,helvetica,sans-serif"><br></div><div class=3D"gmai=
l_default" style=3D"font-family:arial,helvetica,sans-serif">LTP/meltdown.c =
fails on upstream kernel-v4.17-rc2 with both kvm and bare-metal system. Ple=
ase attention!!!<br></div><div class=3D"gmail_default" style=3D"font-family=
:arial,helvetica,sans-serif"><br></div><div class=3D"gmail_default" style=
=3D"font-family:arial,helvetica,sans-serif">kernel-v4.17-rc2 FAIL<br></div>=
<div class=3D"gmail_default" style=3D"font-family:arial,helvetica,sans-seri=
f">kernel-v4.17-rc1 PASS</div><div class=3D"gmail_default" style=3D"font-fa=
mily:arial,helvetica,sans-serif"><br></div><div class=3D"gmail_default" sty=
le=3D"font-family:arial,helvetica,sans-serif"><br></div><div class=3D"gmail=
_default"><span style=3D"font-family:arial,helvetica,sans-serif">=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br></span></di=
v><div class=3D"gmail_default"><pre><span style=3D"font-family:arial,helvet=
ica,sans-serif">Kernel Version: 4.17.0-rc2
Machine Architecture: x86_64</span></pre></div><div class=3D"gmail_default"=
><pre><span style=3D"font-family:arial,helvetica,sans-serif">tst_test.c:101=
5: INFO: Timeout per run is 0h 50m 00s
meltdown.c:259: INFO: access time: cached =3D 51, uncached =3D 343, thresho=
ld =3D 132
meltdown.c:309: INFO: linux_proc_banner is at ffffffff8ba00060
meltdown.c:332: INFO: read ffffffff8ba00060 =3D 0x25 %
meltdown.c:332: INFO: read ffffffff8ba00061 =3D 0x73 s
meltdown.c:332: INFO: read ffffffff8ba00062 =3D 0x20 =20
meltdown.c:332: INFO: read ffffffff8ba00063 =3D 0x76 v
meltdown.c:332: INFO: read ffffffff8ba00064 =3D 0x65 e
meltdown.c:332: INFO: read ffffffff8ba00065 =3D 0x72 r
meltdown.c:332: INFO: read ffffffff8ba00066 =3D 0x73 s
meltdown.c:332: INFO: read ffffffff8ba00067 =3D 0x69 i
meltdown.c:332: INFO: read ffffffff8ba00068 =3D 0x6f o
meltdown.c:332: INFO: read ffffffff8ba00069 =3D 0x6e n
meltdown.c:332: INFO: read ffffffff8ba0006a =3D 0x20 =20
meltdown.c:332: INFO: read ffffffff8ba0006b =3D 0x25 %
meltdown.c:332: INFO: read ffffffff8ba0006c =3D 0x73 s
meltdown.c:342: FAIL: I was able to read your kernel memory!!!

Summary:
passed   0
failed   1
skipped  0
warnings 0</span></pre></div><div class=3D"gmail_default" style=3D"font-fam=
ily:arial,helvetica,sans-serif"><br></div><div class=3D"gmail_default" styl=
e=3D"font-family:arial,helvetica,sans-serif"># lscpu <br>Architecture:=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 x86_64<br>CPU op-mode(s=
):=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 32-bit, 64-bit<br>Byte Order:=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 Little E=
ndian<br>CPU(s):=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 2<br>On-line CPU(s) list:=C2=A0=C2=A0 0,1=
<br>Thread(s) per core:=C2=A0=C2=A0=C2=A0 1<br>Core(s) per socket:=C2=A0=C2=
=A0=C2=A0 1<br>Socket(s):=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 2<br>NUMA node(s):=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 1<br>Vendor ID:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 GenuineIntel<br>CPU family:=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 6<br>Model:=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 13<br>Model name:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 QEMU Virtual CPU version (cpu64-rhel6)<br>Stepp=
ing:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 3<br>CPU MHz:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 2892.748<br>BogoMIPS:=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 5785.49<br>Hyp=
ervisor vendor:=C2=A0=C2=A0=C2=A0=C2=A0 KVM<br>Virtualization type:=C2=A0=
=C2=A0 full<br>L1d cache:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 32K<br>L1i cache:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 32K<br>L2 cache:=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 4096K<br>NUMA =
node0 CPU(s):=C2=A0=C2=A0=C2=A0=C2=A0 0,1<br>Flags:=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 fp=
u de pse tsc msr pae mce cx8 apic mtrr pge mca cmov pse36 clflush mmx fxsr =
sse sse2 syscall nx lm nopl cpuid pni cx16 hypervisor lahf_lm pti<br><br cl=
ear=3D"all"></div><br>-- <br><div class=3D"gmail_signature">Li Wang<br><a h=
ref=3D"mailto:liwang@redhat.com" target=3D"_blank">liwang@redhat.com</a></d=
iv>
</div>

--001a114353c2cd751b056abaf6bb--
