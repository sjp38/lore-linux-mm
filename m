Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3372D6B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 11:26:41 -0400 (EDT)
Received: by wyg36 with SMTP id 36so990488wyg.14
        for <linux-mm@kvack.org>; Wed, 18 Aug 2010 08:26:38 -0700 (PDT)
Date: Wed, 18 Aug 2010 17:26:27 +0200
From: Alejandro Riveira =?UTF-8?B?RmVybsOhbmRleg==?= <ariveira@gmail.com>
Subject: Re: android-kernel memory reclaim x20 boost?
Message-ID: <20100818172627.7e38969f@varda>
In-Reply-To: <20100818151857.GA6188@barrios-desktop>
References: <20100818151857.GA6188@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Arve =?UTF-8?B?SGrDuG5uZXbDpWc=?= <arve@android.com>, swetland@google.com, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

El Thu, 19 Aug 2010 00:18:57 +0900
Minchan Kim <minchan.kim@gmail.com> escribi=C3=B3:

> Hello Android forks,
[ ... ]
>=20
> I saw the advertisement phrase in this[1].=20
>=20
> "Kernel Memory Management Boost: Improved memory reclaim by up to 20x,=20
> which results in faster app switching and smoother performance=20
> on memory-constrained devices."
>=20
> But I can't find any code for it in android kernel git tree.

 Maybe the enhancements are on the Dalvik VM (shooting in the dark here)=20

> If it's your private patch, could you explan what kinds of feature can en=
hance=20
> it by up to 20x?
>=20
> If it is really good, we can merge it to mainline.=20
>=20
> [1] http://developer.android.com/sdk/android-2.2-highlights.html
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
