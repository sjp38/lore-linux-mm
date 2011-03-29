Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D17858D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 07:51:03 -0400 (EDT)
Subject: Re: kmemleak for MIPS
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <AANLkTim-4v5Cbp6+wHoXjgKXoS0axk1cgQ5AHF_zot80@mail.gmail.com>
References: <9bde694e1003020554p7c8ff3c2o4ae7cb5d501d1ab9@mail.gmail.com>
	 <AANLkTinnqtXf5DE+qxkTyZ9p9Mb8dXai6UxWP2HaHY3D@mail.gmail.com>
	 <1300960540.32158.13.camel@e102109-lin.cambridge.arm.com>
	 <AANLkTim139fpJsMJFLiyUYvFgGMz-Ljgd_yDrks-tqhE@mail.gmail.com>
	 <1301395206.583.53.camel@e102109-lin.cambridge.arm.com>
	 <AANLkTim-4v5Cbp6+wHoXjgKXoS0axk1cgQ5AHF_zot80@mail.gmail.com>
Date: Tue, 29 Mar 2011 12:50:54 +0100
Message-ID: <1301399454.583.66.camel@e102109-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxin John <maxin.john@gmail.com>
Cc: Daniel Baluta <dbaluta@ixiacom.com>, naveen yadav <yad.naveen@gmail.com>, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2011-03-29 at 12:38 +0100, Maxin John wrote:
> Hi,
>=20
> > You may want to disable the kmemleak testing to reduce the amount of
> > leaks reported.
>=20
> The kmemleak results in MIPS that I have included in the previous mail
> were obtained during the booting of the malta kernel.
> Later, I have checked the "real" usage by using the default
> "kmemleak_test" module.
>=20
> Following output shows the kmemleak results when I used the "kmemleak_tes=
t.ko"

Yes, that's fine to test kmemleak and show that it reports issues on
MIPS. But it shouldn't report other leaks if the test module isn't
loaded at all (removing it wouldn't remove the leaks reported as they
are permanent).

> debian-mips:~# cat /sys/kernel/debug/kmemleak
> ........

These were caused by the kmemleak test.
>=20
> > These are probably false positives.
> The previous results could be false positives. However, the current
> results are not false positives as we have intentionally created the
> memory leaks using the test module.

I was only referring to those leaks coming from udp.c and ignored the
kmemleak tests (that's why I said that you should run it again without
the kmemleak_test.ko).

> > Since the pointer referring this
> > block (udp_table) is __read_mostly, is it possible that the
> > corresponding section gets placed outside the _sdata.._edata range?
>=20
> I am not sure about this. Please  let know how can I check this.

Boot the kernel with kmemleak enabled but don't load kmemleak_test.ko.
Than you can either wait 10-15 minutes or force a scan with:

echo scan > /sys/kernel/debug/kmemleak
echo scan > /sys/kernel/debug/kmemleak
cat /sys/kernel/debug/kmemleak.

--=20
Catalin


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
