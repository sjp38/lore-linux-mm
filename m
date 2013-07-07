Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id B0E6E6B0036
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 07:59:18 -0400 (EDT)
Received: by mail-ve0-f177.google.com with SMTP id cz10so2773317veb.8
        for <linux-mm@kvack.org>; Sun, 07 Jul 2013 04:59:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1373197978.26573.7.camel@warfang>
References: <1373197450.26573.5.camel@warfang> <1373197978.26573.7.camel@warfang>
From: Raymond Jennings <shentino@gmail.com>
Date: Sun, 7 Jul 2013 04:58:37 -0700
Message-ID: <CAGDaZ_oKhYs3jUjZEJFFVsudd4N1UDiLCd30YBxK-V70CU=zDg@mail.gmail.com>
Subject: Re: [PATCH] swap: warn when a swap area overflows the maximum size (resent)
Content-Type: multipart/alternative; boundary=001a11c2577451bb1104e0eaa865
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Valdis Kletnieks <valdis.kletnieks@vt.edu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

--001a11c2577451bb1104e0eaa865
Content-Type: text/plain; charset=UTF-8

Typo in the second test.

The first line should read:

# lvresize /dev/system/swap --size 64G

First ever serious patch, got excited and burned the copypasta.

--001a11c2577451bb1104e0eaa865
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><span style=3D"font-family:arial,sans-serif;font-size=
:13px">Typo in the second test.</span></div><div><span style=3D"font-family=
:arial,sans-serif;font-size:13px"><br></span></div><div><span style=3D"font=
-family:arial,sans-serif;font-size:13px">The first line should read:</span>=
</div>

<div><span style=3D"font-family:arial,sans-serif;font-size:13px"><br></span=
></div><span style=3D"font-family:arial,sans-serif;font-size:13px"># lvresi=
ze /dev/system/swap --size 64G</span><br><div class=3D"gmail_extra"><br></d=
iv>

<div class=3D"gmail_extra">First ever serious patch, got excited and burned=
 the copypasta.</div><div class=3D"gmail_extra"><br></div></div>

--001a11c2577451bb1104e0eaa865--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
