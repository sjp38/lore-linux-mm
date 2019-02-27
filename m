Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5725C00319
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 09:20:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A686A20842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 09:20:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A686A20842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bootlin.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 534EE8E0004; Wed, 27 Feb 2019 04:20:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 477948E0001; Wed, 27 Feb 2019 04:20:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31A198E0004; Wed, 27 Feb 2019 04:20:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id C98178E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 04:20:27 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id z8so1242596wmc.4
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 01:20:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=2IBbsZ/C2EsVTAkJaZf7DhCWEPWgCh1eHdYtecEyze8=;
        b=YpBRI5U2y3UguCq4dExpbVljskFaPWryKp+lsLEX3Erfzn100wNeOGyjJSY6LPCG6r
         zRMZfRngZAugk9T8chcXVZjiqzSqmclP7PMxEGeu/2+IYEXlCAbW7uJUTmNaROxA/SuT
         hYYycY1fjBfRWBGjJ1GyvoHjlb+OuCIcDKHaQAmaOsKQ6WsuOIdFJB3NTg+sigPNaFSg
         BjsaVdXlcp1nsLXLrnLsBQDbeouzjBvA806CMwzbHBOPMpZgCAEM3AriJStJ3RUkHEof
         snxXM+a0JZJmf7MzdGeagfn3w8V8eH9vjwHaY2hbZOnB8QWLiYmxw+O0JzrXMkzCD5sT
         rCyQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of maxime.ripard@bootlin.com designates 217.70.183.199 as permitted sender) smtp.mailfrom=maxime.ripard@bootlin.com
X-Gm-Message-State: AHQUAuaBDj3JVIK8a1PewS9IFCs4hEI9ZeL8oGFz58qaEaL/b4Tj90/q
	Ew1Agx4QBx/SJB2ccryFIZOWwq5wTxtSoMSyyTijdarFVQLpp33bwaJdMEPTymCPrTabGr4Fc5f
	hfqHQYYu82kmQprPcWwz19kaMrRxeJ/xbHD7Mzrk+Gi8xziox1/SFKgF6MrUs0obsTw==
X-Received: by 2002:a05:600c:210b:: with SMTP id u11mr1564685wml.11.1551259227320;
        Wed, 27 Feb 2019 01:20:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY/Mmg3n0aq6cJYAPWOPNsOe68FNGUbUle+oCMzZR2ou1EZSpl3uFYeNmJqG0tCtMX0ZVzD
X-Received: by 2002:a05:600c:210b:: with SMTP id u11mr1564629wml.11.1551259226055;
        Wed, 27 Feb 2019 01:20:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551259226; cv=none;
        d=google.com; s=arc-20160816;
        b=EUaC5Zs4Zaras/I4iTsYftR/v062ndDXQHhGFgg9UJH+U42mChZyrodMg9Q/6mCd3A
         eXtcdjrNUexi7wsHGQJv0TRl3k+QtsqsDscsy1x+OToqtK04kAHHRxO/kFzLMIFVr4Bv
         eeUQpMJYX/QxMwmPIxpMtEGclDvTndBBwo/A6pIOTEgydjvoVUUC3rKyJ8nqHwczDuzA
         ZxX+mwhFfhT1VFZLND7ynm0O63zemmLMwu4kqL31mtZ+MVbJBaiCKaIpm3skLldbTTbX
         n4c6gNK1Tgm88FyyhaYcqOBQvCY8yIYDBdfE/GTasqJusJOBIZdRZoCqgNRzOvHMGUdV
         H3rQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=2IBbsZ/C2EsVTAkJaZf7DhCWEPWgCh1eHdYtecEyze8=;
        b=jzrCGyspy+qUkIlI6Upm23fjdpOqCc6Rcnn6kClEoJuO+sZnWgMZdvNUA3lNQOoApR
         40W1IoY3Can7oaPX2dggvEblsKVj0FsB0TBdLw0zUkpum6pi9Y4QP3BxPaubkxvFTcc3
         PQ1Vq4/6o29N1e2T8ewFxIS80QvLFW5XSLluC7EHAAGTM90xVLJtcaTBifHv/D956B7Z
         YOLKnZ1J/HjCGDYzNad8hDNdDZdzvA9yhJo1m/vfD33gyzKlzRhGhSWR3FBXEt9I44OI
         1XKOE6AwSBaip09/Lg83R+xbYOmb8C5MuI69C878P/3+2e3tGAwsAP5h79BqI+hWZIcX
         DAAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of maxime.ripard@bootlin.com designates 217.70.183.199 as permitted sender) smtp.mailfrom=maxime.ripard@bootlin.com
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id g17si11041271wro.234.2019.02.27.01.20.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Feb 2019 01:20:26 -0800 (PST)
Received-SPF: pass (google.com: domain of maxime.ripard@bootlin.com designates 217.70.183.199 as permitted sender) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of maxime.ripard@bootlin.com designates 217.70.183.199 as permitted sender) smtp.mailfrom=maxime.ripard@bootlin.com
X-Originating-IP: 90.88.147.150
Received: from localhost (aaubervilliers-681-1-27-150.w90-88.abo.wanadoo.fr [90.88.147.150])
	(Authenticated sender: maxime.ripard@bootlin.com)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id 64411FF805;
	Wed, 27 Feb 2019 09:20:24 +0000 (UTC)
