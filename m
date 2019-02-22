Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 564B8C00319
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 01:48:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5B4F2075C
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 01:48:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5B4F2075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 07E3D8E00E3; Thu, 21 Feb 2019 20:48:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 005658E00E2; Thu, 21 Feb 2019 20:48:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E102A8E00E3; Thu, 21 Feb 2019 20:48:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id B75668E00E2
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 20:48:33 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id a11so403207qkk.10
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 17:48:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version:sender;
        bh=2HMe5xiYjgmWjPJb9YGEqw/4r4GxsPdfIyzrYJmVWZ0=;
        b=fKT0NCUFfdzf4RxJ7ML33fJWWmuvY0PZYJIeRJIjKPXmMAjm3Cv4/QQH6k8ykScar4
         j6DWwqZhgcEMnWncGkoFIqEk8nhKzyOheGQEZBw4/Iiqp3tKQpkgZLv5VMfywTw9QypW
         LiP0OR0pioCQf6C9XIiqY3zT1d5JfuV2QhVTDSJOAPTkYBFA0BH2OuHV70plfHy38FbD
         9UTRzZANT/onTgIYJRxnPmcZKu7geEdP/uMtkX3LvsAKVKa31zh1r3xmJPG5kDvei3fv
         BhwfIyR+pzPgOaBgHycxaViXBEn3DRXCv1x4c3zzwHkTmRL/fvwLdBi/aZxLCs1H2qeU
         NiGg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: AHQUAubmdzldD2v4mT0Mri8BWWp2XIXGN604DOo6C5xCDGU+TIoAAEVm
	aX3mtoq0J+ijF8eiyeEvGd9RsZ6rWrqMBNY/rLTVrVtCXy9dThn5qVyEAgNuZn2vYwcyo14qCq2
	5zYyG2ewIyQdcN3fECQ/UqQgLQUsKCNPRB/1OJmHXm5BkiqABgXplBglrIzdNq7MJKA==
X-Received: by 2002:a37:98c6:: with SMTP id a189mr1163294qke.31.1550800113493;
        Thu, 21 Feb 2019 17:48:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibc0JRKUtxlyuoRD8ha1Scrr4mQz3Y8/yhMFc942BMssYVQbKy3RAQ2i4ZHU9QG7n3uRh62
X-Received: by 2002:a37:98c6:: with SMTP id a189mr1163277qke.31.1550800112809;
        Thu, 21 Feb 2019 17:48:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550800112; cv=none;
        d=google.com; s=arc-20160816;
        b=fvgbrm58Zp7OXqxYzPx8ts2WcwGWeCQZqraPZ4u5vhsbq20bQAeplI/a4VQmFEh3Ve
         59rl1wBHGMit9XYQKljZbZj+i2g4WbwCR3RQiFa28Oe+tPNqTtIUPvmdbqiEDV0zkYxX
         SDcrm6Jkoi993QGLj1fq3bQADHn2Aj9rXamRnD10hZe5i/s6ODv07qNQdnkUZmFx4B5E
         QXPW7ezyW4oGrCUX5aacYJZEpsx/tuIk7PaoIS7lL2xpBaGFgrJ6C3zn1zFUYqD7tfWQ
         IIzuvL87wG/Fh0pbEss5P8JK5ELZw2Edeufq0udLdCPfnY7VuSrd7EzccnbWSjZhzz+W
         V+uA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:references:in-reply-to:date:cc:to:from:subject
         :message-id;
        bh=2HMe5xiYjgmWjPJb9YGEqw/4r4GxsPdfIyzrYJmVWZ0=;
        b=xX9gwBP+euXSo/w8TzJKCx5UhfzQkXvaJGhVJN4oydhX2TN37udt9n1V9ppSouNsue
         O6Jl8dbWaiJfDhLCfKSPdnjDyjS2OLx8r/bGG+f+1dd96zt5YQrlKFXAmhs1+4fLg1E4
         HbGkOV28ZI15wlg/ie4RzZpkxKFY21jezCuHz6RyZvYuIXZBCWb/SkSyfakovG/GzC8R
         wESr8hZUrcdUEv4GymlI7ZSX1zBXVM+EzcfTl6Ps+g4AIXWLC5Teoq0BiwGanDPMrhHt
         OHgM+fA8grTlPSUmXjBrXHf3Lm75SbCKRupA+g4gtcFztPxjW5TxqskUEEU6ptwxgJuW
         pCFg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id v37si52800qvf.218.2019.02.21.17.48.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 17:48:32 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.91)
	(envelope-from <riel@shelob.surriel.com>)
	id 1gwzwy-0005YH-6m; Thu, 21 Feb 2019 20:48:28 -0500
