Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2E3EC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 10:29:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96D0A24537
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 10:29:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="gZ2toIQ0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96D0A24537
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC8B46B026B; Tue,  4 Jun 2019 06:29:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E51E36B026C; Tue,  4 Jun 2019 06:29:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCB296B026E; Tue,  4 Jun 2019 06:29:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 913B56B026B
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 06:29:26 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id j36so12091600pgb.20
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 03:29:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=WIejSqOqVWArGUwS80dnLpzCIBBF7ejgcfIQE3A3wCQ=;
        b=BNKO+VeTt4it0SvduU6wr+0df0S3YdxZkEpXqoiHdhX2hj4cQMWkiNNpbA1HXD3c6D
         14d9qvyXHqy01v9ur7uPu4qpr4T+G2HUvw5UEpm27Dv3MWA29kmFy8h86D85lj4icG8X
         h/vD1yedinlbS7GSKlq62spY6oKvO8LaK0KNJGWmIgFWbOCFZD8Uq1uVy9yXXjwiEkVx
         nySwEZjl+SLrzcnUHskYwk14As5f77qes896tzyyF7JZwP6dP0B8Q4T9aMpHovNO40JW
         eShXfAXLu1ekqABNkM8rdI4bJb+5n+IL6VehteIoqLMg0NxNpUtHUU3idi4zczv5531n
         p0zQ==
X-Gm-Message-State: APjAAAUPo3RqXKwM4VJSzVfbOS21BSjrDdxl74x91RVAB5CCa6LwZteZ
	GJ44UUuU8swy6ivnT8Pjale+dvs8hOA8ZvRbhHQAm9TlblZCnM3pVHFVzI5VNWvlpQUajBxCZX8
	ntTv9iQMV+uVw38Uw3tM454f79u5WCulH32/0TnI/GByG9xGPigwq3wzN8UjUv9KJ6A==
X-Received: by 2002:a63:1657:: with SMTP id 23mr32281134pgw.98.1559644166125;
        Tue, 04 Jun 2019 03:29:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJhD7G6f0A5w7W4DbSSDLTNbiHNyzWZwUx0PY5ZRLABEcOSIKFhXNbCxLae806dz3xVNKx
