Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 38BA66B002C
	for <linux-mm@kvack.org>; Sun, 26 Feb 2012 08:11:09 -0500 (EST)
Received: by dadv6 with SMTP id v6so5054564dad.14
        for <linux-mm@kvack.org>; Sun, 26 Feb 2012 05:11:08 -0800 (PST)
Date: Sun, 26 Feb 2012 05:10:31 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Regression: Bad page map in process xyz
In-Reply-To: <201202261027.48029.maciej.rutecki@gmail.com>
Message-ID: <alpine.LSU.2.00.1202260502450.5648@eggly.anvils>
References: <4F421A29.6060303@suse.cz> <201202261027.48029.maciej.rutecki@gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1891972638-1330261843=:5648"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maciej Rutecki <maciej.rutecki@gmail.com>
Cc: Jiri Slaby <jslaby@suse.cz>, n-horiguchi@ah.jp.nec.com, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1891972638-1330261843=:5648
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Sun, 26 Feb 2012, Maciej Rutecki wrote:
> On poniedzia=C5=82ek, 20 lutego 2012 o 11:02:17 Jiri Slaby wrote:
> > Hi,
> >=20
> > I'm getting a ton of
> > BUG: Bad page map in process zypper  pte:676b700029736c6f pmd:44967067
> > when trying to upgrade the system by:
> > zypper dup
> >=20
> > I bisected that to:
> > commit afb1c03746aa940374b73a7d5750ee05a2376077
> > Author: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Date:   Fri Feb 17 10:57:58 2012 +1100
> >=20
> >     thp: optimize away unnecessary page table locking
> >=20
> > thanks,
>=20
> I created a Bugzilla entry at=20
> https://bugzilla.kernel.org/show_bug.cgi?id=3D42820
> for your bug/regression report, please add your address to the CC list in=
=20
> there, thanks!

No, thanks for spotting it, but please remove from the regressions
report: it's not a regression in 3.3-rc but in linux-next - don't take
my word for it, check the commit and you'll not find it in 3.3-rc.

We do still need to get the fix into linux-next: Horiguchi-san, has
akpm put your fix in mm-commits yet?  Please send it again if not.

Hugh
--8323584-1891972638-1330261843=:5648--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
