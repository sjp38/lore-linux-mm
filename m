Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B385C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:02:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44D4B217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:02:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="JLB0DUS0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44D4B217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D55DE6B0003; Tue, 19 Mar 2019 20:02:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D04816B0007; Tue, 19 Mar 2019 20:02:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB3E76B0003; Tue, 19 Mar 2019 20:02:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 76C916B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 20:02:57 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id z1so595481pfz.8
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 17:02:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=8Uu1TNoF40X1KnQ+5j4CLL3Vv773lLmVGEnNhVJUE1s=;
        b=bcQZgp/22DfP5iL2IsFsb7C0VQMVBj9BkXk1NSQaDz4GtNjz41SDrKGoFs1ZiJfdjF
         51qPxw7az21JwZwefI6I6VWfdVIpjzsuvjC944KeQhPXd8I9OtDZDv4Mn9hurmfC3cPv
         vWLsuPk6CT5/XEivnvlZIDPUJhlOaZ+RFchV7h7YSXAeZl/B1Xy9MSE7p19DLNJn5T6x
         2miZjol5G6zwThO4k21rtPXkI3XPewwEcaJ6+8dN/SkAdmLFTQh4W30IZqFeXZwstkgK
         LaltZzTsVrhOnC4tgHSRRK+kKFAiCXBFOpuPqt4fIkBKCcOUxNwkKNOYivSENEuXcRbf
         MWug==
X-Gm-Message-State: APjAAAXMQusPrNfR5xl1JmJZXhI485VGvFZDzv7wxoIkc3/5uZXynjpg
	AUP1Cmz4AOdsvYlTypsM5YsmYgGZbjxDoumgQ7qvaTm0H2F9wBpGVYgzX4pGsRMi0sRbdl6vYJx
	5jvbQspqaZ0QA2Ca4wlhrjFSOdrG0/O26JkPYglGnzva129PY3Q3wyHo9arwQR9NbpA==
X-Received: by 2002:a62:4299:: with SMTP id h25mr4599520pfd.165.1553040177076;
        Tue, 19 Mar 2019 17:02:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxF2HSQOi+ZRdxbl5wpbwnc+zZ3/KorhYicpjDhBelt1RF0JLLcGoaDqAJRwcEZuQjUiQSZ
