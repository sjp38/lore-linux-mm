Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2209C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:15:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F89F20811
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:15:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="NI2m1mTB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F89F20811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 471A36B0006; Tue, 19 Mar 2019 20:15:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4220C6B0007; Tue, 19 Mar 2019 20:15:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 311E56B0008; Tue, 19 Mar 2019 20:15:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id EABE26B0006
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 20:15:22 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z12so795678pgs.4
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 17:15:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=W45/Anm5kjdQ4lfxsCbtGGkxs9RUnNAt7bgKWVLo7P8=;
        b=pDoLOvkttChQh8vJXgZVV93YB3s8EaLmbu0nsUIBMN11Xd2M5Q4qv3btU3nug4T1ms
         1TBqo4xU9xfZ3FwsML/yq5d8Qlv0swAVMMXA+qrOngu1k1r2Uh6K9Aipp0rnrW7ASb2u
         B/AVZ0Wod4Z95WQApNgca3BYzNFDRrZewVU13mjMwKVGQjRpTn9VKNBq1eH1CDbU7Mll
         6hM49OYhiRgrN3ba+vE15bYgwzJNHn+kwMVehmcQ3MSCgFC1btOCa1bwwrD0CLA9Z8vu
         nfKklO6s7sxG9n6UKE3nOYAwmWmqplQGhuWufahI9LvyaCjYEwj+YgLeHW+1gbMwg4QE
         Nzyg==
X-Gm-Message-State: APjAAAU6alZZ4JVWlQroSVcgvRNOHrRvs2RzMjgP3Vu5BTRGwq5eLSli
	e/Ag2q/qszdIDtdWCtIaxHR1QWKPKIHGXkCTLwoUKIXyZTLO/2CgBqX7CH06CQc5GEg/ybc9C3j
	FnSBRQr7T0bQx3RKrsiGsmSnMSP1uhCwSghyWDVNxR1JRUMf3ioHxjK0+GcA0LFN1lQ==
X-Received: by 2002:a63:124c:: with SMTP id 12mr4362465pgs.86.1553040922503;
        Tue, 19 Mar 2019 17:15:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwr95mnr/qCeChhqQfQ96NOHuh3RV2JovLaxOBE5Tlw2Vo2bq+8CfHGBYQhiEbOiv7L1DQK
