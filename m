Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11F71C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 11:45:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE4092083E
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 11:45:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=sirena.org.uk header.i=@sirena.org.uk header.b="lUTdB8kF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE4092083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D53A8E0003; Fri,  1 Mar 2019 06:45:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 384758E0001; Fri,  1 Mar 2019 06:45:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29AF48E0003; Fri,  1 Mar 2019 06:45:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id C94488E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 06:45:55 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id j44so11217999wre.22
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 03:45:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=T6pXHKNa+ACXCXsUuVIA/K9jwD+fxsERuqC5A6ON50c=;
        b=bi91B72lZN5VDuVmGsvuRMUamiR1P7CW4crHQFIjYkAu7EleFUh9oK0jvYAXoZoLy/
         jRfJlnFd8SA08v6W0Opr8pkZz7gHTbEc99nNqxT0l2m8Mpot1eE9nzqk6/IvJXn7FOdu
         U/t7M/+6EYK4R3oOcwd9IVFV8Jf7tHaTfoZryBEf6A+9/gQnK3/j+CBvgEzsl8tH2vay
         3A1QQH1zeoQwkYDqeq8N/R7oekgW/u8OFAzD///qqDYV4uAsdJSkGmVFl4R3n4D+McgD
         kS9QbE3xt8wHWudnkuhxCEFaBwapu/Rt5AkO/9cRhDEP+oIpWAtCOe/PH5a7fUZlfe6P
         mimg==
X-Gm-Message-State: AHQUAuaQ6IzCjdkwPmdc21ePp7YawW6656MykzmDlA71QX0T9LOzxRdV
	d/lt7aBM0r9S+cPDWHUYBFdTYqREhZ/HBfiT9Bdu1j8mOes2kngvSA7yL6YXf9TawWcCCcZd0Ku
	61FgB4iwXY3Jp5vB6OLYqJtoZVat2d14if/luZURkjs5dQVEGjSZHKBvlbsn0vbw=
X-Received: by 2002:a1c:c187:: with SMTP id r129mr2842988wmf.107.1551440755178;
        Fri, 01 Mar 2019 03:45:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ6IVMhkkXhaYqFJQN3392tFc2jwAc9NOrcFILCaS43NgS38bCbkggH1JsrNNAVQX8qNL5G
X-Received: by 2002:a1c:c187:: with SMTP id r129mr2842933wmf.107.1551440754120;
        Fri, 01 Mar 2019 03:45:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551440754; cv=none;
        d=google.com; s=arc-20160816;
        b=jOHLE2dQwwdtrplqsmu03DoT9bwdAj54FPnhNvXh9ufvU8m0t5YUURsOibkJfecqJS
         +pJrPTausRr/we1UDByE1N0UVO7/pmTg86owq8iJVMdIpu/lD0CW4MCV0vZEXJRJwFGK
         PFjS/iAAfBr5BYIBWjuA8iF/3xJEI5nEtf7UDxyq48R7Pq5rhFF5PPgvJSOf8MCN2x/v
         yblPosKiiWY1Rzzq4i9/ae5LfXjFXLv4hdYF+YCKI0FiPtkYahsYS8WbqQwJfq+poTdz
         CEdP6q9y4pQHzC5L3vowq+Fzx7M+9ykP699T4FI3gSm19whd3RaWfv+VzxbrT/ALCmVr
         xwpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=T6pXHKNa+ACXCXsUuVIA/K9jwD+fxsERuqC5A6ON50c=;
        b=uaPCD4MBmkvOLmENCOVQBq9CEb+si9Qvl8HMpNwQGzwgZxg0xkPk/WTzza1XtR11gP
         qMxYu4n8DCcYEsbmrv9/80Xb85NssfrQnfCsnbihGRZskB6Mdr26Jf4i3cgHA0S6yrM1
         sxfox43biY0+rtzPGQRj3IpWWbws64hunsFIxPU92AKm2h1a4rlXAiosNAR8uztK5f9u
         E/NaAQLAq4Z/qe4iNkCEUcKBKt9OU6HAcS1i587zHJwvVepYjov/5FIwQv64sLgBE8u7
         iP/bt1d9k/9Qe/6h6mZdRuHky5o0hXPmP9s45N2e3cNtZEdDJWV9bJugNb0o3kSPpX8z
         KKWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sirena.org.uk header.s=20170815-heliosphere header.b=lUTdB8kF;
       spf=pass (google.com: best guess record for domain of broonie@sirena.org.uk designates 2a01:7e01::f03c:91ff:fed4:a3b6 as permitted sender) smtp.mailfrom=broonie@sirena.org.uk;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from heliosphere.sirena.org.uk (heliosphere.sirena.org.uk. [2a01:7e01::f03c:91ff:fed4:a3b6])
        by mx.google.com with ESMTPS id a142si4808977wma.91.2019.03.01.03.45.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 03:45:54 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of broonie@sirena.org.uk designates 2a01:7e01::f03c:91ff:fed4:a3b6 as permitted sender) client-ip=2a01:7e01::f03c:91ff:fed4:a3b6;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sirena.org.uk header.s=20170815-heliosphere header.b=lUTdB8kF;
       spf=pass (google.com: best guess record for domain of broonie@sirena.org.uk designates 2a01:7e01::f03c:91ff:fed4:a3b6 as permitted sender) smtp.mailfrom=broonie@sirena.org.uk;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=sirena.org.uk; s=20170815-heliosphere; h=In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=T6pXHKNa+ACXCXsUuVIA/K9jwD+fxsERuqC5A6ON50c=; b=lUTdB8kF9sCjBt8oRzoqjZkIt
	sGcKFwfzbePvy3qmykp1v76FCrTI+N+gFkC2IBMANuYYzdC2Botq2iRTEwavgBOWuozlPjAbGJLQ4
	yitkW7tuiG/n+bxl2BfQSljUuApSG9u1TxAntY/umXEhoFQ58h1ZvYbNmrdBZuVLQVNd4=;
