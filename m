Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 59B176B0073
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 03:49:23 -0400 (EDT)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [PATCH 2/5] vmevent: Convert from deferred timer to deferred
 work
Date: Fri, 8 Jun 2012 07:49:06 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB98269045F7956@008-AM1MPN1-004.mgdnok.nokia.com>
References: <20120601122118.GA6128@lizard>
 <1338553446-22292-2-git-send-email-anton.vorontsov@linaro.org>
 <4FD170AA.10705@gmail.com> <20120608065828.GA1515@lizard>
 <84FF21A720B0874AA94B46D76DB98269045F7890@008-AM1MPN1-004.mgdnok.nokia.com>
 <CAHGf_=rHGotkPYJt65wv+ZDNeO2x+3c5sA8oJmGJX8ehsMHqoA@mail.gmail.com>
 <84FF21A720B0874AA94B46D76DB98269045F78E1@008-AM1MPN1-004.mgdnok.nokia.com>
 <CAHGf_=pNJAQP4GhTwtOkBxUDYU4n_-CKmKU7T4PzszwdL9Ju6Q@mail.gmail.com>
 <84FF21A720B0874AA94B46D76DB98269045F7918@008-AM1MPN1-004.mgdnok.nokia.com>
 <4FD1AABD.7010602@gmail.com>
In-Reply-To: <4FD1AABD.7010602@gmail.com>
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
> Sent: 08 June, 2012 10:33
> To: Moiseichuk Leonid (Nokia-MP/Espoo)
..=20
> Wrong. CPU don't realized the running code belong to userspace or kernel.
> Every code just consume a power. That's why polling timer is wrong from
> point of power consumption view.
???
We are talking about different things.
User-space code could be dropped, distributed between several applications =
and has not deferred timers support.
For polling API the user-space code has to be executed quite often.
Localizing this code in kernel additionally allows to avoid vmsat/meminfo g=
eneration and parsing overhead as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
