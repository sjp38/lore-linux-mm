Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2615C28D17
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:32:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55C7227A83
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:32:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="aSIFYxHn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55C7227A83
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D4BA6B0008; Mon,  3 Jun 2019 10:32:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 885536B000A; Mon,  3 Jun 2019 10:32:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 773B16B000C; Mon,  3 Jun 2019 10:32:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3EAF96B0008
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 10:32:02 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id b127so13730276pfb.8
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 07:32:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=FshMd3TWrfwZaBFFZ9X+HF6XqStTpiDAO0oydV3/MXg=;
        b=EfmQt1G4lf/V6bTus2KhHN51cXm8jXPAh/2jB5OAnQ4vsTq8P/TWMXus35DsGmsbE0
         jrBdZKpXv4bpDtai8ULdQpaPVkmcjyz9GKqFNGn6h6Uhl9MkFbkUYSSpIYp7xfzocC0g
         Se2BOjBV4uHjg0ZK73hwhJr2toi4hFBj8gS7WftMfHJICDQcCtvQnMRz5SNFfjnvX82Z
         LSngjW4fl6CvAwWFJbbmpPWjCkJ6g4RxJaxHFLwBQfhwD7TcppJVxYctbuaZ9DkasjAa
         +wKdDE2KCk+prctnDEyFPM9dzY33BsDmq/Q8EseyXQRDBe99ZJ5FwSiCDbVmg9TRBubk
         Bmwg==
X-Gm-Message-State: APjAAAX5lK3+hGTBexTeIk6a+C6KDXcFg+TSrvP/gnpFti8MMWgZYNdA
	FCgUd474h2dKQhiGdWjvYefcfeGTnJtCjdkc7WVWfpajGyQeTP4T4+CVWeakuOpnCs8sygPIGar
	kOqMdKbyRmg4XToYqaRy9SO4Os8D4ALlDqPrFJeVE60bylAWEfzSzt5K7b2dbaTdOog==
X-Received: by 2002:a63:f44f:: with SMTP id p15mr28468536pgk.65.1559572321907;
        Mon, 03 Jun 2019 07:32:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwngQ2QUuLcSUKfqjJQXjZMsj8ytWnaMMoNtoBazqZP6+LUpfKizjJq6oPKFvfzE+AmCOD
X-Received: by 2002:a63:f44f:: with SMTP id p15mr28468416pgk.65.1559572320906;
        Mon, 03 Jun 2019 07:32:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559572320; cv=none;
        d=google.com; s=arc-20160816;
        b=L7qx2YyMXkC68h+jQia9lRN5DsAu36GT+Hj0o6b01qe4qC0Y1Vc8dggxNHAssOyQ/d
         v9wSIHPmA1XdjaRj7RIqgjXM+lRh7R9UnPgytD+7ZtDPgRdzAOt4HHlTod5vM9oIN36n
         niy1dAdLAR9i5Ytlc+H7LG8QHk/Zev00fByeZ7PR3pSym5+qaJNWkgbSh4QADUDFOR2K
         u6L0xTBloW5DI+lExJBReli+kfpUWHevfv6j2oljZdgoyjegtS7cmGbGEIG52PUExHRC
         AonE0P+/BxcXHHLGecKKdGqBgt98NvQKe29ov5aSnYcN6MafPw3uG7NoFa38p1F+CPYi
         jd2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=FshMd3TWrfwZaBFFZ9X+HF6XqStTpiDAO0oydV3/MXg=;
        b=W+9TtljnmOb1pgbZJjmvfYeDr0v3vvcKYm6m4UZRqPHH6W9ovPUT2glNN8OqkOch0n
         60i+kVbZ7ycOT5bcwHgVtU2A8ZBp+6Iq3ZbWUSxbSnQW2s+apcJNzFsWPXbhmne4mz8l
         GCCYqNc/RJfT6NNwJkECcrOm6Ww823JRA5ZZUjUYELWYK40HiKpwJQklNf+y4pGYxKmN
         W+CDjcsmB3oRcu4yof5YWPVUysZaXEiNV2R+6MInLEsBc0fSVKEeVPzS4Tdo//Pu3zn6
         +k4w35ZhEvHwJAN7jXdHoxzr74Wuz74FAHEgEyC8l304Q2GFHqdxvNnrQOElVNgA8pud
         dskw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=aSIFYxHn;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id 19si14190422pfi.81.2019.06.03.07.32.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 07:32:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=aSIFYxHn;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45HcvH3K3cz9s7h;
	Tue,  4 Jun 2019 00:31:55 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1559572317;
	bh=9CSpMug+i5yMEa9Kh1285Mi9cdGyu1MghkPju4EXwHk=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=aSIFYxHneOS8/EOrgnuN6HYuL+Kq/SKfwpd5sfHzNxUD5wqS8A5eOJoxCpfkxShsR
	 DIa0BgZF8/jrwFdkNwpuVCqzy/jlmM0/MPUuciMfNvNzwRL8M4rJyiSoXig+eU97Uq
	 /LVxMKvQXiTLuXlhxJrQjkKSlsYQ8QOGqdyarRMTtHm9jtMmdi5J0nm/bpEU9XUtGD
	 cIbztJ3tOY3MOEIzcQ+nznEwe0b9CM6xH42VrTnrHUIoLilVyChzQOcCMZXirU2/m9
	 HU9BONazvVQqhNZ+ggH6uR9xc3GbQh6ZKB6B+J33UQHRaVjeDD5tWbmyDvqmc5uHRl
	 Svamyc6afxd1Q==
