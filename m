Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 14F4A6B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 14:22:43 -0400 (EDT)
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01CC2ABF.FE7E792D"
Subject: RE: [PATCH] REPOST: Memory tracking for physical machine migration
Date: Tue, 14 Jun 2011 14:17:49 -0400
Message-ID: <AC1B83CE65082B4DBDDB681ED2F6B2EF12E044@EXHQ.corp.stratus.com>
References: <20110610231850.6327.24452.sendpatchset@localhost.localdomain> <20110611075516.GA7745@infradead.org>
From: "Paradis, James" <James.Paradis@stratus.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01CC2ABF.FE7E792D
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable




-----Original Message-----
> From: Christoph Hellwig [mailto:hch@infradead.org]
> =20
> On Fri, Jun 10, 2011 at 07:19:06PM -0400, Jim Paradis wrote:
>> [tried posting this a couple days ago... kept having formatting =
problems
>> with the exchange server.  Let's see how this works...]
>=20
> Much more important is the problem that the patch is utterly useless
> as-is.  It just adds adds exports, but no real functionality.  It's =
not
> like I have told you exactly that a million times before, but given =
that
> you don't want to listen it might just be easier to ignore your =
patches.

Okay, then, help me out here.  What would it take for this to be =
accepted?
Would you like us to incorporate the memory-harvesting code from LKSM as =
well?

--jim



------_=_NextPart_001_01CC2ABF.FE7E792D
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.7654.12">
<TITLE>RE: [PATCH] REPOST: Memory tracking for physical machine =
migration</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/plain format -->
<BR>
<BR>
<BR>

<P><FONT SIZE=3D2>-----Original Message-----<BR>
&gt; From: Christoph Hellwig [<A =
HREF=3D"mailto:hch@infradead.org">mailto:hch@infradead.org</A>]<BR>
&gt;&nbsp;<BR>
&gt; On Fri, Jun 10, 2011 at 07:19:06PM -0400, Jim Paradis wrote:<BR>
&gt;&gt; [tried posting this a couple days ago... kept having formatting =
problems<BR>
&gt;&gt; with the exchange server.&nbsp; Let's see how this =
works...]<BR>
&gt;<BR>
&gt; Much more important is the problem that the patch is utterly =
useless<BR>
&gt; as-is.&nbsp; It just adds adds exports, but no real =
functionality.&nbsp; It's not<BR>
&gt; like I have told you exactly that a million times before, but given =
that<BR>
&gt; you don't want to listen it might just be easier to ignore your =
patches.<BR>
<BR>
Okay, then, help me out here.&nbsp; What would it take for this to be =
accepted?<BR>
Would you like us to incorporate the memory-harvesting code from LKSM as =
well?<BR>
<BR>
--jim<BR>
<BR>
<BR>
</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01CC2ABF.FE7E792D--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