Message-ID: <2d4e6dd7a546640c9ecb6a60b730d6c3a3da980b.camel@surriel.com>
Subject: Re: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
From: Rik van Riel <riel@surriel.com>
To: Roman Gushchin <guro@fb.com>, Dave Chinner <david@fromorbit.com>
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
  "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,  "dchinner@redhat.com"
 <dchinner@redhat.com>, "guroan@gmail.com" <guroan@gmail.com>, Kernel Team
 <Kernel-team@fb.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>
Date: Thu, 21 Feb 2019 20:48:27 -0500
In-Reply-To: <20190221224616.GB24252@tower.DHCP.thefacebook.com>
References: <20190219071329.GA7827@castle.DHCP.thefacebook.com>
	 <20190220024723.GA20682@dastard> <20190220055031.GA23020@dastard>
	 <20190220072707.GB23020@dastard>
	 <20190221224616.GB24252@tower.DHCP.thefacebook.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-lgNl1vNCER8PgHS4HqER"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-lgNl1vNCER8PgHS4HqER
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2019-02-21 at 17:46 -0500, Roman Gushchin wrote:
> On Wed, Feb 20, 2019 at 06:27:07PM +1100, Dave Chinner wrote:
> > On Wed, Feb 20, 2019 at 04:50:31PM +1100, Dave Chinner wrote:
> > > I'm just going to fix the original regression in the shrinker
> > > algorithm by restoring the gradual accumulation behaviour, and
> > > this
> > > whole series of problems can be put to bed.
> >=20
> > Something like this lightly smoke tested patch below. It may be
> > slightly more agressive than the original code for really small
> > freeable values (i.e. < 100) but otherwise should be roughly
> > equivalent to historic accumulation behaviour.
> >=20
> > Cheers,
> >=20
> > Dave.
> > --=20
> > Dave Chinner
> > david@fromorbit.com
> >=20
> > mm: fix shrinker scan accumulation regression
> >=20
> > From: Dave Chinner <dchinner@redhat.com>
>=20
> JFYI: I'm testing this patch in our environment for fixing
> the memcg memory leak.
>=20
> It will take a couple of days to get reliable results.

Just to clarify, is this test with fls instead of ilog2,
so the last item in a slab cache can get reclaimed as
well?

--=20
All Rights Reversed.

--=-lgNl1vNCER8PgHS4HqER
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAlxvVOsACgkQznnekoTE
3oOfBQf/ZOlT9BiynvY+97b0klsAkgxIn6y8HLGrY/NPn+M456BBbr6XT6p4I1YH
wfpwJ0yg7rGR53tzhUD4b0gkQ5QVMuoJf8rkNMxtYLKFB3k2kK9Q9ZNBvqTZFXYt
/rjEc48Df+qMPWlnBZOmYttyh/YgzR7QKKrGjR2fENzf1akiTO0vZMKcahGLSsYK
gk/NMYee+vrL6+hpgM2BwpjIulnSa+y2qmzL9ndJS71Fl3A+6HG5bBy2eBikOGBP
a0guVyi6+tqaxnNN0BKs50NLYllwzNdeiNo/jlNNrO+5lNphG+OqI3cXTIzpy1fG
1qL+DgNy5rLZq3B/+QY+tUnPNqr9ig==
=9IbL
-----END PGP SIGNATURE-----

--=-lgNl1vNCER8PgHS4HqER--

