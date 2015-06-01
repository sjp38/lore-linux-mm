Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id A67FA6B0038
	for <linux-mm@kvack.org>; Sun, 31 May 2015 22:05:03 -0400 (EDT)
Received: by qkx62 with SMTP id 62so77002828qkx.3
        for <linux-mm@kvack.org>; Sun, 31 May 2015 19:05:03 -0700 (PDT)
Received: from mail-qc0-x22d.google.com (mail-qc0-x22d.google.com. [2607:f8b0:400d:c01::22d])
        by mx.google.com with ESMTPS id 76si11955828qku.38.2015.05.31.19.05.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 31 May 2015 19:05:02 -0700 (PDT)
Received: by qczw4 with SMTP id w4so18294601qcz.2
        for <linux-mm@kvack.org>; Sun, 31 May 2015 19:05:02 -0700 (PDT)
MIME-Version: 1.0
Date: Sun, 31 May 2015 22:05:02 -0400
Message-ID: <CAD6TEOBtaWsYAx8YYUdTzgm8vRUzjiSKz3BVf4vnUk_Wn6tVwQ@mail.gmail.com>
Subject: Is free_all_bootmem broken for ARM in Linux 4.0
From: Andy Joe <jyizheng@gmail.com>
Content-Type: multipart/alternative; boundary=001a113a9bc0f4949105176b40fb
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--001a113a9bc0f4949105176b40fb
Content-Type: text/plain; charset=UTF-8

Hi Experts,

I found that there some modifications to the initialization of memory
system for ARM. In particular, init_bootmem_node is no longer called.
But free_all_bootmem is still in use. In this sense, the global variable
bdata_list is empty. I wonder how the new code is able to free pages
to buddy system. Is this an issue?

The related code are listed below.

http://lxr.free-electrons.com/source/arch/arm/mm/init.c#L530
http://lxr.free-electrons.com/source/mm/bootmem.c#L272

Please help.
Thanks,

Yizheng

--001a113a9bc0f4949105176b40fb
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Experts,<div><br></div><div>I found that there some mod=
ifications to the initialization of memory</div><div>system for ARM. In par=
ticular, init_bootmem_node is no longer called.</div><div>But free_all_boot=
mem is still in use. In this sense, the global variable=C2=A0</div><div>bda=
ta_list is empty. I wonder how the new code is able to free pages=C2=A0</di=
v><div>to buddy system. Is this an issue?</div><div><br></div><div>The rela=
ted code are listed below.</div><div><br></div><div><a href=3D"http://lxr.f=
ree-electrons.com/source/arch/arm/mm/init.c#L530">http://lxr.free-electrons=
.com/source/arch/arm/mm/init.c#L530</a>=C2=A0</div><div><a href=3D"http://l=
xr.free-electrons.com/source/mm/bootmem.c#L272">http://lxr.free-electrons.c=
om/source/mm/bootmem.c#L272</a><br></div><div><br></div><div>Please help.=
=C2=A0</div><div>Thanks,</div><div><br></div><div>Yizheng</div></div>

--001a113a9bc0f4949105176b40fb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
