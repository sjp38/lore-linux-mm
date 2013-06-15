Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 9AFDC6B0034
	for <linux-mm@kvack.org>; Sat, 15 Jun 2013 11:47:35 -0400 (EDT)
Received: by mail-ve0-f193.google.com with SMTP id d10so406156vea.8
        for <linux-mm@kvack.org>; Sat, 15 Jun 2013 08:47:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CANSQ2qd7wSJvnuFZm6819DAtA_yzsL5URB=NUMkOC6ZdP+9eaQ@mail.gmail.com>
References: <CANSQ2qd7wSJvnuFZm6819DAtA_yzsL5URB=NUMkOC6ZdP+9eaQ@mail.gmail.com>
Date: Sat, 15 Jun 2013 23:47:34 +0800
Message-ID: <CANSQ2qdhPcmXRarJYoSLfoxEUkGpz2ahrsgctQKT9q8Vi6txNg@mail.gmail.com>
Subject: Re: lenovo b490 debian install problems
From: tail wei <zhaowei.09.uibe@gmail.com>
Content-Type: multipart/alternative; boundary=001a11c24e742e20ce04df33481a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--001a11c24e742e20ce04df33481a
Content-Type: text/plain; charset=ISO-8859-1

submit@bugs.debian.org


On Sat, Jun 15, 2013 at 10:37 PM, tail wei <zhaowei.09.uibe@gmail.com>wrote:

>   hi,i'm new to debian. got debian wheezy installed by debian.exe through
> win7 this afternoon.Here are some problems that i cannot solved by
> google.if there is any chance,please help me,appreciated.
>   problems:
>     1 when i logon after gnome installed (through command line) ,parameter
> "nomodeset" must given(after some google,someone said it's KMS problems
> ,the parameter can disable it.more explain?) ,otherwise i got a black
> screen with ctrl+alt+F1`F7 and ctrl+alt+del didnot work..but with nomodeset
> ,key combination didnot work either.
>     2 the gnome got a fallback experience.it's the VGA or nvidia driver's
> problem? i tried to install nvidia drivers ,just got black screen,so
> uninstalled.
>     3 in system setting , the display noted as unknow. also the VGA or
> nvidia driver's problem?
>     4 with lspci output to check in debian HCl,just 7 devices work,9
> didnot work and 1 unknown.what should i do?
> lspci -n
> 00:00.0 0600: 8086:0154 (rev 09)
> 00:01.0 0604: 8086:0151 (rev 09)
> 00:02.0 0300: 8086:0166 (rev 09)
> 00:14.0 0c03: 8086:1e31 (rev 04)
> 00:16.0 0780: 8086:1e3a (rev 04)
> 00:1a.0 0c03: 8086:1e2d (rev 04)
> 00:1b.0 0403: 8086:1e20 (rev 04)
> 00:1c.0 0604: 8086:1e10 (rev c4)
> 00:1c.1 0604: 8086:1e12 (rev c4)
> 00:1c.3 0604: 8086:1e16 (rev c4)
> 00:1d.0 0c03: 8086:1e26 (rev 04)
> 00:1f.0 0601: 8086:1e57 (rev 04)
> 00:1f.2 0106: 8086:1e03 (rev 04)
> 00:1f.3 0c05: 8086:1e22 (rev 04)
> 01:00.0 0300: 10de:0de3 (rev a1)
> 03:00.0 0280: 14e4:4727 (rev 01)
> 04:00.0 0200: 10ec:8168 (rev 07)
>
> ----------------------------------------------------------------------------------------------------------------------
> hardwares:
> root@Jack:/home/guest# lspci
> 00:00.0 Host bridge: Intel Corporation 3rd Gen Core processor DRAM
> Controller (rev 09)
> 00:01.0 PCI bridge: Intel Corporation Xeon E3-1200 v2/3rd Gen Core
> processor PCI Express Root Port (rev 09)
> 00:02.0 VGA compatible controller: Intel Corporation 3rd Gen Core
> processor Graphics Controller (rev 09)
> 00:14.0 USB controller: Intel Corporation 7 Series/C210 Series Chipset
> Family USB xHCI Host Controller (rev 04)
> 00:16.0 Communication controller: Intel Corporation 7 Series/C210 Series
> Chipset Family MEI Controller #1 (rev 04)
> 00:1a.0 USB controller: Intel Corporation 7 Series/C210 Series Chipset
> Family USB Enhanced Host Controller #2 (rev 04)
> 00:1b.0 Audio device: Intel Corporation 7 Series/C210 Series Chipset
> Family High Definition Audio Controller (rev 04)
> 00:1c.0 PCI bridge: Intel Corporation 7 Series/C210 Series Chipset Family
> PCI Express Root Port 1 (rev c4)
> 00:1c.1 PCI bridge: Intel Corporation 7 Series/C210 Series Chipset Family
> PCI Express Root Port 2 (rev c4)
> 00:1c.3 PCI bridge: Intel Corporation 7 Series/C210 Series Chipset Family
> PCI Express Root Port 4 (rev c4)
> 00:1d.0 USB controller: Intel Corporation 7 Series/C210 Series Chipset
> Family USB Enhanced Host Controller #1 (rev 04)
> 00:1f.0 ISA bridge: Intel Corporation HM77 Express Chipset LPC Controller
> (rev 04)
> 00:1f.2 SATA controller: Intel Corporation 7 Series Chipset Family 6-port
> SATA Controller [AHCI mode] (rev 04)
> 00:1f.3 SMBus: Intel Corporation 7 Series/C210 Series Chipset Family SMBus
> Controller (rev 04)
> 01:00.0 VGA compatible controller: NVIDIA Corporation Device 0de3 (rev a1)
> 03:00.0 Network controller: Broadcom Corporation BCM4313 802.11b/g/n
> Wireless LAN Controller (rev 01)
> 04:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B
> PCI Express Gigabit Ethernet controller (rev 07)
>
> root@Jack:/home/guest# lsusb
> Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
> Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
> Bus 003 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
> Bus 004 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
> Bus 001 Device 002: ID 8087:0024 Intel Corp. Integrated Rate Matching Hub
> Bus 002 Device 002: ID 8087:0024 Intel Corp. Integrated Rate Matching Hub
> Bus 003 Device 002: ID 04d9:a070 Holtek Semiconductor, Inc.
> Bus 001 Device 003: ID 04f2:b2fb Chicony Electronics Co., Ltd
> Bus 002 Device 003: ID 058f:6366 Alcor Micro Corp. Multi Flash Reader
>
> ----------------------------------------------------------------------------------------------------------------------
> root@Jack:/home/guest# uname -a
> Linux Jack 3.2.0-4-amd64 #1 SMP Debian 3.2.41-2+deb7u2 x86_64 GNU/Linux
>
> ----------------------------------------------------------------------------------------------------------------------
> /var/log/messages and dmesg files by attachment.other information
> required,pleas contact me anytime.
>   looking forward to your reply.
> Thanks a lot.very appreciated.
>

--001a11c24e742e20ce04df33481a
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><a href=3D"mailto:submit@bugs.debian.org">submit@bugs=
.debian.org</a></div></div><div class=3D"gmail_extra"><br><br><div class=3D=
"gmail_quote">On Sat, Jun 15, 2013 at 10:37 PM, tail wei <span dir=3D"ltr">=
&lt;<a href=3D"mailto:zhaowei.09.uibe@gmail.com" target=3D"_blank">zhaowei.=
09.uibe@gmail.com</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div dir=3D"ltr"><div><div><div><div><div><d=
iv><div><div>=A0 hi,i&#39;m new to debian. got debian wheezy installed by d=
ebian.exe through win7 this afternoon.Here are some problems that i cannot =
solved by google.if there is any chance,please help me,appreciated.<br>

</div>=A0 problems:<br></div>=A0=A0=A0 1 when i logon after gnome installed=
 (through command line) ,parameter &quot;nomodeset&quot; must given(after s=
ome google,someone said it&#39;s KMS problems ,the parameter can disable it=
.more explain?) ,otherwise i got a black screen with ctrl+alt+F1`F7 and ctr=
l+alt+del didnot work..but with nomodeset ,key combination didnot work eith=
er.<br>

</div>=A0=A0=A0 2 the gnome got a fallback <a href=3D"http://experience.it"=
 target=3D"_blank">experience.it</a>&#39;s the VGA or nvidia driver&#39;s p=
roblem? i tried to install nvidia drivers ,just got black screen,so uninsta=
lled.<br>
</div>=A0=A0=A0 3 in system setting , the display noted as unknow. also the=
 VGA or nvidia driver&#39;s problem?<br>
</div>=A0=A0=A0 4 with lspci output to check in debian HCl,just 7 devices w=
ork,9 didnot work and 1 unknown.what should i do?<br>lspci -n<br>00:00.0 06=
00: 8086:0154 (rev 09)<br>00:01.0 0604: 8086:0151 (rev 09)<br>00:02.0 0300:=
 8086:0166 (rev 09)<br>

00:14.0 0c03: 8086:1e31 (rev 04)<br>00:16.0 0780: 8086:1e3a (rev 04)<br>00:=
1a.0 0c03: 8086:1e2d (rev 04)<br>00:1b.0 0403: 8086:1e20 (rev 04)<br>00:1c.=
0 0604: 8086:1e10 (rev c4)<br>00:1c.1 0604: 8086:1e12 (rev c4)<br>00:1c.3 0=
604: 8086:1e16 (rev c4)<br>