X-Received: by 2002:a62:4299:: with SMTP id h25mr4599450pfd.165.1553040176164;
        Tue, 19 Mar 2019 17:02:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553040176; cv=none;
        d=google.com; s=arc-20160816;
        b=IK+L8evNRRzVnBZQ9XM+ECghE3NxGZtJBgAka6ob0D+ztZXaEPGpr2cpIFYtKZJeMW
         sKmJI8Qsl+vT7mSYm2otJCnJEXWIYnMtW04qocEOtd2iFwk5/9+fd/1xzqurjyrK7GWu
         KLt5hW//nHSIR2nnyYlQL99XPzms/ve1uOIH6+IqhA8Sslk5iyKM49Vq4opV+2oAImco
         HQV0UK4MR1JM8olpOiGg7+TeC03hXj1riFPo5RjPEs2LaaXtWnjBw6Sbi9WRX9aeeF5q
         cCAevsPJ5409fQpaFlCBs2PW31MrKyY1f5y/xbeiQjYdzqgKolYFwF1QZ0SetQ/vXuUs
         rDtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=8Uu1TNoF40X1KnQ+5j4CLL3Vv773lLmVGEnNhVJUE1s=;
        b=l+z4Ef6R8ZdIs1W5QKGiiBDwENHsnwckGKgQu2St9FpoEP+EpuTKDtvDP9mJDCdofO
         /Jw/Oin8/SxRaAI0GTMU2ySnqDpxB96SptDHEuwXPKS/HudJPKnC6iu4roCE6RJ+4B/Q
         DWMtLRMHm3QnuwDq8obBwyeVM4HysALSl7J9grNyNXoBK8G2wNz9UqQklP9/NM2YYIi0
         93QlAYcS8ku6HH2n8nPzuv/0ilXWYOK66ieBxl+wPsb6J9Sw6bdFzkAkbm40nXDQS+Pi
         l/iU8t9MWFyErxeWwsmtYakHmo3NmBDphlZLIxTYro2otdukAUQdyDOGMTwklTTs7heq
         UWeA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=JLB0DUS0;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id r10si365873plo.268.2019.03.19.17.02.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Mar 2019 17:02:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=JLB0DUS0;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 203.11.71.1 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 44P9956DWbz9sNH;
	Wed, 20 Mar 2019 11:02:49 +1100 (AEDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1553040173;
	bh=jehP9+YT/rAivcVGOfJHVCT+k92Lsz+iBSFzJvUFN/Q=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=JLB0DUS0XtDVE1T2hGU9fOTTCcPEXNuudOsbOY2P9sBGeACPjFJRvurNz1hv4BTSL
	 Uj82m2Jd+FuuKJMmj+QHXF1gWDmATsDVYcAtzs+qR0XwLQ7PLGXIaxqNn1NGnLhGtU
	 SWFMStDnDHgKbyDYvxMsk4xN9fvPXeGjjhHh/2qb6EX9OAlunS/yB0Gj0yKZNiS7eB
	 Ji6GENiI1GQiY99aHr8fMba7nmuJJS69cm3KIQr06PwOXRP3jgZXXu/iizdctQzwjW
	 CfvEvUzSKGAY8LL3tviwU3qjkIRgkE3bl942ktLdOx4jUYd1r5auLSOEIDwr1nWqfA
	 yXNHtkm/V8GwA==
Date: Wed, 20 Mar 2019 11:02:49 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Suren Baghdasaryan <surenb@google.com>
Cc: gregkh@linuxfoundation.org, tj@kernel.org, lizefan@huawei.com,
 hannes@cmpxchg.org, axboe@kernel.dk, dennis@kernel.org,
 dennisszhou@gmail.com, mingo@redhat.com, peterz@infradead.org,
 akpm@linux-foundation.org, corbet@lwn.net, cgroups@vger.kernel.org,
 linux-mm@kvack.org, linux-doc@vger.kernel.org,
 linux-kernel@vger.kernel.org, kernel-team@android.com
Subject: Re: [PATCH v6 1/7] psi: introduce state_mask to represent stalled
 psi states
Message-ID: <20190320110249.652ec153@canb.auug.org.au>
In-Reply-To: <20190319235619.260832-2-surenb@google.com>
References: <20190319235619.260832-1-surenb@google.com>
	<20190319235619.260832-2-surenb@google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/gcf3x9pNF4bWcL9pBwUmVyY"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/gcf3x9pNF4bWcL9pBwUmVyY
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Suren,

On Tue, 19 Mar 2019 16:56:13 -0700 Suren Baghdasaryan <surenb@google.com> w=
rote:
>
> The psi monitoring patches will need to determine the same states as
> record_times().  To avoid calculating them twice, maintain a state mask
> that can be consulted cheaply.  Do this in a separate patch to keep the
> churn in the main feature patch at a minimum.
>=20
> This adds 4-byte state_mask member into psi_group_cpu struct which results
> in its first cacheline-aligned part becoming 52 bytes long.  Add explicit
> values to enumeration element counters that affect psi_group_cpu struct
> size.
>=20
> Link: http://lkml.kernel.org/r/20190124211518.244221-4-surenb@google.com
> Signed-off-by: Suren Baghdasaryan <surenb@google.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Dennis Zhou <dennis@kernel.org>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Li Zefan <lizefan@huawei.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Tejun Heo <tj@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

This last SOB line should not be here ... it is only there on the
original patch because I import Andrew's quilt series into linux-next.

--=20
Cheers,
Stephen Rothwell

--Sig_/gcf3x9pNF4bWcL9pBwUmVyY
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlyRgykACgkQAVBC80lX
0GzGdwgAkeERrC49NHtT6/Phx/CoT0fGnk18tNUFLom+rq3rOBQK2wx1PjucbibK
vXCE9EjVXmM1DNhVakECzW140fJtlo/sepGVTJhmSOUsMbOF1OI5PrAvszpgSjSU
5UF7ikasO20gSNsechnFvkJo4NA5zx/se85Mr62VKU8UgfAUcY3DQwATE6EJiQOY
vuaHEsGdYYpgctzrz9buJn2eXKSqatWwteCeyQj2UDsfXz63CCJxlQrO4p96B//c
wjfoSNMnOa25s418YxLiRmLA/9Upk9CMWPzQ7J6v3/TVGUNLvjZPRd1qBUE2za6g
xvo9LR9TcLA3X/p682Ykd4lk+ccBZA==
=KZbq
-----END PGP SIGNATURE-----

--Sig_/gcf3x9pNF4bWcL9pBwUmVyY--

