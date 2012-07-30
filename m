Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 8C89E6B004D
	for <linux-mm@kvack.org>; Sun, 29 Jul 2012 21:13:20 -0400 (EDT)
Message-ID: <1343610786.4642.43.camel@deadeye.wl.decadent.org.uk>
Subject: Re: [PATCH 00/34] Memory management performance backports for
 -stable V2
From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 30 Jul 2012 02:13:06 +0100
In-Reply-To: <1343050727-3045-1-git-send-email-mgorman@suse.de>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ODL14XBlU3e+F2ONUL8N"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Stable <stable@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


--=-ODL14XBlU3e+F2ONUL8N
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-07-23 at 14:38 +0100, Mel Gorman wrote:
> Changelog since V1
>   o Expand some of the notes					(jrnieder)
>   o Correct upstream commit SHA1				(hugh)
>=20
> This series is related to the new addition to stable_kernel_rules.txt
>=20
>  - Serious issues as reported by a user of a distribution kernel may also
>    be considered if they fix a notable performance or interactivity issue=
.
>    As these fixes are not as obvious and have a higher risk of a subtle
>    regression they should only be submitted by a distribution kernel
>    maintainer and include an addendum linking to a bugzilla entry if it
>    exists and additional information on the user-visible impact.
>=20
> All of these patches have been backported to a distribution kernel and
> address some sort of performance issue in the VM. As they are not all
> obvious, I've added a "Stable note" to the top of each patch giving
> additional information on why the patch was backported. Lets see where
> the boundaries lie on how this new rule is interpreted in practice :).
>
> Patch 1	Performance fix for tmpfs
> Patch 2 Memory hotadd fix
> Patch 3 Reduce boot time on large machines
> Patches 4-5 Reduce stalls for wait_iff_congested
> Patches 6-8 Reduce excessive reclaim of slab objects which for some workl=
oads
> 	will reduce the amount of IO required
> Patches 9-10 limits the amount of page reclaim when THP/Compaction is act=
ive.
> 	Excessive reclaim in low memory situations can lead to stalls some
> 	of which are user visible.
> Patches 11-19 reduce the amount of churn of the LRU lists. Poor reclaim
> 	decisions can impair workloads in different ways and there have
> 	been complaints recently the reclaim decisions of modern kernels
> 	are worse than older ones.
> Patches 20-21 reduce the amount of CPU kswapd uses in some cases. This
> 	is harder to trigger but were developed due to bug reports about
> 	100% CPU usage from kswapd.
> Patches 22-25 are mostly related to interactivity when THP is enabled.
> Patches 26-30 are also related to page reclaim decisions, particularly
> 	the residency of mapped pages.
> Patches 31-34 fix a major page allocator performance regression
[...]
> The patches are based on 3.0.36 but there should not be problems applying
> the series to later stable releases.
[...]

Patches 1-2, 4-15, 20-21, 31-32 correspond to commits included in Linux
3.2.  I've added the rest to the queue for 3.2.y, generally using the
versions Greg has queued for 3.0.39.

Patch 30 'mm: vmscan: convert global reclaim to per-memcg LRU lists'
needed a further context change.

For patch 33 'cpuset: mm: reduce large amounts of memory barrier related
damage v3' I folded in the two fixes Herton pointed out and you
acknowledged, and took the upstream version of the changes to
get_any_partial() in slub.c.

Ben.

--=20
Ben Hutchings
It is impossible to make anything foolproof because fools are so ingenious.

--=-ODL14XBlU3e+F2ONUL8N
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUBXfoue/yOyVhhEJAQq36w//UIdM/5QLkClI1TQNB1yL8Ont6djXbqi9
g5OKxPGNRJZhhmlL9xpoVhoKyC81zQSx8wRRpQEa5ewN8OEaP0ROHxWTXVpxU8wJ
QFbrPR7cPKZhgueF4irZeumv0Qgow0BQbYTBec9rwthaVrf7TI7xTF3Xku0AFUTX
ydA2HEwiTT0+FKTc48zTHrGnZbzKoSPs1kwG/MTavXQj64hEIRSyZfOVI/3PoRw4
9MGfcmvs7K940fqBR5FL9rkhtMroq7JLLbiBigIG9gHVARTWXGFR9fUoF1ij2PuN
impxbyqiHzC5F2WWs6WyTMj9icOmAdeojTUmVS9PcTQO3CGdmw05+Fg6gl1KNeqY
QjOm+vmldwvg5G0nGXl1OpcdK+o3AJ7aYxeCX7a4Ut+XUxChlouGsXi1WeQgUJu3
o0DkEAEBPliWttIQ1aoz7CIzp8jWQSOniPUKXmWXs5YuQUCBSeLHcDV51xDHdRBr
ZorI3ulUZ2XQYhwUeXgT3ge+ispHAcerxVQDXHtX6SsbjMqbwZ+FufpHNx4pydZr
WO8OLsofJiNx43V2bpZx2qdDMz8hUkDrGikWRGVHjpBUFVegaXpPE9UxXMBqC4/A
ygsqz2Z3wZgmuC/rYbyTZ5z2KSPDzl+MG9pvj2lHXxVuKziORQaucRZwY1qZcXQF
zzKlDDJ34Ok=
=YyYI
-----END PGP SIGNATURE-----

--=-ODL14XBlU3e+F2ONUL8N--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