X-Received: by 2002:a63:1657:: with SMTP id 23mr32281011pgw.98.1559644164856;
        Tue, 04 Jun 2019 03:29:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559644164; cv=none;
        d=google.com; s=arc-20160816;
        b=aYmb51XNcCuplUuuO82BvgMiF6Oy1sxBBScI9j/cf/9fxYPUwPWAkCtKijUxPb+kXA
         BGbbKv/5WM/yewCRZvY1MY9nBccC//5S0RFQgBd9aPT6Qy0BjMghFcNUf3quOplBPc2q
         z0Qzb0gS0lcmd7w0YSCbncRwgjcPcu3J06jsGpUNo1jipJ8P6RtAyVBUlrtb+RKmqn/O
         PrZxrUu3vTjgUg8omilgsf2gTdZKbsA6kfLjoOiOFspydOYAU5bFvpr8WhiQk0aV3y+s
         g3HEniR3OydKZkA9AjVXqcescTOWl29S4H5rmtPFkSx0fflC8QFUvvBF7lb++b0fqeR1
         44cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=WIejSqOqVWArGUwS80dnLpzCIBBF7ejgcfIQE3A3wCQ=;
        b=m1aj2pqv3xMDqbQAqXndr6nMkA+OikH9snTVYn8y/Zfdiy5uvxp/Kph2HPE6d8A1q9
         XfidbhxPdIo8Elb8qHO1S6aR8/4+9HQRvIzRYEG/I/agc1LkX53Ao4nZj7Np6D6CMDSt
         7IcLFjpaiYWItUU8UUjOA+V8EmyUK7Oa7Gogpaff8b1Bmlev95A70Tn8l5vDHXoPmkrV
         UY0u5YZ3PGdRjfCjL1H+B9KeVjfrdKo78pYHxk7+hXU2zuEae9urdKYbONdHYyerlR3o
         U/MotBUqVZdEBP/d8xY58tNsHgPE2O7xymXacqVyEfv44geVNm4Iy864qsvQb0ciG/74
         44KA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=gZ2toIQ0;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (bilbo.ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id h34si24147627pld.187.2019.06.04.03.29.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Jun 2019 03:29:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=gZ2toIQ0;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45J7Sx4Bx3z9s3Z;
	Tue,  4 Jun 2019 20:29:21 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1559644162;
	bh=WIejSqOqVWArGUwS80dnLpzCIBBF7ejgcfIQE3A3wCQ=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=gZ2toIQ0UxbHR2sJ10+sYJ3SvpmBB8I1fSgYFk5s+1NZdNGar/HAcbyHm5IeGMFnH
	 mIiH8YPx44nfKkr/q/hDb3RwgsTD7mHa1pIO9HBM+5s7yUuv4QAGknaIx13Gi/8gfh
	 uLt9OYtw0QMul/6N0CtaibZsOIxxjoju2iQDgG6kU+NxG+Bhhd0TO7ifDJ+Al3Kqny
	 nicJfwpClEdmH/2G2HMmhS68zeaBoDK65fE0Pw2hSKXCpaTnMO4TbkaygK5k/rP9ZQ
	 phjpn1em8KVoDSvmML+aNpDeGayvraC72jiEM4KaLulnjWkRMKl56VhAokuXcJSF9H
	 VjhbSUfU8DQOw==
Date: Tue, 4 Jun 2019 20:29:18 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Sachin Sant <sachinp@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-next@vger.kernel.org,
 linux-mm@kvack.org, "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
 linux-kernel@vger.kernel.org
Subject: Re: [POWERPC][next-20190603] Boot failure : Kernel BUG at
 mm/vmalloc.c:470
Message-ID: <20190604202918.17a1e466@canb.auug.org.au>
In-Reply-To: <9F9C0085-F8A4-4B66-802B-382119E34DF5@linux.vnet.ibm.com>
References: <9F9C0085-F8A4-4B66-802B-382119E34DF5@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/n.aGLPJk/wsZDAk8OiMeL=b"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/n.aGLPJk/wsZDAk8OiMeL=b
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Sachin,

On Tue, 4 Jun 2019 14:45:43 +0530 Sachin Sant <sachinp@linux.vnet.ibm.com> =
wrote:
>
> While booting linux-next [next-20190603] on a POWER9 LPAR following
> BUG is encountered and the boot fails.
>=20
> If I revert the following 2 patches I no longer see this BUG message
>=20
> 07031d37b2f9 ( mm/vmalloc.c: switch to WARN_ON() and move it under unlink=
_va() )
> 728e0fbf263e ( mm/vmalloc.c: get rid of one single unlink_va() when merge=
 )

This latter patch has been fixed in today's linux-next ...

--=20
Cheers,
Stephen Rothwell

--Sig_/n.aGLPJk/wsZDAk8OiMeL=b
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlz2R/4ACgkQAVBC80lX
0GxNXwf/fJ0Go1oz1h68yR3tc7OY90gu/bZ5Klbs+GSN973ZKndwaWH4q79zzjie
LYHNzKdPpxDLckq08NQSFajRzh6gIvzI+qeaLHjss93qbxpOhzLRjI7UQsD+isR2
S2HsUU7Tn1hAsVZhbZp3McmIOPIRet/p6jA0K43BH+eeXrcT7R6TOTNkiIV1X1/o
AGsvFmJ80rVbJ/q4mCeC4q5Dz0BrTnCRKhHXChocYDPqSRvjSrwfnI+Uqk9ywHuD
TIMSsoc1JR/xDGmxnoR8hW91OkQkQ5q8N4OSQSxEqS42HSQkLShxyyHiCBQDQa3N
8jYQuik/cymkDKNlptMJG/Ft6lrldA==
=JezC
-----END PGP SIGNATURE-----

--Sig_/n.aGLPJk/wsZDAk8OiMeL=b--

