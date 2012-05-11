Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id D8C428D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:14:24 -0400 (EDT)
Date: Sat, 12 May 2012 01:14:19 +0300
From: Sami Liedes <sami.liedes@iki.fi>
Subject: Re: [Bug 43227] New: BUG: Bad page state in process wcg_gfam_6.11_i
Message-ID: <20120511221419.GC7387@sli.dy.fi>
References: <bug-43227-27@https.bugzilla.kernel.org/>
 <20120511125921.a888e12c.akpm@linux-foundation.org>
 <20120511200615.GA12268@redhat.com>
 <20120511131003.282e9daa.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="1SQmhf2mF2YjsYvc"
Content-Disposition: inline
In-Reply-To: <20120511131003.282e9daa.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org


--1SQmhf2mF2YjsYvc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, May 11, 2012 at 01:10:03PM -0700, Andrew Morton wrote:
> That narrows it down to a 3.3.2 -> 3.3.4 regression, perhaps.

I believe 3.3.2 -> 3.3.3 in that case; I also hit this on 3.3.3
yesterday after downgrading 3.3.5 -> 3.3.3, although in that case I
got a large number (total of 36) bad page state warnings within a
single second. I have been using 3.3.2 succesfully for quite a while
before I first saw this when I upgraded to 3.3.5.

	Sami

--1SQmhf2mF2YjsYvc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCgAGBQJPrY87AAoJEKLT589SE0a0YpkP/1F6CfE7P6T0IWB1oaV05U++
sMIJocoQFifxa8Mw91t9LJ6st8KMEPaPw8ozdTM+goZbvXy0j0NcAVPFcCZWMKoD
OihSng0+Um9LFEzPTzNtNXgTVQeIpCKkb2EtadA8gX3aqb4+2HmaN6jyGGGhRDxg
RCQxNA5G2V4aCEhKZxOIE1dfb/2QKf0+VU37EI7hKteO76nmZfO3AwCWGp03YTW4
H4WdX9cfXeOEHynRiyAbLXmX/6zR3/BRpRAghY7nI2gIRzQvyGevZV3oIxW0gDGb
toIfV6D9d7a8vnjcbriX0ekL9shS87teZP0/Bl3YM0upCj0vJ5pA/ZfUU7qG1EGX
sgMFyxdnVl9OA0MaOij2F3xgn7cBrDjfE9OAIyQqcOYyFsRRKs0G0QRAtDA7zR9F
boN2A6/fxjBZSOJkgruwLkApJ+twWsG1wb7N4knQWNMgjKiHX/xMhyIexrcwB6dJ
wsQZKDOOAXQFQtW5FyxY+Q49D9/3d5LhCTH7rPa6N2wjxBcjsp2i3yClalW9OBpa
uRNb85pVxini6kH1W+XshbIR10cIfzIGZ4DlFgE9vptBL5oG3GU1os7ivd3HUOA0
nAvp6sJgW9baN574aTg1jNcKQygJVxuUknpsmZA8mGSFW4jd7hgMNNA+WZdGEUYv
WaYZQyUmlQArRTnk4QUz
=AObR
-----END PGP SIGNATURE-----

--1SQmhf2mF2YjsYvc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