X-Received: by 2002:a63:124c:: with SMTP id 12mr4362393pgs.86.1553040921471;
        Tue, 19 Mar 2019 17:15:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553040921; cv=none;
        d=google.com; s=arc-20160816;
        b=kP5R564vwuyKK1yb02ZMOJfS1qyDVmgSv3Wi9jx9doZ/geEPrUltKwLbh9OcO3EfnV
         WBdUdJ2IMF4Z2LkXd4y6zt22AwEFsS0BWIqt1Sau0yO+xL2EwCPfXj5ri2EFIdrYlAWR
         Ew2EpqMwcgWINwMuHb+sIdapCPQsn00D7Baj06ACCn5zuaWp610r+ZEgSh51yw+NlxSM
         JFScE7/0HjJYXfdFKTkIuh0LitG2tdJDOYzpIwlqi2S8B/FgdL4YqeKsaccczWiY1MZ2
         jE+ir1opweeUohJykXurjr6vZT39mcofcoBXZ1wPfox7QguxlXAGx8xD1AbuJ9+ohEcC
         dSGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=W45/Anm5kjdQ4lfxsCbtGGkxs9RUnNAt7bgKWVLo7P8=;
        b=lPCPz0FaU4NX4//ABPB/zPWY03ZNsSFISnpk6/dIkiwajqQR7FriH0UAIW49zaTrlm
         U1QymUAvp3NV0ENqkXoIu2yEqL1rc+ac7bGfQmxCSpdxVqXg7ZF3j3X2cCux8beg1QG3
         9pBPkgM+PVpbSYSh5yZLKaWQOPxJ+f6Oxt8lbt4+l8h0O+pFfUs3baCkenAwhSp/70/P
         5vvMHjSH1ge93QNQScO/LL8uEt3/9FaombCBqjR0VTB20Jk4e3BB2x/59FlvxQzYi1FI
         ppLE2TYW1kb3VEswGXv50grCZ+9odIjoSxobVfZO2DcMTvTscD1d1Z/n0aygwwMHzPTq
         C7Dw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=NI2m1mTB;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id d9si414446pln.403.2019.03.19.17.15.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Mar 2019 17:15:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=NI2m1mTB;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 44P9RT2k7Zz9sNG;
	Wed, 20 Mar 2019 11:15:17 +1100 (AEDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1553040918;
	bh=le9TbhZDItapW6nvIxpJwzRAc81dmNc+5o3O5xGMAeE=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=NI2m1mTBHRjd7kgvfU1Br2PoLv8Ehp+2MGlCsVwXmPjd5wA1zZQqrnU4elSdYnmkc
	 k/lZk48rLLwdnHlwItgXPwtxPc2e6YOcUnPjTjxscrlvV0mKkOvyWfH4Ow+0J6NfCi
	 /RKcysO0HJu//7TBh27y6+i+r/vFoX5Wk5jdaUYxLiDG+S+qGhFF7CfjLhLOshUY+9
	 0LJ9vDMQ78+7pDVOZ1Toyp8q9GhSooPLER84bIOQ3+Vo73PqPLye/lfp17qkCsYLVE
	 xIAEhmqRpv3GvcxLW79/WZ2wbqdSNYobOG4ykedB+68kvQyoHqt4fua8NUgTofeclz
	 gpdAJwcvOzPYg==
Date: Wed, 20 Mar 2019 11:15:16 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tejun Heo
 <tj@kernel.org>, lizefan@huawei.com, Johannes Weiner <hannes@cmpxchg.org>,
 axboe@kernel.dk, dennis@kernel.org, Dennis Zhou <dennisszhou@gmail.com>,
 Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
 Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet
 <corbet@lwn.net>, cgroups@vger.kernel.org, linux-mm <linux-mm@kvack.org>,
 linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, kernel-team
 <kernel-team@android.com>
Subject: Re: [PATCH v6 1/7] psi: introduce state_mask to represent stalled
 psi states
Message-ID: <20190320111516.6e151efe@canb.auug.org.au>
In-Reply-To: <CAJuCfpFEqv+x2GnSeU_JLQ3ahvfgNVPYyoRAxkDHcvVw-4r=jg@mail.gmail.com>
References: <20190319235619.260832-1-surenb@google.com>
	<20190319235619.260832-2-surenb@google.com>
	<20190320110249.652ec153@canb.auug.org.au>
	<CAJuCfpFEqv+x2GnSeU_JLQ3ahvfgNVPYyoRAxkDHcvVw-4r=jg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/lana8mbTZC3vblqYeUy4oci"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/lana8mbTZC3vblqYeUy4oci
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Suren,

On Tue, 19 Mar 2019 17:06:50 -0700 Suren Baghdasaryan <surenb@google.com> w=
rote:
>
> Sorry about that. This particular patch has not changed since then,
> that's why I kept all the lines there. Please let me know if I should
> remove it and re-post the patchset.

As long as anyone who is going to apply this patch is aware, there is
no need to repost just for that.  In the future, if you are modifying a
patch that you are resubmitting, you should start from the original
patch (not the version that someone else has applied to their git tree
or quilt series).

--=20
Cheers,
Stephen Rothwell

--Sig_/lana8mbTZC3vblqYeUy4oci
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlyRhhQACgkQAVBC80lX
0GxMQAf9HtDOa/glS11zisJgskGjpJIb4d1mRQfZl2A7I1rgPBRgfZIcx8xWTjXG
DTqMbVKmA6JEmwiQw979yPRrTcxMJexn6Tshyb5B65rFgIVUqEbQWKShlGTDoVvU
LQKmkhqW6m6KdTWZiF9LreQyt8HkyUYP250OTr9hREuDhZBAXs422BBw5/Xpf1nR
NlloZtEs3ofcZ79cN9ltoeYu9cF7iR1KAuRbXRJxztsnu7Jm4R5OB+m6tKRugy8t
XNfvMvdwnPrD2Shfnl++ft8MCBj2UCL/ryoeHl8mz2zI/StnZAr07YoQIIeXL1au
bDs6utAh2+KlWgI/Ihrlc2M8DYPmJA==
=ftsv
-----END PGP SIGNATURE-----

--Sig_/lana8mbTZC3vblqYeUy4oci--

