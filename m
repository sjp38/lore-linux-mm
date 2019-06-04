Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0ED62C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 14:20:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB5E42473C
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 14:20:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="nIZmN1Fq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB5E42473C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42F606B026C; Tue,  4 Jun 2019 10:20:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E04D6B026E; Tue,  4 Jun 2019 10:20:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A9146B0272; Tue,  4 Jun 2019 10:20:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E81696B026C
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 10:20:41 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d125so16276451pfd.3
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 07:20:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=tMGxwX7P22L3/MD7F7w+Qs6FF3WSaRYGYVCWNvm7c50=;
        b=uEn3DXvlDW8PvOw10iNnfzMmwzz27+Vcmh35gyzDDL4dP0BSPQ1w5pIaKQqgwLSpPU
         ft1yBx0enb6jzMB6QGVnNsfKiUqRM3Mjw4RvsEbdqwF0wEpgvsj6pz3xDh7Zn4PWwfoc
         QizDVqYZaurP5PvfMj795o+7lAc3D7AV6UYz3UrmsrW60TsSBD5QRti7h+FUj+wLhiYP
         dad+F0eDO0jqGWvNVmWkB0LBNL5u630grW/wdSV18U+hLn1YvwAlFBeErTjLLwtt1nu5
         8eiiWJ8FN09/5poy868gxm9ZfRYZvgB1EkP8WIP9d1+oX0sdjLsHnRjrLSsOuZ+dnMdd
         r+ZQ==
X-Gm-Message-State: APjAAAVkFvPLEacByVYhn390siHto77gPlNv5S2x9om7UHpJKxY5U75t
	NHQ0TZZeqO/jhfg9aPw7iOZhedP26/g/So8StxIqvlVhFse+HNeeJwrHdZxQsYbqJigDlAxyRQL
	KaU8b/DdsLsyMpvZNO9q0SL667xH5fsnzqJ2gGL5aIExWZ2f+GN9fWG3Y241/WHFiEQ==
X-Received: by 2002:a17:90a:808a:: with SMTP id c10mr36665682pjn.67.1559658041609;
        Tue, 04 Jun 2019 07:20:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYP1nssHqudnbHkQJkqBXdvkFRgzXrJLa7UigxfIo2bzptR2fUW2jUllhU3YRb7tLuvs5j
