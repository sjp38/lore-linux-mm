Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 023366B0083
	for <linux-mm@kvack.org>; Sun, 26 Feb 2012 04:27:53 -0500 (EST)
Received: by eeke53 with SMTP id e53so2085043eek.14
        for <linux-mm@kvack.org>; Sun, 26 Feb 2012 01:27:52 -0800 (PST)
From: Maciej Rutecki <maciej.rutecki@gmail.com>
Reply-To: maciej.rutecki@gmail.com
Subject: Re: Regression: Bad page map in process xyz
Date: Sun, 26 Feb 2012 10:27:47 +0100
References: <4F421A29.6060303@suse.cz>
In-Reply-To: <4F421A29.6060303@suse.cz>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201202261027.48029.maciej.rutecki@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: n-horiguchi@ah.jp.nec.com, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org

On poniedzia=C5=82ek, 20 lutego 2012 o 11:02:17 Jiri Slaby wrote:
> Hi,
>=20
> I'm getting a ton of
> BUG: Bad page map in process zypper  pte:676b700029736c6f pmd:44967067
> when trying to upgrade the system by:
> zypper dup
>=20
> I bisected that to:
> commit afb1c03746aa940374b73a7d5750ee05a2376077
> Author: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date:   Fri Feb 17 10:57:58 2012 +1100
>=20
>     thp: optimize away unnecessary page table locking
>=20
> thanks,

I created a Bugzilla entry at=20
https://bugzilla.kernel.org/show_bug.cgi?id=3D42820
for your bug/regression report, please add your address to the CC list in=20
there, thanks!
=2D-=20
Maciej Rutecki
http://www.mrutecki.pl

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
