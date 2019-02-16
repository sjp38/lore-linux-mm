Return-Path: <SRS0=AfK9=QX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D55DEC43381
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 06:22:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63DE5222D0
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 06:22:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="Iqifbe5I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63DE5222D0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB6F68E0002; Sat, 16 Feb 2019 01:22:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B66A98E0001; Sat, 16 Feb 2019 01:22:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A55858E0002; Sat, 16 Feb 2019 01:22:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 63A8A8E0001
	for <linux-mm@kvack.org>; Sat, 16 Feb 2019 01:22:13 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id o23so8479288pll.0
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 22:22:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=c78WhjlV93GYebRcDqCmZjrGCS9S35SnTwBG8M1GZfU=;
        b=BIRCOilk7l39I3CWvhfw7We3+ze4vikWezdGjmN6dJu81efg8/A8UcA/BnUlXZ5oMS
         dfJqG3pB1p/ceDidWeY4halEWo0LNxhhBRT6U9sXqSGSVE+3RBMccrLUcJRbwtgHu6Wr
         AqEAoIrcCTNB6Fsy4aQdxWV9Dgad8EKZYWP2b+DPgYXJQjaXYKVFPlpS6hrHR+3fJh7G
         Gf6gQDEXJhkOe6aaXOkeXPjXqWr2KVtiM/5XxlYLbngTtFKp000QwSnRYSkWZQs6cv/X
         lvc133UlzV9kR3SWg+T9l55WucIaZwRd7L8FhGHDKmh5eojOgFGXwnSVs57HLPb/JsQE
         iiNw==
X-Gm-Message-State: AHQUAuZb8BSNGAih9uyaS36nqoUei0Fa0+Ai8h5xkQAeS29AuO8uZepg
	9I/4zCQF3j4DkZOADdl7IZkqLiEir8Af3HFHtcAOCVrlI07jPIjBwMoqpV25C78DWOyegVB33Vm
	M5V8UydD1X0rEzp/YY/B1b0m+24F4+Yd01LfMK7kWYcQBAPILfaCUqX0ThK8JOeC+ow==
X-Received: by 2002:a63:5964:: with SMTP id j36mr8866220pgm.210.1550298132904;
        Fri, 15 Feb 2019 22:22:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZYGCMBBFP9vfAu7Y6UrABq9fZy9w9E6uhc2GHBZJj1jZpsLGkeDjk/Ne+VXZVGuNabvN7H
