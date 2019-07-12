Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 801A8C742AB
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 06:20:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C07421537
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 06:20:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="bEmpV3q8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C07421537
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 977738E011A; Fri, 12 Jul 2019 02:20:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 927F08E00DB; Fri, 12 Jul 2019 02:20:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83D738E011A; Fri, 12 Jul 2019 02:20:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4C79A8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 02:20:33 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id t2so5101498pgs.21
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 23:20:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=kOAbaMX8FlsTSm7oTq0mdhFEoLZ2DXr62rCz0QjP/SM=;
        b=oRJAG13I3h9cWnmd5aZwaqSB+8jDhluYagr94jvq8eIaoWuA5XX0MkMqIA8MHYwO7P
         sm0m145S2R0rGE559a3bDLKrBd1hTD4jT9JV8rLxCFnN+oyCH/eDtjOpZctov68wYzwO
         k88h/whqzlmCncbe4kkAv0G6o8EHkWjDnmghoqV+hrIIsly4a+vk4IEcu3vTNnuv0DnN
         INXgL/nUQPwEnD87oY3EzJv8Z2NWF/A6PEvPzTAIFHiP1MTkyYn/nx+Fuhzj0aaUnROP
         DJTV8SdNlNEynn2h2k5teqJKYa/uZFTdi2Gu/byIlcmco4AgUoPjcnLSBmeMsipNbKQF
         c3WQ==
X-Gm-Message-State: APjAAAVJLZTwZ+gI9oDreG1LfHun2RVIJBD9USmxJX0aNZYiNumgGSDE
	J3HDmvZ8+Nx9NRPJtONpDD+Ufhzy9sRFACX4K3DL3z+CjmJQSjxpNnFO5iNIcnGwpfI9Y0/eggp
	3mhE/PVco4Pxjks7109H3AUeDYYfcJHYnpHAvTUd7CeQXNhe7AXqiMNJkkoOsuVZuyA==
X-Received: by 2002:a17:902:7281:: with SMTP id d1mr9190825pll.329.1562912432808;
        Thu, 11 Jul 2019 23:20:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwA8NnojAD6vAyVinIAD3+fafwAJ+SxZZQZnx20FY1h5OCFVx9OKMYTycY/xKtZye2BhQ5v
X-Received: by 2002:a17:902:7281:: with SMTP id d1mr9190791pll.329.1562912432224;
        Thu, 11 Jul 2019 23:20:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562912432; cv=none;
        d=google.com; s=arc-20160816;
        b=boaeBu5ysLMe4Gy0eYiNUIS21n5TRFx1B8brJquTHaVQDe1VG/yPrB7MZfFY3N5Hhj
         xgKq9evDAhHHqUNlDUE8NobyjMBmBolCiEoZYVULE6UO/dBagAk1MoWoW9pk4vSea+Cu
         psatN99UrE1kO9s/uk2P+yr0fdDMnhAf3pQ2DAFM7KuxeKg+eVgT8CJAMRuanYDFZdfo
         xf+vjF4o6MC+AzT1jCAg2/GxLdEQ7LoyvsLkatSKCB5Gq0Ts14mDX2Fu1jvq3f3acB2s
         QsRh8kim4Qfj1HHpqAEY5nzzpPW2pak6wCv4dry7TzmZEgdouGKsnWUY2XG5A0pJ78IC
         wLaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=kOAbaMX8FlsTSm7oTq0mdhFEoLZ2DXr62rCz0QjP/SM=;
        b=QV4k8yH0BXDrXyABgXVL7eP9iNDqNg6pNDYOpgbAuMdxTOTNWTwL6Db102RT+enAU+
         tG1afZlf2WcLQivkmWaUHi7djaO3KtXjepqbMFQ9hyoMCkSLccgtxc0acOmhryIhJZQw
         jRye13j69g6PFLV6vO0ZjVSa51FEMDZGnNIEgnypUSvC1s5MYzB4d74TvEsVVAlfeP39
         OcFq/aEcGPQMDulVkaapZ5wOu/tv9OU0GpYHKdzPaPV4q1A3FJ6qo3heyUJC9Udiq6RZ
         Yv3bIWzaI/RG58pXjF8Jcq8P/8kQtwJ+Ph+P1rxbWxNbQvZrfomSkuwtxG7idDfd5jNE
         NLXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=bEmpV3q8;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (bilbo.ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id 188si7218165pfv.146.2019.07.11.23.20.31
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 11 Jul 2019 23:20:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=bEmpV3q8;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45lN8F2HD4z9s4Y;
	Fri, 12 Jul 2019 16:20:29 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1562912429;
	bh=kOAbaMX8FlsTSm7oTq0mdhFEoLZ2DXr62rCz0QjP/SM=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=bEmpV3q8U9nxIYHUivDoFRMuLSZkz3J3dxpZxyqOKzxX5S/CuInMzSTlAng9Ewp5z
	 vAJndwYRclJJUFDVrkWzd+kBGH1wY6LbQ6cmmcBinSWq6Cfv4mT/Rt+f5VvYSQHfJA
	 JlHWYx8zZeeGXabBw6gZlG9ZJ87W0uBpiVBMhkS4MJ5Im/N4DUtyQcjO4ePHqPuVId
	 NOKLGz2vukRZ4tfEJsTmStlsotXcXQqplazVuJyvfIAzfzdK/VZMqODLq+aFqnPSjt
	 Fbd1zzZWXefXTSR2H0fM9EB5BL4dhezPVjYqg+zC4qi/0PEL2b8KZqJ5b1gaB7obdy
	 xBteUwbEbXMLg==
Date: Fri, 12 Jul 2019 16:20:27 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: akpm@linux-foundation.org
Cc: broonie@kernel.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org
Subject: Re: mmotm 2019-07-11-21-41 uploaded
Message-ID: <20190712162027.7ca31722@canb.auug.org.au>
In-Reply-To: <20190712044154.fiMaFQ0RD%akpm@linux-foundation.org>
References: <20190712044154.fiMaFQ0RD%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/P.802fFMgzhFjtLGcQJfXOl"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/P.802fFMgzhFjtLGcQJfXOl
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Thu, 11 Jul 2019 21:41:54 -0700 akpm@linux-foundation.org wrote:
>
> * mm-migrate-remove-unused-mode-argument.patch

I had to remove the hunk of this patch that updates fs/iomap.c which
should not exist in your tree by this point.

--=20
Cheers,
Stephen Rothwell

--Sig_/P.802fFMgzhFjtLGcQJfXOl
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAl0oJqwACgkQAVBC80lX
0GwVTAf/UvvmoZmrwsW2LgtazMmufzEJPjW7/PDntLDpJeOsZWcsWol9S2I3nzHs
jNBwtvSQRhUoaZOLIiu4YxV9vTMlEfs8XtbRX3yzhTjg2B/Sb+c4xgfYTON0Ww7F
+McHuE/oiXLaOoiAFfsVVsyUSjlrf8Cs8Ko6gOOONLnvVyZzhiUmLVbCd0EmxwSQ
tB0GjW69nes1pMK356u8aApMhM9qIYJI88AZ6WcjN/AlZgAHdu1LGMTvd9LhdrFR
bpUUfIG1vbp0YvjSa5ztKTBHuB9ATQxULkk/1UyGyMbEmfM9TG1mbdn4K2eTQWWu
oMiSR91cGEtvuEC3/vmPaerfsFLY7A==
=77BJ
-----END PGP SIGNATURE-----

--Sig_/P.802fFMgzhFjtLGcQJfXOl--

