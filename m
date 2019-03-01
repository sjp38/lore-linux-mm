Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E3AFC43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 09:30:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C3FA2087E
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 09:30:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C3FA2087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bootlin.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACBAB8E0003; Fri,  1 Mar 2019 04:30:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A54298E0001; Fri,  1 Mar 2019 04:30:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 942F08E0003; Fri,  1 Mar 2019 04:30:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 382D38E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 04:30:43 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o9so9779436edh.10
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 01:30:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3NAyiJBj26Ut4ep/deVBaiBBBnUGn2ze3A9Q4mxkqjs=;
        b=NWMVCG8JwXo8R/MsNRNuqqia1Ip6fxw5wNT9yCL9hiai6zpCuduq9vxaD/Lf4FgeA3
         rGDUKAHBFpEKe12phzBRYSR7chRti4jagdpUmU54YUt3TGFmhPXaV9iAHga3DWW+OCES
         avvl0WieLKr3EkVnkA96fotcstIRpQs6Omzxz/n0HMU+Jlo6shwspSSQL4fJi7g7MvPx
         FPAXZY0WLMU/yYiS4pLWkVLF8qPraG8pAY70l97sBG5DvhZOCQ1o3GGq+DQtcOUXquD5
         spV31I2qwftsKZsKvyZ0DdEXghRYnqOtBTTMefhDzkIK4mTBD9lLD/08OXAhE5i48TX5
         lVvg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of maxime.ripard@bootlin.com designates 217.70.183.194 as permitted sender) smtp.mailfrom=maxime.ripard@bootlin.com
X-Gm-Message-State: APjAAAWRz2mqxTNB6OIyLtG9Ak5x0vKugNdRzs1T2XZtfEfdsgrEsZUw
	XmHunfRmqBJh3X3lpuYKG5F9XXWQuBAh1cpy4ke5tPeZwy/uSe6wiMXIGdliqJrLJCKJdNHwciX
	tBcCCrKMwib6/4kWwijpPoJ0fKEbq2l0efTuAnpH8lg7W+2NoGFIXLG9VoqR8q7RCag==
X-Received: by 2002:aa7:d1d0:: with SMTP id g16mr3442634edp.109.1551432642639;
        Fri, 01 Mar 2019 01:30:42 -0800 (PST)
X-Google-Smtp-Source: APXvYqyisrZKUIIm7OMkZWJxSgkd5FRJrwWICygwjHxL4DJLJACfdeiTygtagZqm017R8cLMbKf7
X-Received: by 2002:aa7:d1d0:: with SMTP id g16mr3442565edp.109.1551432641503;
        Fri, 01 Mar 2019 01:30:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551432641; cv=none;
        d=google.com; s=arc-20160816;
        b=pgrfOKAQByxrGNqsxWt9d1lsidQYR0u8tbTJbFOAqrZ+SRmnpXjh41YyfQmHzXui8P
         snCoiJZnnTf3/C/L6B+OauPgQqNUn7tXj6XubCTZVjR432UMusL84sNQniACj3sFgRT5
         i2uUOJjAL9sc3hI6+tNOUmU6yQm4EwkGHWviKWsr1bOY8U0CWeg7PkCho5LR0aR1k6Uk
         Zw1FL0JxKPqHkcyz/iEJwwes88YLeHRjvEurEN0VzJZHcW3sNdHtgKKcoBQaDeT2jjuQ
         2z5I8qcERqbvqmmPQjc052jn8lkJuK0UFo88b+9xfnubfSaoom8WNGwieSRS5m6TWdSF
         Pk+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3NAyiJBj26Ut4ep/deVBaiBBBnUGn2ze3A9Q4mxkqjs=;
        b=vuht61uOwjy+ECo/UdagXQBxds2IHVlORK3Msalst+x7pMG779iWOp/ApITQCj/o4j
         +96fGURYiKJ7DZcTA5KTgjbuEyn9hXKDzDi0PcgXfxLyUgUzV1n6MT+lbZwh1mRTWs3q
         B9W2GJD86XwuhLbPrXhule+7tGUzhViNAVtLwicnoz+PKNivisgdSsCN/4vuLFJ40Tzl
         17rhfWON6H8SXgoRGMvh+AXfvX7qtZzph/UvLtr3uq4aQezHe98d8aYkcodt7krxA1p6
         linl9ylcDnFukZvo3Vdq8HDo+B91ZlP14XLlE/t7XF7CJbSKipF5UOoMfXoZUEN1V+py
         exEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of maxime.ripard@bootlin.com designates 217.70.183.194 as permitted sender) smtp.mailfrom=maxime.ripard@bootlin.com
Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net. [217.70.183.194])
        by mx.google.com with ESMTPS id s14si1874645ejz.38.2019.03.01.01.30.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 01:30:41 -0800 (PST)
