Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id D89676B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 05:44:53 -0500 (EST)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [RFC 1/3] /dev/low_mem_notify
Date: Wed, 18 Jan 2012 10:44:13 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB982690455978C@008-AM1MPN1-003.mgdnok.nokia.com>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org>
	<1326788038-29141-2-git-send-email-minchan@kernel.org>
	<CAOJsxLHGYmVNk7D9NyhRuqQDwquDuA7LtUtp-1huSn5F-GvtAg@mail.gmail.com>
	<4F15A34F.40808@redhat.com>
	<alpine.LFD.2.02.1201172044310.15303@tux.localdomain>
	<84FF21A720B0874AA94B46D76DB98269045596AE@008-AM1MPN1-003.mgdnok.nokia.com>
	<CAOJsxLGiG_Bsp8eMtqCjFToxYAPCE4HC9XCebpZ+-G8E3gg5bw@mail.gmail.com>
	<84FF21A720B0874AA94B46D76DB98269045596EA@008-AM1MPN1-003.mgdnok.nokia.com>
 <CAOJsxLG4hMrAdsyOg6QUe71SPqEBq3eZXvRvaKFZQo8HS1vphQ@mail.gmail.com>
In-Reply-To: <CAOJsxLG4hMrAdsyOg6QUe71SPqEBq3eZXvRvaKFZQo8HS1vphQ@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@kernel.org
Cc: riel@redhat.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, kosaki.motohiro@gmail.com, hannes@cmpxchg.org, mtosatti@redhat.com, akpm@linux-foundation.org, rhod@redhat.com, kosaki.motohiro@jp.fujitsu.com

> -----Original Message-----
> From: penberg@gmail.com [mailto:penberg@gmail.com] On Behalf Of ext
> Pekka Enberg
> Sent: 18 January, 2012 12:40
...
> > Not worse than %%. For example you had 10% free memory threshold for
> > 512 MB RAM meaning 51.2 MB in absolute number.  Then hotplug turned
> > off 256 MB, you for sure must update threshold for %% because these
> > 10% for 25.6 MB most likely will be not suitable for different operatin=
g
> mode.
> > Using pages makes calculations must simpler.
>=20
> Right. Does threshold in percentages make any sense then? Is it enough to
> use number of free pages?

Paul Mundt noticed that and we stopped use percentage in 2006 for n770 upda=
te.=20
He was right.
Percents are useless and do not correlate with other kernel APIs like sysin=
fo().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
