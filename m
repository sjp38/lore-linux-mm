Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50E8FC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:35:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 161C92171F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:35:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 161C92171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bootlin.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6DF38E0003; Thu, 28 Feb 2019 04:35:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1D0A8E0001; Thu, 28 Feb 2019 04:35:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9357C8E0003; Thu, 28 Feb 2019 04:35:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 380878E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:35:20 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id a9so8335345edy.13
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 01:35:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zn5MqnjKRsOAbjHjWWqZaAK5dv4TbNFPTTyLcFe5lZQ=;
        b=Pjq5e3nJMT8QrsJ48/0tdfcMzTPW6SQRhG5k6Q8fSWGVfVzFomHJOrbKxfwzR/bV9p
         wo7c/DkBIWacTRzMGcgCbT0LJFcgYQyinavCgnXECmgjgS1EOFzbDf2q61Shfii1Q99f
         F4V/oXqAsk/vofgp4q1bHLxgqflNznemDPg0jZnvM22nQ1ETmqjeNxRb3gsqqAyZQmXN
         Ek+TDOEI6SD/Yvh+tCjW/DjEp7kGddYqYJhawAUbb9WJrq2cAUBIxLlYmDxKQEZm4xDy
         9DBcatQ5v4E9PC1GL4tZ27aUiuVLPoisWD+zbCWkPi7SiQVvLj8dNY7J0QalE1ToaC0f
         2ztg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of maxime.ripard@bootlin.com designates 217.70.183.199 as permitted sender) smtp.mailfrom=maxime.ripard@bootlin.com
X-Gm-Message-State: AHQUAuZCUnKnk/al2bimh5OB5/51Psj3iMP+elwGcxkFs8E3ZiH8EaK/
	lZNh146EY8BWMtvKixt1SoL3ZDFLfiGl8nJncBjkaxQGo9dYnCBl+v0Oj8S2wWVHemSN74X9l0u
	oztlCZADr2ETfNanp/UjRYSf0cWh41ClKibsK5Qau4VxA8j+RlJrR/TrV1L+cI7tLZg==
X-Received: by 2002:a50:97f8:: with SMTP id f53mr6055016edb.22.1551346519761;
        Thu, 28 Feb 2019 01:35:19 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYJUJ8ktkvi7lw0W2/zb25YzU7jLw88umKRiNHTq6m9mcLg3FAwUmvEpMtR8ebVuGeMXNcJ
X-Received: by 2002:a50:97f8:: with SMTP id f53mr6054956edb.22.1551346518742;
        Thu, 28 Feb 2019 01:35:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551346518; cv=none;
        d=google.com; s=arc-20160816;
        b=b9/4QcPX8FctV7CJ0zXAJo2Rr15xT8EEIocFnXWGPR9uhXVmOsQjweUyYAcmBTvysG
         rUdgUPoqz4amVX4GNljVEADKDUWg2v+HYE6xBKUjyocLzAfa3dc3ZSk4OKvgbZswVjos
         tLGcYhflayk918VQC7P4CkDnfpXDmqILd22Oigkk+qt4NJOoBNkmCO317qfvgXSrr9CP
         UMKXYznUGsMrwGTB3Oa8ynJSuKg5W6LoFQ03TZL8/mendtWpKQKDC+ufrsZbCwQa/sYh
         XSYbL6M+LIm41c0zI3ldxB8neM4EGLMfXpnv7A0VlVzsZqe62Les0tZyl5UvrXAnIAom
         R8rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zn5MqnjKRsOAbjHjWWqZaAK5dv4TbNFPTTyLcFe5lZQ=;
        b=ckG/ImfGIEj420FlDlgkVaF6GoGuNvanCViIrq+Fwcol4IKiNZjdBfAWjudl77l9VU
         Nq0fct0BXCzBzZPXqd63mG9hmU9OwGL+flxeKkMMJqdzy4qppB6p9rbEMaqj6nGgFpCv
         Y3SE9EYCLaogDEoEN9hqjhfBUOa+nH1KNwv0Qql1YnlhZFozt2vOD4omH66gEkbvZFIc
         qpPFK/04WaiFRXI4lJIkW84830kDIxOzMcPh3IbnmzWNi9J/piZY6cbzb1SET5MLYhbF
         AQxVMUq5pIyCykvAuZWXs+yiZ+0MCUsNYTm2fRVGZPnT/uKeuxs+r3k1qJQ071qY9X2l
         aUsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of maxime.ripard@bootlin.com designates 217.70.183.199 as permitted sender) smtp.mailfrom=maxime.ripard@bootlin.com
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id m43si6808220edd.6.2019.02.28.01.35.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Feb 2019 01:35:18 -0800 (PST)
Received-SPF: pass (google.com: domain of maxime.ripard@bootlin.com designates 217.70.183.199 as permitted sender) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of maxime.ripard@bootlin.com designates 217.70.183.199 as permitted sender) smtp.mailfrom=maxime.ripard@bootlin.com
X-Originating-IP: 90.88.147.150
Received: from localhost (aaubervilliers-681-1-27-150.w90-88.abo.wanadoo.fr [90.88.147.150])
	(Authenticated sender: maxime.ripard@bootlin.com)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id E43B7FF810;
	Thu, 28 Feb 2019 09:35:16 +0000 (UTC)
