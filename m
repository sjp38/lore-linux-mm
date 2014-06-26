Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f53.google.com (mail-oa0-f53.google.com [209.85.219.53])
	by kanga.kvack.org (Postfix) with ESMTP id C74B26B0069
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 09:00:53 -0400 (EDT)
Received: by mail-oa0-f53.google.com with SMTP id l6so3884528oag.12
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 06:00:53 -0700 (PDT)
Received: from mx10.nec.com (mx10.nec.com. [143.101.113.5])
        by mx.google.com with ESMTPS id e10si9732305oeu.26.2014.06.26.06.00.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Jun 2014 06:00:53 -0700 (PDT)
Content-Class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01CF913E.A7E9CDA7"
Subject: RE: [mempolicy] 5507231dd04: -18.2% vm-scalability.migrate_mbps
Date: Thu, 26 Jun 2014 07:59:41 -0500
Message-ID: <FC3CA273EA98D94B96901B237F5F506BB61DB1@irvmail101.necam.prv>
References: <a2aff3e6884b425481b1dd542effbb87@BPXC19GP.gisp.nec.co.jp>
From: "Horiguchi, Naoya" <Naoya.Horiguchi@necam.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jet Chen <jet.chen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKP <lkp@01.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

------_=_NextPart_001_01CF913E.A7E9CDA7
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit

> Hi Naoya,                                                                                      
>
> FYI, we noticed the below changes on
>
> git://git.kernel.org/pub/scm/linux/kernel/git/balbi/usb.git am437x-starterkit
> commit 5507231dd04d3d68796bafe83e6a20c985a0ef68 ("mempolicy: apply page table walker on queue_pages_range()")

This patch is to be revised with one with less performance impact,
where I stop calling ->pte_entry() callback heavily.

Thanks,
Naoya Horiguchi

------_=_NextPart_001_01CF913E.A7E9CDA7
Content-Type: text/html; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-2022-jp">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.7654.12">
<TITLE>RE: [mempolicy] 5507231dd04: -18.2% =
vm-scalability.migrate_mbps</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/plain format -->

<P><FONT SIZE=3D2>&gt; Hi =
Naoya,&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;<BR>
&gt;<BR>
&gt; FYI, we noticed the below changes on<BR>
&gt;<BR>
&gt; git://git.kernel.org/pub/scm/linux/kernel/git/balbi/usb.git =
am437x-starterkit<BR>
&gt; commit 5507231dd04d3d68796bafe83e6a20c985a0ef68 (&quot;mempolicy: =
apply page table walker on queue_pages_range()&quot;)<BR>
<BR>
This patch is to be revised with one with less performance impact,<BR>
where I stop calling -&gt;pte_entry() callback heavily.<BR>
<BR>
Thanks,<BR>
Naoya Horiguchi<BR>
</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01CF913E.A7E9CDA7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
