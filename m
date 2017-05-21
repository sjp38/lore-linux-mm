Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B61C280850
	for <linux-mm@kvack.org>; Sun, 21 May 2017 06:27:53 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w79so19191801wme.7
        for <linux-mm@kvack.org>; Sun, 21 May 2017 03:27:53 -0700 (PDT)
Received: from pokefinder.org (sauhun.de. [88.99.104.3])
        by mx.google.com with ESMTP id 67si16669037wmx.159.2017.05.21.03.27.51
        for <linux-mm@kvack.org>;
        Sun, 21 May 2017 03:27:51 -0700 (PDT)
Date: Sun, 21 May 2017 12:27:51 +0200
From: Wolfram Sang <wsa@the-dreams.de>
Subject: Re: Using best practices for big software change possibilities
Message-ID: <20170521102750.ljgvdw2btuks3tqf@ninjato>
References: <05101843-91f6-3243-18ea-acac8e8ef6af@users.sourceforge.net>
 <bae25b04-2ce2-7137-a71c-50d7b4f06431@users.sourceforge.net>
 <20170521084734.GB1456@katana>
 <7bd4b458-6f6e-416b-97a9-b1b3d0840144@users.sourceforge.net>
 <20170521095654.bzpaa2obfszrajgb@ninjato>
 <82cfcf3e-0089-0629-f10c-e01346487f6a@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="gdo5cy4eznavnyzl"
Content-Disposition: inline
In-Reply-To: <82cfcf3e-0089-0629-f10c-e01346487f6a@users.sourceforge.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Cc: linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org


--gdo5cy4eznavnyzl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


> How do you think about to resolve them by additional means besides mail exchange?

That can work. E.g. meeting at conferences often solved mail
communication problems.

For now, I still wonder why you were unsure about grouping the changes
into one patch? Maybe there is something to be learned?


--gdo5cy4eznavnyzl
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEOZGx6rniZ1Gk92RdFA3kzBSgKbYFAlkha6MACgkQFA3kzBSg
KbavhxAAoa+9yWnANH/b4A1ZvuQ5RJbV/BqCPK0eiJwnEgqcsYGPSlCwUOOtBv2J
m7+5/8/eTNbZCk8WQGl4vBv1e/naI1nYUAASz1Rkqx6RzHe1AuwXU6ZhMQYZRknJ
4iraJyl2ztnlx9kvSSsyiILamiu990GKVbcJVseer56vTO/XiEgg9RwSZLHN5XeU
sZzw0qnR3+vBszNiNu3OnXLjVVp1cKDoo5oGBoGuF08om30TZvAGYzW5RpmB5hcB
NqRwMX5i+kJxCj9rO7j7Flz8gH9L+/p54JDxd+7uUv6sIaEucdsNOUxDj41JIip7
zE+9WDCTTEm9YGKQoWahWc088pU/VwjsBl1KbMgvAMs54ILc8GEGcYXuJ6Vux0lJ
XgXzA5HLxTP29S7sosav+hqNA+hRY84Fg2GGecjKuk+IicpEgRLc3eNfIfe8LGWf
nJ56FpKG6X+cYMAz5FhsOoJN7CuTp+2XNn5kL3tKSbBzVT9TQSnMMFOmXSGTgQmO
uAFgTSUUA1CHEX97VjI02TXG4NcTaEx0Sa13vDiGLTjfjxr1WPT3cDg0U6M7M/3X
gc+lZfxLbvFABWNSzfvUHp8C7mOqh6nPnaG24M0TkM3Q5e70ZdrWP+MXQo+/R9SN
GtIMhSh5yPAjOdwK7NwxgvItvY0rqFaY5YRXYyRtDb6AiDXUynU=
=+rC+
-----END PGP SIGNATURE-----

--gdo5cy4eznavnyzl--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
