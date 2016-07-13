Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id AAA8C6B0253
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 15:49:00 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id f7so108444658qkc.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 12:49:00 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [74.92.59.67])
        by mx.google.com with ESMTPS id d29si2984026qkh.218.2016.07.13.12.48.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jul 2016 12:48:58 -0700 (PDT)
Message-ID: <1468439322.17053.13.camel@surriel.com>
Subject: Re: [PATCH 3/3] Add name fields in shrinker tracepoint definitions
From: Rik van Riel <riel@surriel.com>
Date: Wed, 13 Jul 2016 15:48:42 -0400
In-Reply-To: <3261aa0c-92d0-dfb8-e1ca-7c518d2a02c1@suse.de>
References: <cover.1468051277.git.janani.rvchndrn@gmail.com>
	 <6114f72a15d5e52984ea546ba977737221351636.1468051282.git.janani.rvchndrn@gmail.com>
	 <447d8214-3c3d-cc4a-2eff-a47923fbe45f@suse.cz>
	 <ed4c8fa0-d727-c014-58c5-efe3a191f2ec@suse.de>
	 <010E7991-C436-414A-8F5A-602705E5A47B@gmail.com>
	 <3261aa0c-92d0-dfb8-e1ca-7c518d2a02c1@suse.de>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-OaRnMUVOw63p3dWlybVb"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Jones <tonyj@suse.de>, Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com


--=-OaRnMUVOw63p3dWlybVb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-07-13 at 12:12 -0700, Tony Jones wrote:
> On 07/12/2016 11:16 PM, Janani Ravichandran wrote:
> >=20
> > >=20
> > > I also have a patch which adds a similar latency script (python)
> > > but interfaces it into the perf script setup.
> > I=E2=80=99m looking for pointers for writing latency scripts using
> > tracepoints as I=E2=80=99m new to it. Can I have a look at yours, pleas=
e?
> I was going to send it to you (off list email) last night but I seem
> to have misplaced the latest version.=C2=A0=C2=A0I think it's on a diff t=
est
> system.=C2=A0=C2=A0I'll fire it off to you when I find it, hopefully in t=
he
> next couple of days. I can also post it here if there is any
> interest.=C2=A0=C2=A0I'd like to see it added to the builtin scripts unde=
r
> tools/perf.

That is what Janani has been working on
as part of her Outreachy internship.

However, tools like this very much seem
to be subject to the 80/20 rule, and I
would expect that regardless of whether
Janani chooses to continue with her own
script, or continue working on yours,
there will be more than enough work left
to fill the remainder of the internship
period.

For one, chances are many of the things
inside vmscan.c (and compaction.c!) that
need to be instrumented currently are not.

Secondly, the tool will also need some
documentation.

Tony, Janani should be able to work on this
project full time for another month and a half
or so. This could be a good opportunity to get
something (1) upstream, and (2) refined, and
(3) documented :)

--=20
All rights reversed

--=-OaRnMUVOw63p3dWlybVb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXhpsbAAoJEM553pKExN6DqAoH/RzCXYEqPH2p4vy0XA7ig/lF
gArQbUF8zxTzAsvbpYC5qHmAvjbfzIz+nbhGr4pKOdCh/9q4R67a6pOziDhHHSyQ
OLWMrAW/eoCcKWgl7nTFMShzGBFKhNetqDm7xypPGivTrOoXhw34T6NAI3piEImd
+egppXXz5hsqYIn+R3Yd4GfHDySUIdYf9ritoPHxkymM+5vE5tLIeroyjmiCgr6o
elLtJMgcV8ppTL2dB/eWHZTIa2u5nTNBJ3kTEBtwF5NJ/zRAftUcay1jQccuqkeb
IgCzNpC/VkPKDItSlDrSFzMoGoD6dajWILD0s7iaygOOpvNiB7YqPnB4kVAhnDE=
=gfZ4
-----END PGP SIGNATURE-----

--=-OaRnMUVOw63p3dWlybVb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