Received-SPF: pass (google.com: domain of maxime.ripard@bootlin.com designates 217.70.183.194 as permitted sender) client-ip=217.70.183.194;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of maxime.ripard@bootlin.com designates 217.70.183.194 as permitted sender) smtp.mailfrom=maxime.ripard@bootlin.com
X-Originating-IP: 90.88.147.150
Received: from localhost (aaubervilliers-681-1-27-150.w90-88.abo.wanadoo.fr [90.88.147.150])
	(Authenticated sender: maxime.ripard@bootlin.com)
	by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 979D64001C;
	Fri,  1 Mar 2019 09:30:39 +0000 (UTC)
Date: Fri, 1 Mar 2019 10:30:38 +0100
From: Maxime Ripard <maxime.ripard@bootlin.com>
To: Gerhard Wiesinger <lists@wiesinger.com>
Cc: arm@lists.fedoraproject.org, Chen-Yu Tsai <wens@csie.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	Florian Fainelli <f.fainelli@gmail.com>, filbar@centrum.cz
Subject: Re: Banana Pi-R1 stabil
Message-ID: <20190301093038.oz56z22ivpntdcfw@flea>
References: <7b20af72-76ea-a7b1-9939-ca378dc0ed83@wiesinger.com>
 <20190227092023.nvr34byfjranujfm@flea>
 <5f63a2c6-abcb-736f-d382-18e8cea31b65@wiesinger.com>
 <20190228093516.abual3564dkvx6un@flea>
 <91c22ba4-39eb-dd3d-29bd-1bfa7a45e9cd@wiesinger.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="5dqx3l4hsuk3weiw"
