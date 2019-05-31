Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E52D0C04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 03:50:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8971C2632C
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 03:50:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="PlRRvQZB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8971C2632C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAA216B026B; Thu, 30 May 2019 23:50:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5A716B0274; Thu, 30 May 2019 23:50:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D48D86B0278; Thu, 30 May 2019 23:50:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4B66B026B
	for <linux-mm@kvack.org>; Thu, 30 May 2019 23:50:23 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id g11so6268274pfq.7
        for <linux-mm@kvack.org>; Thu, 30 May 2019 20:50:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=hQS1WJIXnfsusc4YBwGaofW4UCQhUN3YmBQWN7NTQS8=;
        b=DY8a+kYIstMnpfGnvMzrw5c4LU2WI5jCw9AqHlgoapMnn8La6rAWU5u7euE3Qzkohc
         MF1AwDKCcDJqvzOrrfeP+iD9IJhQA8bWwc7NRjArIgkYB+2u/HXZUow6/pHiwnkxFijS
         907ZlrOI/WGucVXEwH3/rql9k+ii40erWlk3nal/lft3m8wkeYyCpJ7XCKCyzsonw20o
         u2eN/9zDjcTjskAjO/NsEa/W6vqDSK8nT0QpDyTtwC9rtrpEW1hroqQu6/Tsaf3MGie+
         791ru7ie7liR4aouRhDAIT37CYQ4UAfkG+rJ8zhh7Rf7h1r0jyuJp/obuKZ1xmkK+BwO
         g1TQ==
X-Gm-Message-State: APjAAAW4MyX8+jn3aiDzRGb3lEEyu/wbD04kc24GDJ1a4fhDiofUITgx
	UdMFPPaiX0pG48GAdLeU81SPvx3Zswq15pzrcMoAaSB8PYWPktCKE8p2VnsmgnotIZ7QHsqQg/D
	Qo0lg7CPESx4LhBKALVptLPAb0rXcQ4RgjTfJvF1Ot2EgSjUVtLygsmYJKGfk0tsThw==
X-Received: by 2002:a63:2c01:: with SMTP id s1mr6719347pgs.261.1559274623089;
        Thu, 30 May 2019 20:50:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5WFV9z0shPrRPLzqkaUPvWlOxLUe5xUUAaQm8Zn7QKqObT/WhW2H9FzsUJbpl2wdgENi/
X-Received: by 2002:a63:2c01:: with SMTP id s1mr6719306pgs.261.1559274621936;
        Thu, 30 May 2019 20:50:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559274621; cv=none;
        d=google.com; s=arc-20160816;
        b=x/oaY2nOO4ORM0l4T2cnWHuLUdYF+PvAbutGu6njlAQ930ZP0IoR4COmzRt8Asy9VA
         usydFLn9jyTfymDWLEPwCsJ3xbnbs2BcWub1OoQ6sA5zcuGzHf+nGW4MQRhLEgqVWkWg
         fOCHcPS9fcpfo5B5asAD8ycIp4aEEapYc/Ypu8Jq8WvYU44L/e4Xlds04Rewo7X+YXh2
         9eEJ+OgPmJmIcXfq7XDN9/4bFJx5uClwxpxcRCxjs3uqSbxqkGVTWNrgC+BJHtHHXFMF
         ciV4tkgQDfAA0keCUecNNCX1d5wmzFRA7UNtzwAgZQ882+NnGTz48q6hBLjVkzup4U8w
         9rOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=hQS1WJIXnfsusc4YBwGaofW4UCQhUN3YmBQWN7NTQS8=;
        b=NIQDsAiHSuH05Q4BxRdei/dlYdYTJexulXho8SoAgjBY8h9P0Wbp3j1+ZejGfqvZ1O
         ZwmIandRXpQkh2+y0FCSOi78/NSiOrzyGqhTUNKkv5hP44GTgErHAaButan8yd4eUdvn
         vq9RPndrP84P/CAOR5DMHXH7yiBwAOivtz0MD9XQ/Z0pArpjP9Xof+dJ1jCBgiCNeRvq
         mCCgAONIC7e+POqvd4FtWeqIWgmRLEIbe0HCEbEGN54R0C9MhOdsTZ0ajTZzo9gaAHs0
         EcBPnreskz6IAaTPES8beNO1snzbckjQEy2RoYL3EUOHaXWXiJAoi7dmM7ZV8objOnQw
         0iGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=PlRRvQZB;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id 3si4634162pgt.305.2019.05.30.20.50.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 30 May 2019 20:50:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=PlRRvQZB;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45FVpJ4c70z9sB8;
	Fri, 31 May 2019 13:50:16 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1559274618;
	bh=3Jn9dbpUQuW69rISQSqXh57RfRI00oNjkHZ1rVQBavo=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=PlRRvQZBtSGz+xAA6PBxyynY6UWNDGViQ7MbZq6/FlimXvcCQ03/is6ipsf8Av8DQ
	 +4+2SYR0etZ/u5XhkJBzaOkVTbLRxSHsqb5qTnJApYXbLv6UzT0QkMhK5nXUwoP5XO
	 1cOmZSs9we13FahymyPyxHr32ukL6DTUq0p2NZv/Kc9pJNLzG32OClppN40l8llGeb
	 KGDJb9vkJAXWaRNWoZDPjc9BVN3aXJhSb1gtgV8d2V0635kLyizvhseymPS6UpbfoT
	 z4dxvRdSiZtvutmKQkB7h9k+Ov+TvkRmXkY7ceq4fvSkPRUmWGilspvl889p7wINTx
	 5fqvOujgUBdpg==