X-Received: by 2002:a63:5964:: with SMTP id j36mr8866192pgm.210.1550298132207;
        Fri, 15 Feb 2019 22:22:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550298132; cv=none;
        d=google.com; s=arc-20160816;
        b=Vc9nxCCpY6ps5aP0tX1CMkUMHr11K7aexh9ksSOAtIlVmd4qX9/MNgVR7bgDw6c3vw
         ANRmQsQyllNDLjgXqAd1EnAPTH1wuwpnz1aLiVz0J2UkurRaCKjyZuhsfHIs6Pq8d5Lm
         anSr+7VtGJUPLsgtEdYTuqu5i2U3hJFkG0w27kvt+CbE+BcF0AVQSKbHkMBHfmvmgPlg
         x4NhaNEo1DeCliu12e7uCsD3Wpnm3NkxY7Mdc8owqKpNIS8N1gNrQ3iGtIN1h3vAyawD
         oJfkuKYwkgTLr1Mse9MudDlCcY/jOE5C/e9DOwHquoD1h00ISApBPof2frbf/2sKZzWu
         LkMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=c78WhjlV93GYebRcDqCmZjrGCS9S35SnTwBG8M1GZfU=;
        b=ntGyWZp36IvFZpkTlA4CgsmnT/VY2/B40UsIF9hnNNEnVl0QeINzSZEnmg9tR0KAu9
         /wsC86LOolOh0DW6J3e29Cb62RFPCHPt3QcgWPd5p0Yl2y+GVRp7LmZFqpna5zIxrHe0
         nMXWWepNsTQBK/JdFudd0LacvQaIluR8str+o2NuVpeMZeJjfSUHZ7eAKuWL2mS0GtOt
         KMJSrJG/ZWB7gfTn54PWU5ZK8nwqUgXsv+vzxNNFY2deAkoeyWBFw7846NBa9KOdaSvT
         d2YNK6wHnk9kOzsKcPIgRIaFvl44I5UWxMt1Cjl7VfZTLYB0E/GxYY6VIb+HpiQcBBuV
         j4bA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=Iqifbe5I;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id r1si7130536pfb.118.2019.02.15.22.22.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Feb 2019 22:22:12 -0800 (PST)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=Iqifbe5I;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 441g5Q74V4z9s7T;
	Sat, 16 Feb 2019 17:22:02 +1100 (AEDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1550298129;
	bh=iHpNKem2HNQGfNgnRALLLbllqNJ3AW/b2p/hv8V8fQE=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=Iqifbe5I0imB2U5W+MMz/HO5RFNMV2Qp7RBqR6L4ZFuv0hbRwtsHKm+nH8/M06N5z
	 6LuWTAeL8HN91eAQGLiQpTgO9sTN5boyURoLhMd1ySr83QVYoTClCIZFFt6fZb7RJT
	 DDvbSsHJKv4Ylfe+HurjfzlkmKtTVh7KKfT3lU4HoR6mc7C2S439MQdLy5wM2qVavp
	 Gle16O+yA+H21i0+zLa5HRogtYzLs3QIOroDrexRwxOIGULyOKeSbsbK11I7kd/tDE
	 3mrqZkeZOb9xYztszSTPwAVW2YHOGq87iukx/snkPjfaVqeXpHK4OLhzHkZRsUrXIa
	 rRHXVMEIhSepg==
Date: Sat, 16 Feb 2019 17:21:57 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mark Brown <broonie@kernel.org>, "kernelci.org bot" <bot@kernelci.org>,
 tomeu.vizoso@collabora.com, guillaume.tucker@collabora.com, Dan Williams
 <dan.j.williams@intel.com>, matthew.hart@linaro.org, khilman@baylibre.com,
 enric.balletbo@collabora.com, Nicholas Piggin <npiggin@gmail.com>, Dominik
 Brodowski <linux@dominikbrodowski.net>, Masahiro Yamada
 <yamada.masahiro@socionext.com>, Kees Cook <keescook@chromium.org>, Adrian
 Reber <adrian@lisas.de>, linux-kernel@vger.kernel.org, Johannes Weiner
 <hannes@cmpxchg.org>, linux-mm@kvack.org, Mathieu Desnoyers
 <mathieu.desnoyers@efficios.com>, Michal Hocko <mhocko@suse.com>, Richard
 Guy Briggs <rgb@redhat.com>, "Peter Zijlstra (Intel)"
 <peterz@infradead.org>
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
Message-ID: <20190216172157.77f0883c@canb.auug.org.au>
In-Reply-To: <20190215110024.011197d86e3ab8642a9bbecf@linux-foundation.org>
References: <5c6702da.1c69fb81.12a14.4ece@mx.google.com>
	<20190215104325.039dbbd9c3bfb35b95f9247b@linux-foundation.org>
	<20190215185151.GG7897@sirena.org.uk>
	<20190215110024.011197d86e3ab8642a9bbecf@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/2N.6XtaAhi3SXj.PGoC+_32"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/2N.6XtaAhi3SXj.PGoC+_32
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Fri, 15 Feb 2019 11:00:24 -0800 Andrew Morton <akpm@linux-foundation.org=
> wrote:
>
> On Fri, 15 Feb 2019 18:51:51 +0000 Mark Brown <broonie@kernel.org> wrote:
>=20
> > On Fri, Feb 15, 2019 at 10:43:25AM -0800, Andrew Morton wrote: =20
> > > On Fri, 15 Feb 2019 10:20:10 -0800 (PST) "kernelci.org bot" <bot@kern=
elci.org> wrote: =20
> >  =20
> > > >   Details:    https://kernelci.org/boot/id/5c666ea959b514b017fe6017
> > > >   Plain log:  https://storage.kernelci.org//next/master/next-201902=
15/arm/multi_v7_defconfig+CONFIG_SMP=3Dn/gcc-7/lab-collabora/boot-am335x-bo=
neblack.txt
> > > >   HTML log:   https://storage.kernelci.org//next/master/next-201902=
15/arm/multi_v7_defconfig+CONFIG_SMP=3Dn/gcc-7/lab-collabora/boot-am335x-bo=
neblack.html =20
> >  =20
> > > Thanks. =20
> >  =20
> > > But what actually went wrong?  Kernel doesn't boot? =20
> >=20
> > The linked logs show the kernel dying early in boot before the console
> > comes up so yeah.  There should be kernel output at the bottom of the
> > logs. =20
>=20
> OK, thanks.
>=20
> Well, we have a result.  Stephen, can we please drop
> mm-shuffle-default-enable-all-shuffling.patch for now?

Dropped.

--=20
Cheers,
Stephen Rothwell

--Sig_/2N.6XtaAhi3SXj.PGoC+_32
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlxnrAUACgkQAVBC80lX
0Gy7pAf/ajVfxnCsd6WEXykRPKeQW0zW2HCw9jXiyMYLK9YsKiR35PMkr3Bq7i+p
wFr+eG5Ktc93thjmc6bWE2x+LN1wOIeoeTOAJkbg3rRY7WJW8Ns3TkBxVAFP6sLF
MUZjeG+W7UDtzqu82nJX0bT7Tcil/drbjB+kNpY+qxOgy5SzKcKVh1lBcC2vGzs3
prrhsTUssLHAqcI5gGHQO3eIQG1UuEmKpxJj31vtZpJvOPejlm4vIW+IMGUEkd2x
XlGY+AjiLgdMh68d8IA4kwoNDQVtBWCdiwuCvH/hoqGsrERiqJyACmIckgSEr4PD
pdtHOS3bbduTQvtxTetk16P1drHNqw==
=l+na
-----END PGP SIGNATURE-----

--Sig_/2N.6XtaAhi3SXj.PGoC+_32--

