Received: from brain ([62.252.84.143]) by mta06-svc.ntlworld.com
          (InterMail vM.4.01.02.27 201-229-119-110) with SMTP
          id <20001018200906.DSCR19246.mta06-svc.ntlworld.com@brain>
          for <linux-mm@kvack.org>; Wed, 18 Oct 2000 21:09:06 +0100
Message-ID: <001b01c0393f$bc79ddc0$c958fc3e@brain>
Reply-To: "p.hamshere" <p.hamshere@ntlworld.com>
From: "p.hamshere" <p.hamshere@ntlworld.com>
Subject: Page allocation (get_free_pages)
Date: Wed, 18 Oct 2000 21:12:26 +0100
MIME-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0018_01C03948.1D8ECBE0"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

------=_NextPart_000_0018_01C03948.1D8ECBE0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi
I'm wondering why get_free_pages allocates contiguous pages for non-DMA =
transfers and why the kernel identity (ish) maps the whole (up to 1GB) =
of physical memory to its address space...
Surely only DMA requires physically contiguous memory, and everything =
else (such as kernel stack) could be allocated via a 'vmalloc' like =
function. If this could be done cleverly, contiguous blocks could be =
held for DMA and the rest would be allocated from the random free pages =
left throughout the system.=20
Also, the kernel only *needs* to identity map its code and data, and all =
other free pages can be mapped anywhere at will - surely?
Given the large blocks may be more 'permanent' than single page =
allocation / deallocation (on the assumption they are needed to be =
present for DMA), then also the allocation could be slower and perhaps =
work on a best-fit algorithm. This then might remove the 'power of two' =
alignment dependency in the get_free_page allocation.
I know I'm missing something (extra overhead of remapping physical =
memory in the kernel page tables, lack of identity mapping and the fact =
the kernel assumes this, tracking of physical memory, my Intel-centric =
view of the world misses the MIPS architecture  -something)...but what =
is it?
Reading some books on page allocation it seems that some oses do not =
allocate contiguous page ever, including NT by the looks of it - do they =
just fudge the DMA into smaller chunks - anyone know?
Paul

------=_NextPart_000_0018_01C03948.1D8ECBE0
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META content=3D"text/html; charset=3Diso-8859-1" =
http-equiv=3DContent-Type>
<META content=3D"MSHTML 5.00.2314.1000" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>Hi</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>I'm wondering why get_free_pages =
allocates=20
contiguous pages for non-DMA transfers and why the kernel identity (ish) =
maps=20
the whole (up to 1GB) of physical memory to its address =
space...</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Surely only DMA requires physically =
contiguous=20
memory, and everything else (such as kernel stack) could be allocated =
via a=20
'vmalloc' like function. If this could be done cleverly, contiguous =
blocks could=20
be held for DMA and the rest would be allocated from the random free =
pages left=20
throughout the system. </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Also, the kernel only *needs* to =
identity map its=20
code and data, and all other free pages can be mapped anywhere at will - =

surely?</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Given the large blocks may be more =
'permanent' than=20
single page allocation&nbsp;/ deallocation (on the assumption they are =
needed to=20
be present for DMA), then also the allocation could be slower and =
perhaps work=20
on a best-fit algorithm. This then might remove the 'power of two' =
alignment=20
dependency in the get_free_page allocation.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>I know I'm missing something (extra =
overhead of=20
remapping physical memory in the kernel page tables, lack of identity =
mapping=20
and the fact the kernel assumes this, tracking of physical memory,=20
my&nbsp;Intel-centric view of the world misses the MIPS architecture =20
-something)...but what is it?</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Reading some books on page allocation =
it seems that=20
some oses do not allocate contiguous page ever, including NT by the =
looks of it=20
- do they just fudge the DMA into smaller chunks - anyone =
know?</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Paul</FONT></DIV></BODY></HTML>

------=_NextPart_000_0018_01C03948.1D8ECBE0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
