Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 795D86B0388
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 09:39:32 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v66so14994924wrc.4
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 06:39:32 -0800 (PST)
Received: from mail.free-electrons.com (mail.free-electrons.com. [62.4.15.54])
        by mx.google.com with ESMTP id 91si19428995wri.305.2017.02.27.06.39.31
        for <linux-mm@kvack.org>;
        Mon, 27 Feb 2017 06:39:31 -0800 (PST)
Date: Mon, 27 Feb 2017 15:39:30 +0100
From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH 2/8] dt-bindings: gpu: mali: Add optional memory-region
Message-ID: <20170227143930.dfi32lmshmhkwxnm@lukather>
References: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
 <49fd36f667c5ae46b0724c8204eabc51014aab92.1486655917.git-series.maxime.ripard@free-electrons.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="nhqrksdjcvhubqhp"
Content-Disposition: inline
In-Reply-To: <49fd36f667c5ae46b0724c8204eabc51014aab92.1486655917.git-series.maxime.ripard@free-electrons.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Chen-Yu Tsai <wens@csie.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: dri-devel@lists.freedesktop.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>


--nhqrksdjcvhubqhp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Feb 09, 2017 at 05:39:16PM +0100, Maxime Ripard wrote:
> The reserved memory bindings allow us to specify which memory areas our
> buffers can be allocated from.
>=20
> Let's use it.
>=20
> Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>

Applied with Rob Acked-by.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--nhqrksdjcvhubqhp
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYtDoiAAoJEBx+YmzsjxAgUR4QAKsTKYNjlNbB7uiDM7d6lKiC
Aj0+B+EzyOKHJbK5FodQpp6Bi8oHO89iSf0ppgk7wKYQDjnfic4Sul4EsTjYO9S5
gpRhppXAHmvkzjy14D6ZldzrVGPLQDHT50MJtFiF0lowCytKyuc9FDABxDYXDXxz
o9ERk0icSwjZEYoVlxlEMvFLgMJf7Pntk7vhBpIcsEvzC9CoXrKmKKgkdai+U/u5
zyyg46nOz/VlAfgm1vzvNEGmGGG5L6fyCF6u3yljveRfe/h1f9n6M8CSSAs85Aue
cNhBUVTErxAPt9yuUuMefjMvk9dtCE8sHkSAQ6jHBxZe12mapC7/PF93GsEu2LHY
01rOT4efoHyLlmC8CuFTejt0aADkqyzmuIFVb9y2NwUzKa5Pk3AKOHAf4H10PMgH
w9w4bu+BsUV5/iyNxR+xNBYrAnGhD2wrGgjnjxetnNQi00wcmKVzwOJsaTL1I1be
0RqucVRkJGBd3B+Bzb1zn125G0jiV093HP2/sA1RlkeGQaDC+QJZNTOSSNJhCTms
wlQnHpWB9q/y5Afd3iap7+pYh5fyA2dtZeq6c3p66jD8N0zT6XOsppOcgGY/NaVS
5vYMWpDJ8bvfjHm51lQ6OZp+N2NkuevJ0IUyxNPPcJimsxtEKwPTfy5rz6xCjGH/
uXtQlNC9u7D+QPPfdDYm
=3XNT
-----END PGP SIGNATURE-----

--nhqrksdjcvhubqhp--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
