Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id B940D6B0080
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 23:15:29 -0400 (EDT)
Received: by widem10 with SMTP id em10so12127762wid.2
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 20:15:29 -0700 (PDT)
Received: from mail-we0-x22a.google.com (mail-we0-x22a.google.com. [2a00:1450:400c:c03::22a])
        by mx.google.com with ESMTPS id ey12si1989942wid.77.2015.03.09.20.15.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Mar 2015 20:15:28 -0700 (PDT)
Received: by wesq59 with SMTP id q59so23134751wes.9
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 20:15:27 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 9 Mar 2015 20:15:27 -0700
Message-ID: <CAN3bvwucTo41Kk+NdUf8Fa_bkVWyeMcRo2ttAJeDM0G9bHjLiw@mail.gmail.com>
Subject: Greedy kswapd reclaim behavior
From: Lock Free <atomiclong64@gmail.com>
Content-Type: multipart/alternative; boundary=047d7bf10b1cfef9d10510e68f9c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--047d7bf10b1cfef9d10510e68f9c
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

I'm trying to explain swapping out behavior that is causing
unpredictability in our app.  We=E2=80=99re running redhat kernel 2.6.32-43=
1 (yes
older) on a host that has 24GB of physical memory and a swap space of 4GB.
Swappiness is set to 10, min_free_kbytes is 90112.   Over time free memory
drop down to ~180MB due to filesystem usage over a few hours, which is
immediately followed by 2GB or 4GB of memory being reclaimed.  We expect
the free memory to be used by the file system cache, and also expect kswapd
to be triggered when min_free_kbytes is breached.  However what was not
expected was the 2-4GB of memory being reclaimed.  Our understanding is
once free memory hits high water mark which is 2 x min_free_kbytes, kswapd
duty cycle finishes.   2-3GB is usually the file system cache pages,
however the other 1-2GB are anonymous pages.  It=E2=80=99s a issue for us t=
o see
the anonymous pages swapped out because they correspond to a process (JVM)
whose performance is important to us.  This process virtual and resident
size is static at 15GB.  Why is kswapd so aggressive in reclaiming pages
when it clearly reclaimed more than high water immediately after the FS
cache was flushed?  Is this by design?

--047d7bf10b1cfef9d10510e68f9c
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">







<p class=3D"">I&#39;m trying to explain swapping out behavior that is causi=
ng unpredictability in our app.=C2=A0 We=E2=80=99re running redhat kernel 2=
.6.32-431 (yes older) on a host that has 24GB of physical memory and a swap=
 space of 4GB.=C2=A0 Swappiness is set to 10, min_free_kbytes is 90112. =C2=
=A0 Over time free memory drop down to ~180MB due to filesystem usage over =
a few hours, which is immediately followed by 2GB or 4GB of memory being re=
claimed.=C2=A0 We expect the free memory to be used by the file system cach=
e, and also expect kswapd to be triggered when min_free_kbytes is breached.=
=C2=A0 However what was not expected was the 2-4GB of memory being reclaime=
d.=C2=A0 Our understanding is once free memory hits high water mark which i=
s 2 x min_free_kbytes, kswapd duty cycle finishes. =C2=A0 2-3GB is usually =
the file system cache pages, however the other 1-2GB are anonymous pages.=
=C2=A0 It=E2=80=99s a issue for us to see the anonymous pages swapped out b=
ecause they correspond to a process (JVM) whose performance is important to=
 us.=C2=A0 This process virtual and resident size is static at 15GB.=C2=A0 =
Why is kswapd so aggressive in reclaiming pages when it clearly reclaimed m=
ore than high water immediately after the FS cache was flushed?=C2=A0 Is th=
is by design?</p></div>

--047d7bf10b1cfef9d10510e68f9c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
