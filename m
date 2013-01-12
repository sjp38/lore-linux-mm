Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 52A196B0068
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 21:17:25 -0500 (EST)
Date: Sat, 12 Jan 2013 13:17:13 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2013-01-11-15-47 uploaded (x86 asm-offsets broken)
Message-Id: <20130112131713.749566c8d374cd77b1f2885e@canb.auug.org.au>
In-Reply-To: <50F0BFAA.10902@infradead.org>
References: <20130111234813.170A620004E@hpza10.eem.corp.google.com>
	<50F0BFAA.10902@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Sat__12_Jan_2013_13_17_13_+1100_y2CXxaYJ+hOT3aC0"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Joe Perches <joe@perches.com>

--Signature=_Sat__12_Jan_2013_13_17_13_+1100_y2CXxaYJ+hOT3aC0
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 11 Jan 2013 17:43:06 -0800 Randy Dunlap <rdunlap@infradead.org> wro=
te:
>
> b0rked.
>=20
> Some (randconfig?) causes this set of errors:
>=20
>   CC      arch/x86/kernel/asm-offsets.s
> In file included from include/linux/ktime.h:25:0,
>                  from include/linux/timer.h:5,
>                  from include/linux/workqueue.h:8,
>                  from include/linux/srcu.h:34,
>                  from include/linux/notifier.h:15,
>                  from include/linux/memory_hotplug.h:6,
>                  from include/linux/mmzone.h:761,
>                  from include/linux/gfp.h:4,
>                  from include/linux/slab.h:12,
>                  from include/linux/crypto.h:24,
>                  from arch/x86/kernel/asm-offsets.c:8:
> include/linux/jiffies.h: In function '__inline_jiffies_to_msecs':
> include/linux/jiffies.h:306:10: error: 'HZ_TO_MSEC_MUL32' undeclared (fir=
st use in this function)
> include/linux/jiffies.h:306:10: note: each undeclared identifier is repor=
ted only once for each function it appears in
> include/linux/jiffies.h:306:35: error: 'HZ_TO_MSEC_SHR32' undeclared (fir=
st use in this function)
> include/linux/jiffies.h: In function '__inline_jiffies_to_usecs':
> include/linux/jiffies.h:328:10: error: 'HZ_TO_USEC_MUL32' undeclared (fir=
st use in this function)
> include/linux/jiffies.h:328:35: error: 'HZ_TO_USEC_SHR32' undeclared (fir=
st use in this function)
> include/linux/jiffies.h: In function '__inline_msecs_to_jiffies':
> include/linux/jiffies.h:392:10: error: 'MSEC_TO_HZ_MUL32' undeclared (fir=
st use in this function)
> include/linux/jiffies.h:392:33: error: 'MSEC_TO_HZ_ADJ32' undeclared (fir=
st use in this function)
> include/linux/jiffies.h:393:6: error: 'MSEC_TO_HZ_SHR32' undeclared (firs=
t use in this function)
> include/linux/jiffies.h: In function '__inline_usecs_to_jiffies':
> include/linux/jiffies.h:413:10: error: 'USEC_TO_HZ_MUL32' undeclared (fir=
st use in this function)
> include/linux/jiffies.h:413:33: error: 'USEC_TO_HZ_ADJ32' undeclared (fir=
st use in this function)
> include/linux/jiffies.h:414:6: error: 'USEC_TO_HZ_SHR32' undeclared (firs=
t use in this function)

So, what am I missing? ... how could that have worked - those constants are
generated into kernel/timeconst.h which is only included in kernel/time.c
(from where all this code was moved to jiffies.h).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Sat__12_Jan_2013_13_17_13_+1100_y2CXxaYJ+hOT3aC0
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQ8MepAAoJEECxmPOUX5FEeS4QAIN+gxB+FZf/05RH+qNt9DSf
t0/gfB6djGH3CK/jGehsKOiHHpznYbrL5eDODjCpn7F8ByIV6vo98BDJD5r1YN9G
5a5V77F2SVmaRstByRCYLQ+tUWihaFH3L/+FFehH+n0yhXQCGHRhPRg1BH/gUbET
KWUQbrW6HNSFYzsA/CDqVYMuEi3wICuOUSx+LidTWjVH8waUbeVkHzM/p2jGG72R
l1eWtgO6vnJoaKsqoMZSKeriJd6dzh9zwz3TH8cIuEmVnSyh22kZgkx53vzq5eJ+
pXq0fEgUYFhACWSVG6bwhLBkj2O22LKOgUocjmkpc5GPEBGHNlxRc159aHySVUOj
NEJMFyDyXo0Werhx75dPZL7+8JTpUy5/HRl+zBPjXgxP7kOGGMRa8catZ0vUD3Ty
n7PI4cNH9+0ejRNACSXsjNjlBul8dmPGOVH2P3+bX36WaBLJtFrvNFfFsx7bRFx9
jOlrkurJFpQfodd8X8Bu0grNBBeO2ALOY2kuaJ9l7k+GENlAyVqxXpPpf5zqwUWT
wE6NOs5s+KamuprdL1i9cVHMKUikL5XESM4nS3v+nCtEikqxxu2huQET2UyN4VDJ
SI4jgfoK5Agks47smTkL3ziMi/omrp+cZvEXcamBQoByiFyAd2LAM/YEjye6oj1L
Kp2bsUKmjNQA5BodSzeA
=UmN4
-----END PGP SIGNATURE-----

--Signature=_Sat__12_Jan_2013_13_17_13_+1100_y2CXxaYJ+hOT3aC0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
