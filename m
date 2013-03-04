Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id E5B5E6B0002
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 05:33:10 -0500 (EST)
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01CE18C3.A9C11EC8"
Subject: how to acquire large DMA buffes in 64bit kernel
Date: Mon, 4 Mar 2013 11:33:08 +0100
Message-ID: <F12E8BD2FBBBAA4C98474AAA7FA1599101574ECE@it-dc.i-tech.local>
From: =?iso-8859-2?Q?Uro=B9_Golob?= <uros.golob@i-tech.si>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: =?iso-8859-2?Q?Uro=B9_Golob?= <uros.golob@i-tech.si>

This is a multi-part message in MIME format.

------_=_NextPart_001_01CE18C3.A9C11EC8
Content-Type: text/plain;
	charset="iso-8859-2"
Content-Transfer-Encoding: quoted-printable

Hello fellow developers,
 I am researching possibilities to acquire large DMA contiguous memory =
for our new device. Plan is to develop Linux driver for our new product =
with MicroTCA Kontron board with Intel i7 and 4GB ram (there is slim =
possibility to get 8GB system). In the same system (crate) user could =
plug in up to 10 custom devices (that is our new product with fpga chip =
and pcie interface), each board requires 4 32MB buffers in kernel =
module. So on end of day I would like to have from 128 to 1280MB of =
memory, depends of number of devices plugged into system. I know that it =
is possible to use scatter gather for DMA, but there is shortage of =
descriptors in our fpga chip...
I have come to some problems/questions and I can't find answer to, I did =
use google and read ton of documentation, books, forums, etc... with no =
luck...

 - Does Contiguous Memory Allocator support x86_64 platform? And if, how =
to configure kernel ( because there is conflict between SWIOTLB and =
HAVE_DMA_CONTIGOUS).=20
 - Is there any working bigphysarea patch for Linux kernel 3.2.x (or =
newer) for x86_64 platform (I know that there is for x86_32, but wit 32 =
bit kernel I could get only 512MB of contiguous memory).

I must confess I am total noob in device driver development, so what am =
I missing? Is there any other way to acquire large buffers in Linux =
kernel module? Am I just way too greedy with contiguous memory?

Best regards,

Uros

------_=_NextPart_001_01CE18C3.A9C11EC8
Content-Type: text/html;
	charset="iso-8859-2"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-2">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.7654.12">
<TITLE>how to acquire large DMA buffes in 64bit kernel</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/plain format -->

<P><FONT SIZE=3D2>Hello fellow developers,<BR>
&nbsp;I am researching possibilities to acquire large DMA contiguous =
memory for our new device. Plan is to develop Linux driver for our new =
product with MicroTCA Kontron board with Intel i7 and 4GB ram (there is =
slim possibility to get 8GB system). In the same system (crate) user =
could plug in up to 10 custom devices (that is our new product with fpga =
chip and pcie interface), each board requires 4 32MB buffers in kernel =
module. So on end of day I would like to have from 128 to 1280MB of =
memory, depends of number of devices plugged into system. I know that it =
is possible to use scatter gather for DMA, but there is shortage of =
descriptors in our fpga chip...<BR>
I have come to some problems/questions and I can't find answer to, I did =
use google and read ton of documentation, books, forums, etc... with no =
luck...<BR>
<BR>
&nbsp;- Does Contiguous Memory Allocator support x86_64 platform? And =
if, how to configure kernel ( because there is conflict between SWIOTLB =
and HAVE_DMA_CONTIGOUS).<BR>
&nbsp;- Is there any working bigphysarea patch for Linux kernel 3.2.x =
(or newer) for x86_64 platform (I know that there is for x86_32, but wit =
32 bit kernel I could get only 512MB of contiguous memory).<BR>
<BR>
I must confess I am total noob in device driver development, so what am =
I missing? Is there any other way to acquire large buffers in Linux =
kernel module? Am I just way too greedy with contiguous memory?<BR>
<BR>
Best regards,<BR>
<BR>
Uros</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01CE18C3.A9C11EC8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
