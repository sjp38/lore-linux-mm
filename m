Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38E1CC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:52:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3C90222A1
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:52:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=sirena.org.uk header.i=@sirena.org.uk header.b="VpH8YuDe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3C90222A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6DEB88E0002; Fri, 15 Feb 2019 13:52:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6661C8E0001; Fri, 15 Feb 2019 13:52:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 556AB8E0002; Fri, 15 Feb 2019 13:52:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id EEFEC8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 13:52:17 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id z13so555331wrp.5
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 10:52:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=8qR40ZC+e9YK0rsc5uJ5+eiqEVuDiidFJ7N+XNLUBh8=;
        b=G02K5XKOwSTsXizdvP6pdUVSeeqd+ce6R4IaXSbbpcK/Qlhd1kM+CxhSMWtBW5qflN
         kzKnK8hzAO/Aj7u4UVyfWeNjKFbDV/Umhv9NpVohA+l1JnBfo/SQL2Wh+XIV4o6tTyOk
         E4YWL8MjBT3VKQWqNpE8IsQONjQUCiBlNGE8AfOO/KRK4cTk2qwIjOtIWJzgoZBzmo+O
         OYSRJtdOheibqS/XQSkHZ4nef+A7gIvhfzSGl+BAJmNy8/9880E7Rl1qLX1EFsAOlwuV
         98PfO3mXV9TuXJX8IRjIGDP1wj/o9b2oe+/z58qoPtlhrm2IRs0UY47HeiQFeyUV9ZT4
         F4jg==
X-Gm-Message-State: AHQUAuZ54YNxY3hgJY2nWhyo+9QCuvgAx7xKzt+GgILX2urr0IEU/GzZ
	u7hP01j4Cd1C69mFJMq4STM3Uqq4k7LVzGolcmBrwqJPtofQ/ZXcmpz9vDOCy2/3G9yYAL6Fa7H
	KsOnbxWucAR5JtmNwmrwqTEQsSN4VtE67DOkykE+aNrFQA//U0+GY0tCE9SOSAts=
X-Received: by 2002:adf:8143:: with SMTP id 61mr7610756wrm.47.1550256737541;
        Fri, 15 Feb 2019 10:52:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYDvYBN1rs2LbtHqBNLp2OS5hHN4OMGT51ut6rS9IP0yV98pqyHa5MPzPDSwnC3fPNRJ9ev
X-Received: by 2002:adf:8143:: with SMTP id 61mr7610728wrm.47.1550256736904;
        Fri, 15 Feb 2019 10:52:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550256736; cv=none;
        d=google.com; s=arc-20160816;
        b=SXt5VxddG1sTWZ2DxYXr0RDOJ2AWzBiAt1Ze041CfXmP/jWO3p6fDGUywOxNrgmxQN
         0yt8vnjYTcpJA7f8ZXAlGc6E4MNmy6UaGWKeb7G4+4YOYvbge25nsQ8qy4RBxhBRV2xq
         UKiIa0e3gJnMk4dljyJBNenNBldL41Sx8TVngiMXbwwMPDaoI97OCqfIdzI/MMcM7rkC
         5BqstM2mLX84yhb+rQOc3qUULSAw81JYGumiM26ZUkj2N310kjkm6WehGnSt/zg27e7V
         b9t25IgGWHhWyjg8BNpMqjXF/DCkFgqF4rtT5psPRhU1oKyiYcRz4rG36N2tEtCI/vs7
         9K3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=8qR40ZC+e9YK0rsc5uJ5+eiqEVuDiidFJ7N+XNLUBh8=;
        b=hBFqmVpEZBESyHmGuSVVmlRdAB7tsbsVD2YqTRZIhjtwv7zn45TbttHdkaedh687hC
         UnfFVF2T0HGZ8R7VRoHLtFy8G23Daj8fbwgUWymcZD1egf9wZb+pyqGkthqfsnbreQus
         Gdh1mQJU2M2+Iw1AV/7rKiD0U775yIuG57FKbCMPfIpahDmgxbqJXKSyeVmQq6f3VCth
         UHGyhG+K6TS9vkK8dKRyPk56zecI7M/sidpR5LPwOE1uMhypAaXCpr9r88f+ZLPVnrzk
         R2gCEjTa/TpmQhhxvVyf8Y9XYjCQ/xBf22UeDNzlXC+q3R5U5hcCbdJVO87jvPhtUL5x
         PqUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sirena.org.uk header.s=20170815-heliosphere header.b=VpH8YuDe;
       spf=pass (google.com: best guess record for domain of broonie@sirena.org.uk designates 172.104.155.198 as permitted sender) smtp.mailfrom=broonie@sirena.org.uk;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from heliosphere.sirena.org.uk (heliosphere.sirena.org.uk. [172.104.155.198])
        by mx.google.com with ESMTPS id r13si4185284wrs.352.2019.02.15.10.52.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Feb 2019 10:52:16 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of broonie@sirena.org.uk designates 172.104.155.198 as permitted sender) client-ip=172.104.155.198;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sirena.org.uk header.s=20170815-heliosphere header.b=VpH8YuDe;
       spf=pass (google.com: best guess record for domain of broonie@sirena.org.uk designates 172.104.155.198 as permitted sender) smtp.mailfrom=broonie@sirena.org.uk;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=sirena.org.uk; s=20170815-heliosphere; h=In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=8qR40ZC+e9YK0rsc5uJ5+eiqEVuDiidFJ7N+XNLUBh8=; b=VpH8YuDe0xki0RDP8di9dkwrv
	Vw+oaiytt2TRY0YsQRGRfCJB+0FY/OyBs76ZKWmHE2a0wtD2NdZkbg5d7WNEaLXHV+h2iqjieQ6p2
	HFqXVvbUXBl4QRtiAJZj8nA8rdGKUvldfzBnYmUCobAJcy4xMgpbKYleHOHxqZV12e7VQ=;
