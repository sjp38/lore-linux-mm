Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 91EF06B0069
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 16:58:18 -0500 (EST)
Date: Thu, 10 Nov 2011 08:58:03 +1100
From: NeilBrown <neilb@suse.de>
Subject: Re: mdraid write performance in different kernels up to 3.0, 3.0
 shows huge improvement
Message-ID: <20111110085803.3f60c2d6@notabene.brown>
In-Reply-To: <alpine.DEB.2.00.1111081019010.19721@uplift.swm.pp.se>
References: <alpine.DEB.2.00.1111081019010.19721@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/5RI3B1BoRMOV2ePMJ_Q6r3="; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikael Abrahamsson <swmike@swm.pp.se>
Cc: linux-mm@kvack.org, linux-raid@vger.kernel.org

--Sig_/5RI3B1BoRMOV2ePMJ_Q6r3=
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 8 Nov 2011 10:28:57 +0100 (CET) Mikael Abrahamsson <swmike@swm.pp.s=
e>
wrote:

>=20
> Hello.
>=20
> I have been running mdraid->cryptsetup/LUKS->lvm->xfs on Ubuntu AMD64 wit=
h=20
> RAID5 and now RAID6 for quite some time, dating back to 2.6.27. Around=20
> 2.6.32 I saw quite a bit of regression in write performance (probably the=
=20
> implementation of barriers), 2.6.35 was acceptable, 2.6.38 was really=20
> really bad, and 3.0 is like a rocket. Best of them all.
>=20
> I'm talking about 10-20x in different in write performance on my workload=
,=20
> in combination with the older kernels throwing me page allocation failure=
s=20
> when the write load gets high, and also quite often the machine would jus=
t=20
> freeze up and had to be rebooted.
>=20
> With 2.6.38 I was down to 6-10 megabyte/s write speed, whereas 3.0 seem t=
o=20
> give me 100+ megabyte/s with the exact same workload, I've seen up to 150=
=20
> megabyte/s writes at good times. This is on a box with AES-NI, so the=20
> crypto is not the limiting factor.

That is an amazing improvement.  I wish I know what caused it I really have
no idea.  You have quite a deep stack there and the change could be anywher=
e.

Still, it is good to hear such positive reports - thanks!

NeilBrown


>=20
> I have from time to time sent out an email regarding my page allocation=20
> failures, but never really got any takers on trying to fault find it, my=
=20
> tickets with ubuntu also never got any real attention. I haven't really=20
> pushed it super hard with 3.0, but I've thrown loads at it that would mak=
e=20
> 2.6.38 lock up.
>=20
> Just wanted to send in this success report that this finally seem to have=
=20
> seen some really nice improvements!
>=20


--Sig_/5RI3B1BoRMOV2ePMJ_Q6r3=
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBTrr3aznsnt1WYoG5AQJUjw//TK0D2Z+eBRTZRLpzBMDisnfvHKbm9OaE
A3cXIA4zN+1tMBbHoanvfKQRpG8YF7wWWMUBlru32QoN+cM+yaUPouWkqZ6imb+8
unA6SvaqI/8Xodci5mS0Bn4bNBjYwAVYuKAF4a9DjjZpQcSwZwyYdMnDOhurMWTA
MuViVj+tdV8aFuJuT5lRw5YZRlLWV1xmUPoRE8GLnyMW8MU/Bd01549RRa8Fz8yU
rcgI0qlzGFtq207eRC0sbr8VOkCauYCSWrPKXweJXA5HupmTJakDS4uuFDpUOmix
+HPTuIzgER/WPVJvHc5Hz1v26v+U6HPV897kMqywV/9w4cH2esVbHDewkiQUS0ik
00lvzepaeZ3KdxtKxanJhHOgO+KCmUyMbMOjObZWD/O+SHmbciVu19szD7dDD07g
infUJO1gUc828q3TfPovrDIkuoH3ToKbJHd+c/Xs1Ew9E9qs2auQRQ1IIp7m1MdL
FvEAmy8oomD9KF1avu4lwFo1wQ/TuekTcHYCF6RhQ6g2O9zK7eWwUm7b16Ud0ZPZ
Qd8I7pJRsOQz1ceo6kiJqrMtU21vbw2qyjJhnfOMuAd5f4uWGzmahM8GbnKf/K+V
CE4LoZ0Oje/XttJ/hVN7I3hEMcab8EUKczDmv48P5DtsZcfTfiZVON/ixbxT0rqT
zZsofhTVahA=
=aTJf
-----END PGP SIGNATURE-----

--Sig_/5RI3B1BoRMOV2ePMJ_Q6r3=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
