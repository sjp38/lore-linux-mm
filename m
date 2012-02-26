Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 667BF6B002C
	for <linux-mm@kvack.org>; Sun, 26 Feb 2012 12:04:17 -0500 (EST)
Received: by eaag11 with SMTP id g11so2924222eaa.14
        for <linux-mm@kvack.org>; Sun, 26 Feb 2012 09:04:15 -0800 (PST)
From: Maciej Rutecki <maciej.rutecki@gmail.com>
Reply-To: maciej.rutecki@gmail.com
Subject: Re: Regression: Bad page map in process xyz
Date: Sun, 26 Feb 2012 18:04:11 +0100
References: <4F421A29.6060303@suse.cz> <201202261027.48029.maciej.rutecki@gmail.com> <alpine.LSU.2.00.1202260502450.5648@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1202260502450.5648@eggly.anvils>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201202261804.11440.maciej.rutecki@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Jiri Slaby <jslaby@suse.cz>, n-horiguchi@ah.jp.nec.com, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org

On niedziela, 26 lutego 2012 o 14:10:31 Hugh Dickins wrote:
> On Sun, 26 Feb 2012, Maciej Rutecki wrote:
> > On poniedzia=C5=82ek, 20 lutego 2012 o 11:02:17 Jiri Slaby wrote:
> > > Hi,
> > >=20
> > > I'm getting a ton of
> > > BUG: Bad page map in process zypper  pte:676b700029736c6f pmd:44967067
> > > when trying to upgrade the system by:
> > > zypper dup
> > >=20
> > > I bisected that to:
> > > commit afb1c03746aa940374b73a7d5750ee05a2376077
> > > Author: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > Date:   Fri Feb 17 10:57:58 2012 +1100
> > >=20
> > >     thp: optimize away unnecessary page table locking
> > >=20
> > > thanks,
> >=20
> > I created a Bugzilla entry at
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D42820
> > for your bug/regression report, please add your address to the CC list =
in
> > there, thanks!
>=20
> No, thanks for spotting it, but please remove from the regressions
> report: it's not a regression in 3.3-rc but in linux-next - don't take
> my word for it, check the commit and you'll not find it in 3.3-rc.
>=20
> We do still need to get the fix into linux-next: Horiguchi-san, has
> akpm put your fix in mm-commits yet?  Please send it again if not.
>=20
> Hugh

Thanks for the information. I should check where is commit placed before.

Regards
=2D-=20
Maciej Rutecki
http://www.mrutecki.pl

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