Received: from cpc102320-sgyl38-2-0-cust46.18-2.cable.virginm.net ([82.37.168.47] helo=debutante.sirena.org.uk)
	by heliosphere.sirena.org.uk with esmtpa (Exim 4.89)
	(envelope-from <broonie@sirena.org.uk>)
	id 1guiaV-0000tf-JU; Fri, 15 Feb 2019 18:51:51 +0000
Received: by debutante.sirena.org.uk (Postfix, from userid 1000)
	id 0A9ED11286B7; Fri, 15 Feb 2019 18:51:51 +0000 (GMT)
Date: Fri, 15 Feb 2019 18:51:51 +0000
From: Mark Brown <broonie@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "kernelci.org bot" <bot@kernelci.org>, tomeu.vizoso@collabora.com,
	guillaume.tucker@collabora.com,
	Dan Williams <dan.j.williams@intel.com>, matthew.hart@linaro.org,
	Stephen Rothwell <sfr@canb.auug.org.au>, khilman@baylibre.com,
	enric.balletbo@collabora.com, Nicholas Piggin <npiggin@gmail.com>,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Kees Cook <keescook@chromium.org>, Adrian Reber <adrian@lisas.de>,
	linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	linux-mm@kvack.org,
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
	Michal Hocko <mhocko@suse.com>, Richard Guy Briggs <rgb@redhat.com>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
Message-ID: <20190215185151.GG7897@sirena.org.uk>
References: <5c6702da.1c69fb81.12a14.4ece@mx.google.com>
 <20190215104325.039dbbd9c3bfb35b95f9247b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="ulDeV4rPMk/y39in"
Content-Disposition: inline
In-Reply-To: <20190215104325.039dbbd9c3bfb35b95f9247b@linux-foundation.org>
X-Cookie: Neutrinos have bad breadth.
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--ulDeV4rPMk/y39in
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Feb 15, 2019 at 10:43:25AM -0800, Andrew Morton wrote:
> On Fri, 15 Feb 2019 10:20:10 -0800 (PST) "kernelci.org bot" <bot@kernelci.org> wrote:

> >   Details:    https://kernelci.org/boot/id/5c666ea959b514b017fe6017
> >   Plain log:  https://storage.kernelci.org//next/master/next-20190215/arm/multi_v7_defconfig+CONFIG_SMP=n/gcc-7/lab-collabora/boot-am335x-boneblack.txt
> >   HTML log:   https://storage.kernelci.org//next/master/next-20190215/arm/multi_v7_defconfig+CONFIG_SMP=n/gcc-7/lab-collabora/boot-am335x-boneblack.html

> Thanks.

> But what actually went wrong?  Kernel doesn't boot?

The linked logs show the kernel dying early in boot before the console
comes up so yeah.  There should be kernel output at the bottom of the
logs.

--ulDeV4rPMk/y39in
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAlxnCkYACgkQJNaLcl1U
h9C80AgAgd27KFeIsKCGWeXoSKrX1pbokLajTcvGXF+ITEiv7vS0eBekb9KG/Wvx
FuKCmuN4yRBKT+GgPSTv6oMwJjnicGFiU+k8bqwROu2SuNqnJwACl2fLIgbuIB4D
jWNGxS9rsjRn8jVSsm0/kk38szs6jjUnMtoL73XT5UBNm6rZS5iLhEI6kjCJkBvJ
1yvgLPdLzKhsdm/GCWfol8BVp4re2bLsRmrrMeEzyQsTazQK/umjNbby2DSILlAO
jB0wvg1elRjdqG/F6cSZLtQEwdJLGKhv1ETMtG9fWQXzQvmNwYOQI6+KbzJ+FZcx
L1nTT0hILYzXvjtkZKJ9fjOR7Uu4Aw==
=M5GD
-----END PGP SIGNATURE-----

--ulDeV4rPMk/y39in--

