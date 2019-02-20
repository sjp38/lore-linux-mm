Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFBD0C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 17:00:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9134C21841
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 17:00:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9134C21841
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10DE18E0027; Wed, 20 Feb 2019 12:00:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BE008E0002; Wed, 20 Feb 2019 12:00:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F157E8E0027; Wed, 20 Feb 2019 12:00:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id C927A8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 12:00:47 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id e31so23375174qtb.22
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 09:00:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version:sender;
        bh=LwXRfDuo15K8qnCiLIZaBV4WJKRU5+s0C24FPa41FZY=;
        b=lr24ZCi6nhGYP6wftAi3trXs+XvMQc8y5qNgRNtlkiI3qb7BJ3JUMmvzc6pRue+q3n
         4wtdwh4DjVaGQzxHiTWU5pUPDiVY4Akgx6jD/XpA2ojiWqNL54rZM48BLDAz6XXHRhaH
         8yPnlpsTdtinCcWcnZMg0a5+aUmoUxbSZGV3Hw0XQsHryK31u9j0855cabewTvxfu4K6
         2M539/WY8Oa2RxUVzYOpL/kVqxYlneODOqc+9XqOLcVHttc5IzbHeITgJrAUOVLlMbrQ
         YGNihb1G2geQfuyMXk8Em0dP1gOJran6bHqvg3OJ9gkL8e8kNINn80eUbxRImw2aKvK1
         y71g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: AHQUAub9IB8f4HtpIhGzqlbdbRGalTJClevbZe6bcKNo32ZOrIw3L/LO
	XxVYV142NMkznZdRgeShh4eAvqZCe2YyVPewL1Y+pOwbAgqUCVfG0V1y/R2vYAJV55Gh8tZ9ynZ
	otHkppkTyunLYhR1Tj+nq/io9k9jix40nVb5Ga8/1HXQEgx4pY0YbQopfZoySNbWB9A==
X-Received: by 2002:a0c:91bb:: with SMTP id n56mr27136185qvn.77.1550682047518;
        Wed, 20 Feb 2019 09:00:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbBsiQrJzWkDvSQNJUtrm4PKzv+RQrMHz9obauHxGse+KsN3jSvhltXz4hhScAVUAmbHaGC
X-Received: by 2002:a0c:91bb:: with SMTP id n56mr27136073qvn.77.1550682046106;
        Wed, 20 Feb 2019 09:00:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550682046; cv=none;
        d=google.com; s=arc-20160816;
        b=vQ46TGAfCQtfspkIouV/S/dSdPF+Xt+ILHGe7ujRzIL71MU1mFvjBD1FhN448L3qus
         htDW2U8aGtYTek9jp2C4idKnm+MCf/4MIqTzSf1nczy1tOMGeHBiLAhtLPcvUbGK+/UQ
         wz/3bUe83E56aAWAlAbIaPYVkOlOlDKDEXkQ4cjwDlXC6SEGDEMRw3Fh7fCN4kCZdVk1
         P45kXGkqsLFRmEMpR9ZwcPSirkYpiFSHRmV+4i8K706kxE/vOXwQ48PbJNfaMyOh/Qld
         8mC5+UKomVj2INY8HqnKl5UsWra/Hshy2XjKODW4O3dYgdcpGscAvhoMtD29MH8x2v8u
         w5jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:references:in-reply-to:date:cc:to:from:subject
         :message-id;
        bh=LwXRfDuo15K8qnCiLIZaBV4WJKRU5+s0C24FPa41FZY=;
        b=lXRLBtwdqD1bHD7clhS/EzgjJ/YcOczeq8Hf5oSgt9Vtl6yfneruYLhf0yjuOv7Bk8
         Pb9LubyY6HokJZn/yl08XWHxmVM2v8y5Zsi1C+3Of+Nm/PMOjtmBi1Huhg4JPFw0FWIB
         cFeF5CLZEjJ+TM3imk1mJqCrBZTcYWOsvhujJg6gQG0/DzZTzmHOz/CKtt0wf0sc8Cqp
         g5I1LLOehTQ2homvO6uNZndmHWzkli16OgvdNPZR/V654ZBypZ4c69VpQYxJ/CYxFvYW
         /S3CmJ8ENvosyDndONtabmgllbVYFCNjHSbczkwTTe/c9lpz7T26w4G70dln3/lzUY4J
         xaMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id k11si1746472qtj.404.2019.02.20.09.00.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 09:00:45 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.91)
	(envelope-from <riel@shelob.surriel.com>)
	id 1gwVEN-0006wA-G5; Wed, 20 Feb 2019 12:00:23 -0500
