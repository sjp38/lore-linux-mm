Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 71B326B0069
	for <linux-mm@kvack.org>; Sun,  4 Dec 2016 16:57:35 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id h201so251079301qke.7
        for <linux-mm@kvack.org>; Sun, 04 Dec 2016 13:57:35 -0800 (PST)
Received: from mail-qt0-x229.google.com (mail-qt0-x229.google.com. [2607:f8b0:400d:c0d::229])
        by mx.google.com with ESMTPS id l126si7622538qkd.76.2016.12.04.13.57.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Dec 2016 13:57:34 -0800 (PST)
Received: by mail-qt0-x229.google.com with SMTP id n6so298602743qtd.1
        for <linux-mm@kvack.org>; Sun, 04 Dec 2016 13:57:34 -0800 (PST)
MIME-Version: 1.0
From: Raymond Jennings <shentino@gmail.com>
Date: Sun, 4 Dec 2016 13:56:54 -0800
Message-ID: <CAGDaZ_r3-DxOEsGdE2y1UsS_-=UR-Qc0CsouGtcCgoXY3kVotQ@mail.gmail.com>
Subject: Silly question about dethrottling
Content-Type: multipart/alternative; boundary=001a11407a10340c4c0542dc4251
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>

--001a11407a10340c4c0542dc4251
Content-Type: text/plain; charset=UTF-8

I have an application that is generating HUGE amounts of dirty data.
Multiple GiB worth, and I'd like to allow it to fill at least half of my
RAM.

I already have /proc/sys/vm/dirty_ratio pegged at 80 and the background one
pegged at 50.  RAM is 32GiB.

it appears to be butting heads with clean memory.  How do I tell my system
to prefer using RAM to soak up writes instead of caching?

Atm I'm at the stage where I'm prepared to patch the kernel itself.

--001a11407a10340c4c0542dc4251
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">I have an application that is generating HUGE amounts of d=
irty data.=C2=A0 Multiple GiB worth, and I&#39;d like to allow it to fill a=
t least half of my RAM.<div><br></div><div>I already have /proc/sys/vm/dirt=
y_ratio pegged at 80 and the background one pegged at 50.=C2=A0 RAM is 32Gi=
B.</div><div><br></div><div>it appears to be butting heads with clean memor=
y.=C2=A0 How do I tell my system to prefer using RAM to soak up writes inst=
ead of caching?</div><div><br></div><div>Atm I&#39;m at the stage where I&#=
39;m prepared to patch the kernel itself.</div></div>

--001a11407a10340c4c0542dc4251--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
