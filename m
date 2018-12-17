Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 24AF18E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 03:26:54 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id t83so6502141oie.16
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 00:26:54 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k90sor7707555otk.104.2018.12.17.00.26.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Dec 2018 00:26:52 -0800 (PST)
MIME-Version: 1.0
From: vijay nag <vijunag@gmail.com>
Date: Mon, 17 Dec 2018 13:56:40 +0530
Message-ID: <CAKhyrx-gbHjzWyeUERrXhH2CGMEMZeFX66Q-POD7Q+hKwWA1kw@mail.gmail.com>
Subject: Cgroups support for THP
Content-Type: multipart/alternative; boundary="000000000000fd7415057d338a2d"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--000000000000fd7415057d338a2d
Content-Type: text/plain; charset="UTF-8"

Hello Linux-MM,

My containerized application which is suppose to have a very low RSS(by
default containers patterns are to have low memory footprint) seems to be
getting its BSS segment RSS bloated due to THPs. Although there is a huge
zero page support, the overhead seems to be at-least 2MB even when a byte
is dirtied. Also there are tune-able to disable this feature,  but this
seems to be a system wide setting. Is there a plan to make this setting
cgroup aware ?

Thanks,
Vijay Nag

--000000000000fd7415057d338a2d
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Hello Linux-MM, <br></div><div><br></div><div>My cont=
ainerized application which is suppose to have a very low RSS(by default co=
ntainers patterns are to have low memory footprint) seems to be getting its=
 BSS segment RSS bloated due to THPs. Although there is a huge zero page su=
pport, the overhead seems to be at-least 2MB even when a byte is dirtied. A=
lso there are tune-able to disable this feature,=C2=A0 but this seems to be=
 a system wide setting. Is there a plan to make this setting cgroup aware ?=
</div><div><br></div><div>Thanks,</div><div>Vijay Nag<br></div></div>

--000000000000fd7415057d338a2d--
