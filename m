Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 17D9E6B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 18:25:59 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 199so9644576iou.0
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 15:25:59 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f73sor6832032itc.24.2018.01.29.15.25.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jan 2018 15:25:58 -0800 (PST)
MIME-Version: 1.0
From: Daniel Colascione <dancol@google.com>
Date: Mon, 29 Jan 2018 15:25:56 -0800
Message-ID: <CAKOZuevLegEQgaVxAtRS=-5XH5x2Q3DasL9oKJbJ6NuTeDmsQQ@mail.gmail.com>
Subject: Discrepancy between sum of smaps rss and process rss
Content-Type: multipart/alternative; boundary="001a1144b3e479589a0563f29198"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--001a1144b3e479589a0563f29198
Content-Type: text/plain; charset="UTF-8"

Hi linux-mm,

Do we expect the reporter process-wide RSS figure to differ from that of
the sum of the RSS fields of the individual VMAs as reported via smaps?
They're tracked very differently: the former is the sum
of MM_FILEPAGES, MM_ANONPAGES, and MM_SHMEMPAGES, while the latter comes
from counting pages in smaps_pte_entry (huge pages don't appear in this
context). The sum of the smaps rss fields is sometimes larger than the
counter-based values from status. Same with the anonymous sizes and the new
anonymous RSS in status.

Weirdly, I can't reproduce the discrepancy in a minimal UML boot with
init=/bin/sh (either with 4.4.88 or with latest master), but I can see this
discrepancy appear on both Android systems and normal Ubuntu 14.04 systems.

Before I spend more time debugging: is there something obvious that I
missed? Where should I be looking?

Thanks!

--001a1144b3e479589a0563f29198
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi linux-mm,<div><br></div><div>Do we expect the reporter =
process-wide RSS figure to differ from that of the sum of the RSS fields of=
 the individual VMAs as reported via smaps? They&#39;re tracked very differ=
ently: the former is the sum of=C2=A0MM_FILEPAGES,=C2=A0MM_ANONPAGES, and=
=C2=A0MM_SHMEMPAGES, while the latter comes from counting pages in smaps_pt=
e_entry (huge pages don&#39;t appear in this context). The sum of the smaps=
 rss fields is sometimes larger than the counter-based values from status. =
Same with the anonymous sizes and the new anonymous RSS in status.</div><di=
v><br></div><div>Weirdly, I can&#39;t reproduce the discrepancy in a minima=
l UML boot with init=3D/bin/sh (either with 4.4.88 or with latest master), =
but I can see this discrepancy appear on both Android systems and normal Ub=
untu 14.04 systems.</div><div><br></div><div>Before I spend more time debug=
ging: is there something obvious that I missed? Where should I be looking?<=
/div><div><br></div><div>Thanks!</div></div>

--001a1144b3e479589a0563f29198--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