Date: Thu, 28 Feb 2019 10:35:16 +0100
From: Maxime Ripard <maxime.ripard@bootlin.com>
To: Gerhard Wiesinger <lists@wiesinger.com>
Cc: arm@lists.fedoraproject.org, Chen-Yu Tsai <wens@csie.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	Florian Fainelli <f.fainelli@gmail.com>, filbar@centrum.cz
Subject: Re: Banana Pi-R1 stabil
Message-ID: <20190228093516.abual3564dkvx6un@flea>
References: <7b20af72-76ea-a7b1-9939-ca378dc0ed83@wiesinger.com>
 <20190227092023.nvr34byfjranujfm@flea>
 <5f63a2c6-abcb-736f-d382-18e8cea31b65@wiesinger.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="y46btgmwon2ggfsd"
Content-Disposition: inline
In-Reply-To: <5f63a2c6-abcb-736f-d382-18e8cea31b65@wiesinger.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--y46btgmwon2ggfsd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Feb 27, 2019 at 07:58:14PM +0100, Gerhard Wiesinger wrote:
> On 27.02.2019 10:20, Maxime Ripard wrote:
> > On Sun, Feb 24, 2019 at 09:04:57AM +0100, Gerhard Wiesinger wrote:
> > > Hello,
> > >=20
> > > I've 3 Banana Pi R1, one running with self compiled kernel
> > > 4.7.4-200.BPiR1.fc24.armv7hl and old Fedora 25 which is VERY STABLE, =
the 2
> > > others are running with Fedora 29 latest, kernel 4.20.10-200.fc29.arm=
v7hl. I
> > > tried a lot of kernels between of around 4.11
> > > (kernel-4.11.10-200.fc25.armv7hl) until 4.20.10 but all had crashes w=
ithout
> > > any output on the serial console or kernel panics after a short time =
of
> > > period (minutes, hours, max. days)
> > >=20
> > > Latest known working and stable self compiled kernel: kernel
> > > 4.7.4-200.BPiR1.fc24.armv7hl:
> > >=20
> > > https://www.wiesinger.com/opensource/fedora/kernel/BananaPi-R1/
> > >=20
> > > With 4.8.x the DSA b53 switch infrastructure has been introduced which
> > > didn't work (until ca8931948344c485569b04821d1f6bcebccd376b and kernel
> > > 4.18.x):
> > >=20
> > > https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree=
/drivers/net/dsa/b53?h=3Dv4.20.12
> > >=20
> > > https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/log/=
drivers/net/dsa/b53?h=3Dv4.20.12
> > >=20
> > > https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/comm=
it/drivers/net/dsa/b53?h=3Dv4.20.12&id=3Dca8931948344c485569b04821d1f6bcebc=
cd376b
> > >=20
> > > I has been fixed with kernel 4.18.x:
> > >=20
> > > https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/log/=
drivers/net/dsa/b53?h=3Dlinux-4.18.y
> > >=20
> > >=20
> > > So current status is, that kernel crashes regularly, see some samples=
 below.
> > > It is typically a "Unable to handle kernel paging request at virtual =
addres"
> > >=20
> > > Another interesting thing: A Banana Pro works well (which has also an
> > > Allwinner A20 in the same revision) running same Fedora 29 and latest
> > > kernels (e.g. kernel 4.20.10-200.fc29.armv7hl.).
> > >=20
> > > Since it happens on 2 different devices and with different power supp=
lies
> > > (all with enough power) and also the same type which works well on the
> > > working old kernel) a hardware issue is very unlikely.
> > >=20
> > > I guess it has something to do with virtual memory.
> > >=20
> > > Any ideas?
> > > [47322.960193] Unable to handle kernel paging request at virtual addr=
es 5675d0
> > That line is a bit suspicious
> >=20
> > Anyway, cpufreq is known to cause those kind of errors when the
> > voltage / frequency association is not correct.
> >=20
> > Given the stack trace and that the BananaPro doesn't have cpufreq
> > enabled, my first guess would be that it's what's happening. Could you
> > try using the performance governor and see if it's more stable?
> >=20
> > If it is, then using this:
> > https://github.com/ssvb/cpuburn-arm/blob/master/cpufreq-ljt-stress-test
> >=20
> > will help you find the offending voltage-frequency couple.
>
> For me it looks like they have all the same config regarding cpu governor
> (Banana Pro, old kernel stable one, new kernel unstable ones)

The Banana Pro doesn't have a regulator set up, so it will only change
the frequency, not the voltage.

> They all have the ondemand governor set:
>=20
> I set on the 2 unstable "new kernel Banana Pi R1":
>=20
> # Set to max performance
> echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
> echo "performance" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor

What are the results?

> Running some stress tests are ok (I did that already in the past, but
> without setting maximum performance governor).

Which stress tests have you been running?

Maxime

--=20
Maxime Ripard, Bootlin
Embedded Linux and Kernel engineering
https://bootlin.com

--y46btgmwon2ggfsd
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYIAB0WIQRcEzekXsqa64kGDp7j7w1vZxhRxQUCXHerVAAKCRDj7w1vZxhR
xRwDAQCGdTiXZQdCkQJEFPhFXYILEbJ90fTxJZTyeqNeGi1PigEA4VqTGGg8x+U1
8jWECOpya2M6Za6558+iRGJQTIVx8wA=
=cnxS
-----END PGP SIGNATURE-----

--y46btgmwon2ggfsd--