Date: Fri, 31 May 2019 13:50:15 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Luigi Semenzato <semenzato@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, broonie@kernel.org,
 linux-fsdevel@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>,
 Linux Memory Management List <linux-mm@kvack.org>,
 linux-next@vger.kernel.org, Michal Hocko <mhocko@suse.cz>,
 mm-commits@vger.kernel.org
Subject: Re: mmotm 2019-05-29-20-52 uploaded
Message-ID: <20190531135015.6a898d26@canb.auug.org.au>
In-Reply-To: <CAA25o9RFhS=qm=B_mYAdQeAUAi7pLbXttWJfw7yKMWQQAXhhAw@mail.gmail.com>
References: <20190530035339.hJr4GziBa%akpm@linux-foundation.org>
	<CAA25o9RFhS=qm=B_mYAdQeAUAi7pLbXttWJfw7yKMWQQAXhhAw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/1ISJy/USqL3uKe+N6QGnZgM"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/1ISJy/USqL3uKe+N6QGnZgM
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

On Wed, 29 May 2019 21:43:36 -0700 Luigi Semenzato <semenzato@google.com> w=
rote:
>
> My apologies but the patch
>=20
> mm-smaps-split-pss-into-components.patch
>=20
> has a bug (does not update private_clean and private_dirty).  Please
> do not include it.  I will resubmit a corrected version.

I have dropped that from linux-next today.

P.S. in the future please trim your replies to relevant bits, thanks.
--=20
Cheers,
Stephen Rothwell

--Sig_/1ISJy/USqL3uKe+N6QGnZgM
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlzwpHcACgkQAVBC80lX
0GzTMwf+P79ZCniPZu4298eDmJPDDV5hrSNugRpBpF7wLOr72Nm/RbueUfGnpM7e
JlSehMtkCyaJkCW7uW+N6Ior1ep747lrkVCtg95G/yB6vrIu5oUlLG2sGxlWlh1D
pAXCHg3T1BB0/8dRvJXr7YmDOLakwpKf+4nN6V0PZwwEctN4ZvcuCWuHnj2lGTnR
BVlrJe4EDfB/sDUSm9i1gd3Dgx5ClUSk7gG8RrYRezNlOS7pCPEOwEgmQ62KUaeD
qncMOV1g6xhllddSxA97HEyf8C6eA+5tDR2kj1EmDu9hZNR+gLHXgyGUg7QWSGEW
dtHgXURwm3m/7VmP4N+fqpqyzkMF2g==
=ImAe
-----END PGP SIGNATURE-----

--Sig_/1ISJy/USqL3uKe+N6QGnZgM--