Content-Disposition: inline
In-Reply-To: <91c22ba4-39eb-dd3d-29bd-1bfa7a45e9cd@wiesinger.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--5dqx3l4hsuk3weiw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Feb 28, 2019 at 08:41:53PM +0100, Gerhard Wiesinger wrote:
> On 28.02.2019 10:35, Maxime Ripard wrote:
> > On Wed, Feb 27, 2019 at 07:58:14PM +0100, Gerhard Wiesinger wrote:
> > > On 27.02.2019 10:20, Maxime Ripard wrote:
> > > > On Sun, Feb 24, 2019 at 09:04:57AM +0100, Gerhard Wiesinger wrote:
> > > > > Hello,
> > > > >=20
> > > > > I've 3 Banana Pi R1, one running with self compiled kernel
> > > > > 4.7.4-200.BPiR1.fc24.armv7hl and old Fedora 25 which is VERY STAB=
LE, the 2
> > > > > others are running with Fedora 29 latest, kernel 4.20.10-200.fc29=
=2Earmv7hl. I
> > > > > tried a lot of kernels between of around 4.11
> > > > > (kernel-4.11.10-200.fc25.armv7hl) until 4.20.10 but all had crash=
es without
> > > > > any output on the serial console or kernel panics after a short t=
ime of
> > > > > period (minutes, hours, max. days)
> > > > >=20
> > > > > Latest known working and stable self compiled kernel: kernel
> > > > > 4.7.4-200.BPiR1.fc24.armv7hl:
> > > > >=20
> > > > > https://www.wiesinger.com/opensource/fedora/kernel/BananaPi-R1/
> > > > >=20
> > > > > With 4.8.x the DSA b53 switch infrastructure has been introduced =
which
> > > > > didn't work (until ca8931948344c485569b04821d1f6bcebccd376b and k=
ernel
> > > > > 4.18.x):
> > > > >=20
> > > > > https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/=
tree/drivers/net/dsa/b53?h=3Dv4.20.12
> > > > >=20
> > > > > https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/=
log/drivers/net/dsa/b53?h=3Dv4.20.12
> > > > >=20
> > > > > https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/=
commit/drivers/net/dsa/b53?h=3Dv4.20.12&id=3Dca8931948344c485569b04821d1f6b=
cebccd376b
> > > > >=20
> > > > > I has been fixed with kernel 4.18.x:
> > > > >=20
> > > > > https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/=
log/drivers/net/dsa/b53?h=3Dlinux-4.18.y
> > > > >=20
> > > > >=20
> > > > > So current status is, that kernel crashes regularly, see some sam=
ples below.
> > > > > It is typically a "Unable to handle kernel paging request at virt=
ual addres"
> > > > >=20
> > > > > Another interesting thing: A Banana Pro works well (which has als=
o an
> > > > > Allwinner A20 in the same revision) running same Fedora 29 and la=
test
> > > > > kernels (e.g. kernel 4.20.10-200.fc29.armv7hl.).
> > > > >=20
> > > > > Since it happens on 2 different devices and with different power =
supplies
> > > > > (all with enough power) and also the same type which works well o=
n the
> > > > > working old kernel) a hardware issue is very unlikely.
> > > > >=20
> > > > > I guess it has something to do with virtual memory.
> > > > >=20
> > > > > Any ideas?
> > > > > [47322.960193] Unable to handle kernel paging request at virtual =
addres 5675d0
> > > > That line is a bit suspicious
> > > >=20
> > > > Anyway, cpufreq is known to cause those kind of errors when the
> > > > voltage / frequency association is not correct.
> > > >=20
> > > > Given the stack trace and that the BananaPro doesn't have cpufreq
> > > > enabled, my first guess would be that it's what's happening. Could =
you
> > > > try using the performance governor and see if it's more stable?
> > > >=20
> > > > If it is, then using this:
> > > > https://github.com/ssvb/cpuburn-arm/blob/master/cpufreq-ljt-stress-=
test
> > > >=20
> > > > will help you find the offending voltage-frequency couple.
> > > For me it looks like they have all the same config regarding cpu gove=
rnor
> > > (Banana Pro, old kernel stable one, new kernel unstable ones)
> > The Banana Pro doesn't have a regulator set up, so it will only change
> > the frequency, not the voltage.
> >=20
> > > They all have the ondemand governor set:
> > >=20
> > > I set on the 2 unstable "new kernel Banana Pi R1":
> > >=20
> > > # Set to max performance
> > > echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_gov=
ernor
> > > echo "performance" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_gov=
ernor
> > What are the results?
>=20
> Stable since more than around 1,5 days. Normally they have been crashed f=
or
> such a long uptime. So it looks that the performance governor fixes it.
>=20
> I guess crashes occour because of changing CPU voltage and clock changes =
and
> invalid data (e.g. also invalid RAM contents might be read, register
> problems, etc).
>=20
> Any ideas how to fix it for ondemand mode, too?

Run https://github.com/ssvb/cpuburn-arm/blob/master/cpufreq-ljt-stress-test

> But it doesn't explaing that it works with kernel 4.7.4 without any
> problems.

My best guess would be that cpufreq wasn't enabled at that time, or
without voltage scaling.

Maxime

--=20
Maxime Ripard, Bootlin
Embedded Linux and Kernel engineering
https://bootlin.com

--5dqx3l4hsuk3weiw
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYIAB0WIQRcEzekXsqa64kGDp7j7w1vZxhRxQUCXHj7vgAKCRDj7w1vZxhR
xecyAP4mfLXF4qD/SP+n+VXeyb0mvspwFb3VpGY2eW1ERmcyyAEAk8LZZvC3+zOR
JanaiJJh7WJroKFs4P31bTIzuu2abA4=
=k0lp
-----END PGP SIGNATURE-----

--5dqx3l4hsuk3weiw--