Date: Tue, 4 Jun 2019 00:31:53 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Krzysztof Kozlowski <krzk@kernel.org>
Cc: Uladzislau Rezki <urezki@gmail.com>, Andrew Morton
 <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>,
 "linux-samsung-soc@vger.kernel.org" <linux-samsung-soc@vger.kernel.org>,
 linux-kernel@vger.kernel.org, Hillf Danton <hdanton@sina.com>, Thomas
 Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, Andrei Vagin
 <avagin@gmail.com>
Subject: Re: [BUG BISECT] bug mm/vmalloc.c:470 (mm/vmalloc.c: get rid of one
 single unlink_va() when merge)
Message-ID: <20190604003153.76f33dd2@canb.auug.org.au>
In-Reply-To: <CAJKOXPdczUnsaBeXTuutZXCQ70ejDT68xnVm-e+SSdLZi-vyCA@mail.gmail.com>
References: <CAJKOXPcTVpLtSSs=Q0G3fQgXYoVa=kHxWcWXyvS13ie73ByZBw@mail.gmail.com>
	<20190603135939.e2mb7vkxp64qairr@pc636>
	<CAJKOXPdczUnsaBeXTuutZXCQ70ejDT68xnVm-e+SSdLZi-vyCA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/T8JB7vmA6.0wdOso2xn.yrp"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/T8JB7vmA6.0wdOso2xn.yrp
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Krzysztof,

On Mon, 3 Jun 2019 16:10:40 +0200 Krzysztof Kozlowski <krzk@kernel.org> wro=
te:
>
> Indeed it looks like effect of merge conflict resolution or applying.
> When I look at MMOTS, it is the same as yours:
> http://git.cmpxchg.org/cgit.cgi/linux-mmots.git/commit/?id=3Db77b8cce67f2=
46109f9d87417a32cd38f0398f2f
>=20
> However in linux-next it is different.
>=20
> Stephen, any thoughts?

Have you had a look at today's linux-next?  It looks correct in
there.  Andrew updated his patch series over the weekend.

--=20
Cheers,
Stephen Rothwell

--Sig_/T8JB7vmA6.0wdOso2xn.yrp
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlz1L1kACgkQAVBC80lX
0Gy6Nwf/eOmUW6/H8C+yiT3y7MfpDwgD9FP9IuOOQsC1eGfyZ//CGE7jojPjuwCp
827J8ZM8CaEvBsV9iELlKg+w1zy+RrNVDoNQE+l2z8O7MJYW9Tm9u95cdAsLqWwA
oZfzmqKp+5GJ/rYEXm/zRzT9rkR/NnKdUr5WumOp7gUlVhzjQ9KgFQPnhjrIB94Z
Ib+WdHZ9IgaisVD1pA8rWju5wTAq2SyKLKfAL35h18Lj6T0+QZiEx23Je8GiiWtR
30VF4LCZvtL95TjMz8vNDOIEU57lDRSXEGQcM17KHLVLpM3a1VmN6IKYyVTKd21m
0FAZGs8EWDEh4iitzOEbJD0KE6N0jA==
=59/d
-----END PGP SIGNATURE-----

--Sig_/T8JB7vmA6.0wdOso2xn.yrp--