00:1d.0 0c03: 8086:1e26 (rev 04)<br>00:1f.0 0601: 8086:1e57 (rev 04)<br>00:=
1f.2 0106: 8086:1e03 (rev 04)<br>00:1f.3 0c05: 8086:1e22 (rev 04)<br>01:00.=
0 0300: 10de:0de3 (rev a1)<br>03:00.0 0280: 14e4:4727 (rev 01)<br>04:00.0 0=
200: 10ec:8168 (rev 07)<br>

---------------------------------------------------------------------------=
-------------------------------------------<br></div>hardwares:<br>root@Jac=
k:/home/guest# lspci<br>00:00.0 Host bridge: Intel Corporation 3rd Gen Core=
 processor DRAM Controller (rev 09)<br>

00:01.0 PCI bridge: Intel Corporation Xeon E3-1200 v2/3rd Gen Core processo=
r PCI Express Root Port (rev 09)<br>00:02.0 VGA compatible controller: Inte=
l Corporation 3rd Gen Core processor Graphics Controller (rev 09)<br>00:14.=
0 USB controller: Intel Corporation 7 Series/C210 Series Chipset Family USB=
 xHCI Host Controller (rev 04)<br>

00:16.0 Communication controller: Intel Corporation 7 Series/C210 Series Ch=
ipset Family MEI Controller #1 (rev 04)<br>00:1a.0 USB controller: Intel Co=
rporation 7 Series/C210 Series Chipset Family USB Enhanced Host Controller =
#2 (rev 04)<br>

00:1b.0 Audio device: Intel Corporation 7 Series/C210 Series Chipset Family=
 High Definition Audio Controller (rev 04)<br>00:1c.0 PCI bridge: Intel Cor=
poration 7 Series/C210 Series Chipset Family PCI Express Root Port 1 (rev c=
4)<br>

00:1c.1 PCI bridge: Intel Corporation 7 Series/C210 Series Chipset Family P=
CI Express Root Port 2 (rev c4)<br>00:1c.3 PCI bridge: Intel Corporation 7 =
Series/C210 Series Chipset Family PCI Express Root Port 4 (rev c4)<br>
00:1d.0 USB controller: Intel Corporation 7 Series/C210 Series Chipset Fami=
ly USB Enhanced Host Controller #1 (rev 04)<br>
00:1f.0 ISA bridge: Intel Corporation HM77 Express Chipset LPC Controller (=
rev 04)<br>00:1f.2 SATA controller: Intel Corporation 7 Series Chipset Fami=
ly 6-port SATA Controller [AHCI mode] (rev 04)<br>00:1f.3 SMBus: Intel Corp=
oration 7 Series/C210 Series Chipset Family SMBus Controller (rev 04)<br>

01:00.0 VGA compatible controller: NVIDIA Corporation Device 0de3 (rev a1)<=
br>03:00.0 Network controller: Broadcom Corporation BCM4313 802.11b/g/n Wir=
eless LAN Controller (rev 01)<br>04:00.0 Ethernet controller: Realtek Semic=
onductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller (r=
ev 07)<br>

<br>root@Jack:/home/guest# lsusb<br>Bus 001 Device 001: ID 1d6b:0002 Linux =
Foundation 2.0 root hub<br>Bus 002 Device 001: ID 1d6b:0002 Linux Foundatio=
n 2.0 root hub<br>Bus 003 Device 001: ID 1d6b:0002 Linux Foundation 2.0 roo=
t hub<br>

Bus 004 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub<br>Bus 001 D=
evice 002: ID 8087:0024 Intel Corp. Integrated Rate Matching Hub<br>Bus 002=
 Device 002: ID 8087:0024 Intel Corp. Integrated Rate Matching Hub<br>
Bus 003 Device 002: ID 04d9:a070 Holtek Semiconductor, Inc. <br>
Bus 001 Device 003: ID 04f2:b2fb Chicony Electronics Co., Ltd <br>Bus 002 D=
evice 003: ID 058f:6366 Alcor Micro Corp. Multi Flash Reader<br>-----------=
---------------------------------------------------------------------------=
--------------------------------<br>

root@Jack:/home/guest# uname -a<br>Linux Jack 3.2.0-4-amd64 #1 SMP Debian 3=
.2.41-2+deb7u2 x86_64 GNU/Linux<br>----------------------------------------=
---------------------------------------------------------------------------=
---<br>

</div>/var/log/messages and dmesg files by attachment.other information req=
uired,pleas contact me anytime.<br></div><div>=A0 looking forward to your r=
eply.<br></div>Thanks a lot.very appreciated.<br></div>
</blockquote></div><br></div>

--001a11c24e742e20ce04df33481a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
