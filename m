Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 2B4806B0032
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 02:22:35 -0400 (EDT)
Date: Fri, 16 Aug 2013 16:22:17 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [Bug] Reproducible data corruption on i5-3340M: Please continue
 your great work! :-)
Message-Id: <20130816162217.dfd6b88266b772d893f90bb8@canb.auug.org.au>
In-Reply-To: <CA+55aFwFx7uhtDTX5vfiYRo+keLmuvxvSFupU4nB8g1KCN-WVg@mail.gmail.com>
References: <52050382.9060802@gmail.com>
	<520BB225.8030807@gmail.com>
	<20130814174039.GA24033@dhcp22.suse.cz>
	<CA+55aFwAz7GdcB6nC0Th42y8eAM591sKO1=mYh5SWgyuDdHzcA@mail.gmail.com>
	<20130814182756.GD24033@dhcp22.suse.cz>
	<CA+55aFxB6Wyj3G3Ju8E7bjH-706vi3vysuATUZ13h1tdYbCbnQ@mail.gmail.com>
	<520C9E78.2020401@gmail.com>
	<CA+55aFy2D2hTc_ina1DvungsCL4WU2OTM=bnVb8sDyDcGVCBEQ@mail.gmail.com>
	<CA+55aFxuUrcod=X2t2yqR_zJ4s1uaCsGB-p1oLTQrG+y+Z2PbA@mail.gmail.com>
	<520D5ED2.9040403@gmail.com>
	<CA+55aFwFx7uhtDTX5vfiYRo+keLmuvxvSFupU4nB8g1KCN-WVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__16_Aug_2013_16_22_17_+1000_gwq8T6YN=ISaACzP"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ben Tebulin <tebulin@googlemail.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

--Signature=_Fri__16_Aug_2013_16_22_17_+1000_gwq8T6YN=ISaACzP
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Linus,

On Thu, 15 Aug 2013 17:33:28 -0700 Linus Torvalds <torvalds@linux-foundatio=
n.org> wrote:
>
> I'll probably delay committing it until tomorrow, in the hope that
> somebody using one of the other architectures will at least ack that
> it compiles. I'm re-attaching the patch (with the two "logn" -> "long"
> fixes) just to encourage that. Hint hint, everybody..

I built all the (major) PowerPC defconfigs, allnoconfig and allmodconfig
and they built as well as they did before this patch (i.e. some failed
for other reasons).  I have not done any boot testing on PowerPC.=20

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__16_Aug_2013_16_22_17_+1000_gwq8T6YN=ISaACzP
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIbBAEBCAAGBQJSDcUgAAoJEECxmPOUX5FEosoP+IStSdd54sfyppn5kkBhxf80
k8Bn0fIY9WNsaxjlY+cXfValHQiuUBPGmi3V8/42JETlVBDgFzhFPidDZRB1qW2+
ABNE8GiU0lztpkLijCTOzJmttY/5P+lqPhv22MjBcGSStUCgoUdB1hYYLGHmsWQL
2olYRNk9GPowIpCc8zdAGzC9JS4boi52xKYZVLsmuxu7+4hjO+J+oDu9s7JqRJHK
jkgtGfHPuknpQYCzlhio/qWrf8oW8Q7y9qFqoa0bgioIW1Sp4g3917xmNo8qk9wO
eHvCISosLzwOuOxUvXVyqsuvCbAnV6wq13UYwhCeVO6w326GGQ6wGNSxB1kLIpvT
yE2DEhvAD7ai/88u2j83wv7TNxW39l39M0eWrT6SUhoIi13qAaG+f8n7KC1vn0c3
KmL2I+/3Xr0SUHsJzPLCMP/x7HmiH++eAng5FYX4COLbmkqmPvZeFg5g/BpodI4S
8xa1ftygy1YNkO1epPY3gY3+asnBPLYXFnRvleI7ASJ3b332oUDs0+HdU1JFpzrd
snn/5/CiOXXg6ivRZ2GSUjht2lZcFalOwpX1Y/NJGaJdaPvYmeqcXNlLde7kdnHw
ktAwfK6f3CvCedO9azkZ87yiey18SEA5wsWKA0tF3SD9r8lUfRZKC3kZwZjxfNBq
DEH56qoP4SLlMLxOZVM=
=fXUB
-----END PGP SIGNATURE-----

--Signature=_Fri__16_Aug_2013_16_22_17_+1000_gwq8T6YN=ISaACzP--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