Message-ID: <9d07c396baa10008bd605f032ca46c8e48f78644.camel@surriel.com>
Subject: Re: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
From: Rik van Riel <riel@surriel.com>
To: Dave Chinner <dchinner@redhat.com>
Cc: Roman Gushchin <guro@fb.com>, "lsf-pc@lists.linux-foundation.org"
 <lsf-pc@lists.linux-foundation.org>, "linux-mm@kvack.org"
 <linux-mm@kvack.org>,  "mhocko@kernel.org" <mhocko@kernel.org>,
 "guroan@gmail.com" <guroan@gmail.com>, Kernel Team <Kernel-team@fb.com>,
 "hannes@cmpxchg.org" <hannes@cmpxchg.org>
Date: Wed, 20 Feb 2019 12:00:23 -0500
In-Reply-To: <20190220043332.GA31397@rh>
References: <20190219003140.GA5660@castle.DHCP.thefacebook.com>
	 <20190219020448.GY31397@rh>
	 <7f66dd5242ab4d305f43d85de1a8e514fc47c492.camel@surriel.com>
	 <20190219232627.GZ31397@rh>
	 <9446a6a8a6d60cf5727d348d34969ba1e67e1c58.camel@surriel.com>
	 <20190220043332.GA31397@rh>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-2Dfk45/APovBQW1o7Ntt"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-2Dfk45/APovBQW1o7Ntt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2019-02-20 at 15:33 +1100, Dave Chinner wrote:
> On Tue, Feb 19, 2019 at 09:06:07PM -0500, Rik van Riel wrote:
> >=20
> > You are overlooking the fact that an inode loaded
> > into memory by one cgroup (which is getting torn
> > down) may be in active use by processes in other
> > cgroups.
>=20
> No I am not. I am fully aware of this problem (have been since memcg
> day one because of the list_lru tracking issues Glauba and I had to
> sort out when we first realised shared inodes could occur). Sharing
> inodes across cgroups also causes "complexity" in things like cgroup
> writeback control (which cgroup dirty list tracks and does writeback
> of shared inodes?) and so on. Shared inodes across cgroups are
> considered the exception rather than the rule, and they are treated
> in many places with algorithms that assert "this is rare, if it's
> common we're going to be in trouble"....

It is extremely common to have files used from
multiple cgroups. For example:
- The main workload generates a log file, which
  is parsed from a (lower priority) system cgroup.
- A backup program reads files that are also accessed
  by the main workload.
- Systemd restarts a program that runs in a cgroup,
  into a new cgroup. This ends up touching many/most of=20
  the same files that were in use in the old instance=20
  of the program, running in the old cgroup.

With cgroup use being largely automated, instead of
set up manually, it is becoming more and more common
to see systems where dozens of cgroups are created
and torn down daily.

--=20
All Rights Reversed.

--=-2Dfk45/APovBQW1o7Ntt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAlxth6cACgkQznnekoTE
3oP1QAf/bTjVaiVq2C3AoaDrYoo6OXegcS2D8aHtHYN55wai1grITZkXEYUz0P4/
lZAqiBuC3Rq3FSbtBBNyd5+NcboOhKMYKAyADlk0swYAv6y+6/16RBjHu0NodNKt
YH0QrkvAeLWW0vh0RhuY2WM1NY5olrVZHJVt7820Yv92nVLKlA1LG9Kx9WWOBkRr
BY+NB0So3yiqpLHlqe6/mOVeX0Su8hMoMByjB8CxjtPwRI79jCnxzH+Dz4dlrWDb
jiovbALo+E9upsuz11xP53kixQjx5ttLAVfaHrgZ0mstwXSc16EDvM629pH3dsrw
IFMXW1JQ0VajV83ZTF9ys5JvR5+3Bw==
=fL6T
-----END PGP SIGNATURE-----

--=-2Dfk45/APovBQW1o7Ntt--