X-Received: by 2002:a17:90a:808a:: with SMTP id c10mr36665589pjn.67.1559658040711;
        Tue, 04 Jun 2019 07:20:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559658040; cv=none;
        d=google.com; s=arc-20160816;
        b=OEfIx0UTYrek3pGxH1NZkByhtjvJ87Nz4v1ZxKMy9fg/WBC4+gnHbUAfACocu7CRBi
         oVivLNSSS+IPT7X2Jn/Va95Me/n4fwV7YAjrBXG9KSAJ6pSct+RKMENNde4yNIZQv9Gq
         nwrsey2RH0Y5gs+k9HRMnnM7BnSPvKsMoL54MS9Su8QQGK/fCT+cUgHDENLG4ISw+rhc
         IfcH/Cg99sxf7XRwxCA8ZNSjhDg4k8Ym4ks3geALvxRM8YnQZsN4arkTjJKBk7kwZZAZ
         4M3UATd6+f8A9gP3gMs3EO/c3v69knvfPKa+GMY3u1ehz10+3pzWIbMpt75OBaMI9pu1
         ChAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=tMGxwX7P22L3/MD7F7w+Qs6FF3WSaRYGYVCWNvm7c50=;
        b=Q+4uSlUlazjTkYeZsT9KUgeaMVcGM9fm7MOxNrfJNF2JKr8ALlOKPoeRo/kF4HpvLL
         F2+NQCRHDJYKmySCehXaOVn3DeuGzhbTKmlZTjiYuHJ9yxPbn9MW5RFGI0Lu8f+FljZX
         +2uu7xXINd+qSpfvLVjSoC1jG4bys0F3NkEKqxvooXwYAaj0lBJXoXU4ckt/Z9oZrVJ0
         PKt3qtCiSaSudXWjpzGE1ADivyTF4HWOkakFxXTEEep2W3feLSpyd5o2064Mqq+hAGDs
         KFbA4eS/lsNCxzEGXuqDNWrbrzzaCiR34PqI9oNapiLIXhl1FASGnUpAw80tNI5Ky+Yf
         zVfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=nIZmN1Fq;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (bilbo.ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id d24si23624305pgj.18.2019.06.04.07.20.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Jun 2019 07:20:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=nIZmN1Fq;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45JDbl1Dcjz9sBb;
	Wed,  5 Jun 2019 00:20:35 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1559658035;
	bh=tMGxwX7P22L3/MD7F7w+Qs6FF3WSaRYGYVCWNvm7c50=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=nIZmN1Fq4Q1801Z3veCCCfGDYCbUh15plZiiVaxoVVw29tO9T2wVlGVylk2C/BIvy
	 YrpzWuSY4mMQV5r/7XJIkkM5CU9ZjLlzDtc8jJ7WTVHDBWY8VauQTvz4qkFMTDBxJL
	 9mx8/ZNS95tq7YzPeLiswHb0R00YJiJIiyGhxqgtSm2sz1AwRE4GuH32TRYjk5dFc/
	 BkBluR76uYKKGGFPKqR9smRuvRYC39A0okf4DTeluT6WwGSMiB4Lx9USVX35+qijBJ
	 ru3RjE+NVau98oTj7AIh6bcvQdX7oDcIgnWO0LPisGkJ6jNzc303fy1Tq9LMoXFDB6
	 kAGbD+uvJC17g==
Date: Wed, 5 Jun 2019 00:20:21 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Sachin Sant <sachinp@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-next@vger.kernel.org,
 linux-mm@kvack.org, "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
 linux-kernel@vger.kernel.org
Subject: Re: [POWERPC][next-20190603] Boot failure : Kernel BUG at
 mm/vmalloc.c:470
Message-ID: <20190605002021.12392167@canb.auug.org.au>
In-Reply-To: <88ADCAAE-4F1A-49FE-A454-BBAB12A88C70@linux.vnet.ibm.com>
References: <9F9C0085-F8A4-4B66-802B-382119E34DF5@linux.vnet.ibm.com>
	<20190604202918.17a1e466@canb.auug.org.au>
	<88ADCAAE-4F1A-49FE-A454-BBAB12A88C70@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/_igep8kUAWl9L/+0neHtMzK"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/_igep8kUAWl9L/+0neHtMzK
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi Sachin,

On Tue, 4 Jun 2019 19:09:26 +0530 Sachin Sant <sachinp@linux.vnet.ibm.com> =
wrote:
>
> With today=E2=80=99s next (20190604) I no longer see this issue.

Excellent, thanks for verifying.

--=20
Cheers,
Stephen Rothwell

--Sig_/_igep8kUAWl9L/+0neHtMzK
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlz2fiUACgkQAVBC80lX
0GwP7Af+Nds/li0BeO7YFEHCVlP8ZGoPFFEQWkfiT8toFusuPbkFeVnHRYq3wODm
5FviWpQpujr9p5c2XrArh4o+CmZR9Ht7DJrpN2pwpNLYzDE6ewRX42sK3zWEr7wf
MIYwHJRSjLyxcQ2gJDKUe1UjHQZZpaBnk9zjuuPbVNLilOMUUgYUXCZwWS8AU2Qr
/8DVv3lT5EQSB3lDQNJR6ULYYPOTXmdA8B1DrDV4knmzc/VtOdevKhEHAQabbXj5
e7mcLfr91dqNQU+pNakAd+bT6h8Z54a7nqNHL8ObT4SoIi/K4uCYpNM4dfk0+n31
MrkfBaVsgQll4+Gbt7/Sflxco6udxQ==
=SSN/
-----END PGP SIGNATURE-----

--Sig_/_igep8kUAWl9L/+0neHtMzK--

