Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id B081E6B0005
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 15:07:57 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id w104so186568134qge.1
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 12:07:57 -0700 (PDT)
Received: from DUB004-OMC3S19.hotmail.com (dub004-omc3s19.hotmail.com. [157.55.2.28])
        by mx.google.com with ESMTPS id 92si11466500qgz.58.2016.03.22.12.07.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 Mar 2016 12:07:56 -0700 (PDT)
Message-ID: <DUB128-W107FCE75365A03B067D06B9C800@phx.gbl>
From: David Binderman <dcb314@hotmail.com>
Subject: mm/memblock.c:843: pointless test ?
Date: Tue, 22 Mar 2016 19:07:55 +0000
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

Hello there=2C=0A=
=0A=
mm/memblock.c:843:11: warning: comparison of unsigned expression>=3D 0 is a=
lways true [-Wtype-limits]=0A=
=0A=
Source code is=0A=
=0A=
=A0=A0=A0 if (*idx>=3D 0 && *idx < type->cnt) {=0A=
=0A=
but=0A=
=0A=
void __init_memblock __next_reserved_mem_region(u64 *idx=2C=0A=
=0A=
Suggest avoid pointless test.=0A=
=0A=
=0A=
Regards=0A=
=0A=
David Binderman=0A=
 		 	   		  =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
