Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 10A986B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 03:19:11 -0400 (EDT)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [PATCH 2/5] vmevent: Convert from deferred timer to deferred
 work
Date: Fri, 8 Jun 2012 07:18:57 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB98269045F78E1@008-AM1MPN1-004.mgdnok.nokia.com>
References: <20120601122118.GA6128@lizard>
 <1338553446-22292-2-git-send-email-anton.vorontsov@linaro.org>
 <4FD170AA.10705@gmail.com> <20120608065828.GA1515@lizard>
 <84FF21A720B0874AA94B46D76DB98269045F7890@008-AM1MPN1-004.mgdnok.nokia.com>
 <CAHGf_=rHGotkPYJt65wv+ZDNeO2x+3c5sA8oJmGJX8ehsMHqoA@mail.gmail.com>
In-Reply-To: <CAHGf_=rHGotkPYJt65wv+ZDNeO2x+3c5sA8oJmGJX8ehsMHqoA@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: anton.vorontsov@linaro.org, penberg@kernel.org, b.zolnierkie@samsung.com, john.stultz@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

> -----Original Message-----
> From: ext KOSAKI Motohiro [mailto:kosaki.motohiro@gmail.com]
> Sent: 08 June, 2012 10:11
..
> No. I don't suggest to wake up every 100ms. I suggest to integrate existi=
ng
> subsystems. If you need any enhancement, just do it.
That will be non-trivial to hook all vmstat updates . Simple to use deferre=
d timer.

> > It also will cause page trashing because user-space code could be pushe=
d
> out from cache if VM decide.
>=20
> This is completely unrelated issue. Even if notification code is not swap=
ped,
> userland notify handling code still may be swapped. So, if you must avoid
> swap, you must use mlock.

If you wakeup only by signal when memory situation changed you can be not m=
locked.
Mlocking uses memory very inefficient way and usually cannot be applied for=
 apps which wants to be notified due to resources restrictions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