Received: from cpc102320-sgyl38-2-0-cust46.18-2.cable.virginm.net ([82.37.168.47] helo=debutante.sirena.org.uk)
	by heliosphere.sirena.org.uk with esmtpa (Exim 4.89)
	(envelope-from <broonie@sirena.org.uk>)
	id 1gzgbU-00027o-6q; Fri, 01 Mar 2019 11:45:24 +0000
Received: by debutante.sirena.org.uk (Postfix, from userid 1000)
	id 5C0F11126E96; Fri,  1 Mar 2019 11:45:23 +0000 (GMT)
Date: Fri, 1 Mar 2019 11:45:23 +0000
From: Mark Brown <broonie@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>,
	"kernelci.org bot" <bot@kernelci.org>,
	Tomeu Vizoso <tomeu.vizoso@collabora.com>,
	guillaume.tucker@collabora.com, matthew.hart@linaro.org,
	Stephen Rothwell <sfr@canb.auug.org.au>, khilman@baylibre.com,
	enric.balletbo@collabora.com, Nicholas Piggin <npiggin@gmail.com>,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Kees Cook <keescook@chromium.org>, Adrian Reber <adrian@lisas.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>,
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
	Michal Hocko <mhocko@suse.com>, Richard Guy Briggs <rgb@redhat.com>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>, info@kernelci.org
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
Message-ID: <20190301114523.GA7429@sirena.org.uk>
References: <5c6702da.1c69fb81.12a14.4ece@mx.google.com>
 <20190215104325.039dbbd9c3bfb35b95f9247b@linux-foundation.org>
 <20190215185151.GG7897@sirena.org.uk>
 <20190226155948.299aa894a5576e61dda3e5aa@linux-foundation.org>
 <CAPcyv4ivjC8fNkfjdFyaYCAjGh7wtvFQnoPpOcR=VNZ=c6d6Rg@mail.gmail.com>
 <20190228151438.fc44921e66f2f5d393c8d7b4@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="5mCyUwZo2JvN/JJP"
Content-Disposition: inline
In-Reply-To: <20190228151438.fc44921e66f2f5d393c8d7b4@linux-foundation.org>
X-Cookie: Yow!
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Feb 28, 2019 at 03:14:38PM -0800, Andrew Morton wrote:

> hm, does bot@kernelci.org actually read emails?  Let's try info@ as well..

bot@ isn't reading mails but it copies people who can look at stuff on
what it sends out.

--5mCyUwZo2JvN/JJP
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAlx5G1AACgkQJNaLcl1U
h9DjOAf+PPHQ/BVl5TBqjfMNMuiPCeaKRG1c8zsb8fiR194RFwgdwNGWRE8HcRXk
AN30FaxyXFI+y7WhlvBmJj3kCLHiP1ZXpDFU7XOpFLEcPdSqjMyYZttxSM5Dztdg
s5M58t9V3ic2Panl7J+yq2e2U3aC8NRui2v8RgsEaXNo++uKkEHRbQy5O8+sp57B
ScsEjIa6hWFmy0XZBOSAWSCo+ev7nIiqTdV7EFcYyD9B/TGzJQKvExT5qqq8NYDy
N2U7xhc4a3pWHmtfkyAYfG9MZw8e1nlnoRZqOETEApoI7T1XG0af2C2CyenZ/YER
MQQzHE5/oVawoiZ1dtzvnsn32Nfl3Q==
=VHFA
-----END PGP SIGNATURE-----

--5mCyUwZo2JvN/JJP--