Date: Wed, 27 Feb 2019 10:20:23 +0100
From: Maxime Ripard <maxime.ripard@bootlin.com>
To: Gerhard Wiesinger <lists@wiesinger.com>
Cc: arm@lists.fedoraproject.org, Chen-Yu Tsai <wens@csie.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	Florian Fainelli <f.fainelli@gmail.com>, filbar@centrum.cz
Subject: Re: Banana Pi-R1 stabil
Message-ID: <20190227092023.nvr34byfjranujfm@flea>
References: <7b20af72-76ea-a7b1-9939-ca378dc0ed83@wiesinger.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <7b20af72-76ea-a7b1-9939-ca378dc0ed83@wiesinger.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 24, 2019 at 09:04:57AM +0100, Gerhard Wiesinger wrote:
> Hello,
>=20
> I've 3 Banana Pi R1, one running with self compiled kernel
> 4.7.4-200.BPiR1.fc24.armv7hl and old Fedora 25 which is VERY STABLE, the 2
> others are running with Fedora 29 latest, kernel 4.20.10-200.fc29.armv7hl=
=2E I
> tried a lot of kernels between of around 4.11
> (kernel-4.11.10-200.fc25.armv7hl) until 4.20.10 but all had crashes witho=
ut
> any output on the serial console or kernel panics after a short time of
> period (minutes, hours, max. days)
>=20
> Latest known working and stable self compiled kernel: kernel
> 4.7.4-200.BPiR1.fc24.armv7hl:
>=20
> https://www.wiesinger.com/opensource/fedora/kernel/BananaPi-R1/
>=20
> With 4.8.x the DSA b53 switch infrastructure has been introduced which
> didn't work (until ca8931948344c485569b04821d1f6bcebccd376b and kernel
> 4.18.x):
>=20
> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/dri=
vers/net/dsa/b53?h=3Dv4.20.12
>=20
> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/log/driv=
ers/net/dsa/b53?h=3Dv4.20.12
>=20
> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/d=
rivers/net/dsa/b53?h=3Dv4.20.12&id=3Dca8931948344c485569b04821d1f6bcebccd37=
6b
>=20
> I has been fixed with kernel 4.18.x:
>=20
> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/log/driv=
ers/net/dsa/b53?h=3Dlinux-4.18.y
>=20
>=20
> So current status is, that kernel crashes regularly, see some samples bel=
ow.
> It is typically a "Unable to handle kernel paging request at virtual addr=
es"
>=20
> Another interesting thing: A Banana Pro works well (which has also an
> Allwinner A20 in the same revision) running same Fedora 29 and latest
> kernels (e.g. kernel 4.20.10-200.fc29.armv7hl.).
>=20
> Since it happens on 2 different devices and with different power supplies
> (all with enough power) and also the same type which works well on the
> working old kernel) a hardware issue is very unlikely.
>=20
> I guess it has something to do with virtual memory.
>=20
> Any ideas?

> [47322.960193] Unable to handle kernel paging request at virtual addres 5=
675d0

That line is a bit suspicious

Anyway, cpufreq is known to cause those kind of errors when the
voltage / frequency association is not correct.

Given the stack trace and that the BananaPro doesn't have cpufreq
enabled, my first guess would be that it's what's happening. Could you
try using the performance governor and see if it's more stable?

If it is, then using this:
https://github.com/ssvb/cpuburn-arm/blob/master/cpufreq-ljt-stress-test

will help you find the offending voltage-frequency couple.

Maxime

--=20
Maxime Ripard, Bootlin
Embedded Linux and Kernel engineering
https://bootlin.com

