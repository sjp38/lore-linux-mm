Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 690576B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 10:59:07 -0500 (EST)
Received: by mail-oi0-f54.google.com with SMTP id k206so177992106oia.1
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 07:59:07 -0800 (PST)
Received: from DUB004-OMC3S15.hotmail.com (dub004-omc3s15.hotmail.com. [157.55.2.24])
        by mx.google.com with ESMTPS id j3si27332016oeq.41.2016.01.18.07.59.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Jan 2016 07:59:06 -0800 (PST)
Message-ID: <DUB128-W86263FEE560D2053CF19D09CC00@phx.gbl>
From: David Binderman <dcb314@hotmail.com>
Subject: linux-next/mm/vmscan.c:3751: possible poor choice of data type ?
Date: Mon, 18 Jan 2016 15:59:04 +0000
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

Hello there=2C=0A=
=0A=
=A0[linux-next/mm/vmscan.c:3751]: (style) int result is assigned to long va=
riable.=0A=
=0A=
=A0 const unsigned long nr_pages =3D 1 << order=3B=0A=
=0A=
Maybe something like=0A=
=0A=
=A0 const unsigned long nr_pages =3D 1UL << order=3B=0A=
=0A=
would be better code.=0A=
=0A=
=0A=
Regards=0A=
=0A=
David Binderman=0A=
=0A=
 		 	   		  =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
