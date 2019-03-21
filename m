Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F79AC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 21:20:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4AAD218D4
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 21:20:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="CvHMCAHb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4AAD218D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BD8C6B0003; Thu, 21 Mar 2019 17:20:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 447396B0006; Thu, 21 Mar 2019 17:20:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EAD76B0007; Thu, 21 Mar 2019 17:20:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id D9A9F6B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 17:20:54 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id v3so95441pgk.9
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 14:20:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:dkim-signature;
        bh=P6nweyKjbPNRrHuFN0rcQFMXBtF9NIHBGG9PP2cx3gU=;
        b=JYit7/PCqjRFeNsCiYTfqE4PYqovXZypsjRy/OvZIv2GMxDjwTIKUnCjDmKIvMOcyZ
         SM/PLRVeHSzQY1LaTwsloLnO0V7aP+mArXCtyBdhh8zZlDT+43OkxSmAsMiJ2QxBKYg4
         CgdUdYXKkm0yUDJHRC2i+IS8F4SO1wh79p/5qZ313HCFCfeE4tydekLRa8mLIBtTGHYe
         pxUCwRri32OXqlj4+rFZfuaSRDTGA7WvsRWum91YLFUsrwa4SbBMq76knmPv6gMe/4SA
         pzrkNp/6bGmZyGmsOZ2EjA3hb9YdtgZvQY6yB6OPNrCq8C2UOQN/elMSSGMfyGatMj0i
         WH1Q==
X-Gm-Message-State: APjAAAXc5PrvdMQv3qNR+5N+LswZTWzw7GIL8qf2Nf9/REBe9ZBpm2IC
	M7XCllc/DOq8aQhMC4N9ohgaKbzuhP+o73RtRQkL3IMV8n6LID3ay9XSzpZ66QB/Vi3Al4ZsQnd
	cplLOZ5gflau/yieUNcZuI7XvaKJEsLej0DkI//T603PxJT7cJDGOsMYo2JfHh5grjA==
X-Received: by 2002:a63:d848:: with SMTP id k8mr4379488pgj.396.1553203254343;
        Thu, 21 Mar 2019 14:20:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzPSC5/Lfeh227XCUffvFJPft+LKUVOvhsgcYdyOkxnDFpF7JB+r3PDm06iNtq+W4u4daiR
X-Received: by 2002:a63:d848:: with SMTP id k8mr4379421pgj.396.1553203253483;
        Thu, 21 Mar 2019 14:20:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553203253; cv=none;
        d=google.com; s=arc-20160816;
        b=KMESPh2ybNAZuUT1tECvp/1md3JY7wqF4/hAkgr69XVTvvSlzIsY60jAbiY0wcmwUA
         oRHhjbK1iAB6EcbA/0+3XKL+Ylx/JbBN1/KwzDahEukuI5FXjbZO7LvlWvXAdhcoz+jQ
         1f4TsNOFb6bU1hKmQbUha8X/33lTTG0Odb0i8JxU5Q227JXyOPC5zrZvitV8pTA+t3MM
         KSsYKpGn5L4Ar64a9cxGEkHxkmTi6ouR0C8ExTqN//r2wjO8dCmvsb+2cKP8ySzXzOav
         h31Dl1WIo7VJOiIMnyqt5DUM9o5PDqbBeTO1PJICYBKSjfRwU3rxZENzIfg7BwvTmNel
         /7xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from;
        bh=P6nweyKjbPNRrHuFN0rcQFMXBtF9NIHBGG9PP2cx3gU=;
        b=x0LFMIow3cjHEt+qnBRoWN1ROkoeq1la/eWYjZdYvzG0xiOxw3AaJzOtQA4PB/EDB/
         MoQ2EWNGHZ8gBGV3/tcykGQRMv9680lgwzlSp/mm7xuA94QH4IfDp0CHkmzqe8Tytbyf
         f4u/cAdChBvkH1OpQHMmXf8wonRNnQRU12Um1sosLhsX4oUoM8oSvCXbKiMvQKthdohs
         /+FzYxMR5HCi+zY+Be0EQDGfJwkJ0Lw+aiXUkpDxNiPqESxNXsw5/8d5IV5FhHzUIVHG
         3qKAvEJjUIDRBvIu5L+C9k9X7fPVzBLHYY2bqTWpmI/ujSyHz/p282s+spoeEFLWjFbw
         V9Tw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=CvHMCAHb;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 3si5702711plf.250.2019.03.21.14.20.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 14:20:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=CvHMCAHb;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9400330001>; Thu, 21 Mar 2019 14:20:51 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 21 Mar 2019 14:20:52 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 21 Mar 2019 14:20:52 -0700
Received: from [10.2.161.82] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 21 Mar
 2019 21:20:52 +0000
From: Zi Yan <ziy@nvidia.com>
To: Keith Busch <keith.busch@intel.com>
CC: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
	<linux-nvdimm@lists.01.org>, Dave Hansen <dave.hansen@intel.com>, Dan
 Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov"
	<kirill@shutemov.name>, John Hubbard <jhubbard@nvidia.com>, Michal Hocko
	<mhocko@suse.com>, David Nellans <dnellans@nvidia.com>
Subject: Re: [PATCH 0/5] Page demotion for memory reclaim
Date: Thu, 21 Mar 2019 14:20:51 -0700
X-Mailer: MailMate (1.12.4r5614)
Message-ID: <5B5EFBC2-2979-4B9F-A43A-1A14F16ACCE1@nvidia.com>
In-Reply-To: <20190321200157.29678-1-keith.busch@intel.com>
References: <20190321200157.29678-1-keith.busch@intel.com>
MIME-Version: 1.0
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: multipart/signed;
	boundary="=_MailMate_64525BCB-86AC-4202-8D74-2FF72494C4AB_=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553203251; bh=P6nweyKjbPNRrHuFN0rcQFMXBtF9NIHBGG9PP2cx3gU=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type;
	b=CvHMCAHb62LnWhXYaTKpIzZ/8/u5hF9yqCeAjmJyfMMVl7GIJFMWQFiBM6fNonSzy
	 x0EZcfLfo9VxMuTzYfXd//0+SQKpUHOPNN5y4VnGtpMkG+VIxCLfUpsSnFgo2WS43W
	 NIG+SX1L/NPoMoKZKMybvacOhDPrC6VmTMnyDYeaFG7/Svs4gvnbPTksyuLJdyvOti
	 l/UPviM7V/RLqaPtk0vN58Ck2XWrtqNmqIBCl/3A9U/oEG2OprSTnOn5Y4UlXakkqq
	 1HrfxlQaUWJknjTmA67/CYma9htlCXfc/H/Lp1ggGJavdjx3ko/Wq7/IpPHR3SISF+
	 ISTSP1ebZpdIA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--=_MailMate_64525BCB-86AC-4202-8D74-2FF72494C4AB_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 21 Mar 2019, at 13:01, Keith Busch wrote:

> The kernel has recently added support for using persistent memory as
> normal RAM:
>
>   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/co=
mmit/?id=3Dc221c0b0308fd01d9fb33a16f64d2fd95f8830a4
>
> The persistent memory is hot added to nodes separate from other memory
> types, which makes it convenient to make node based memory policies.
>
> When persistent memory provides a larger and cheaper address space, but=

> with slower access characteristics than system RAM, we'd like the kerne=
l
> to make use of these memory-only nodes as a migration tier for pages
> that would normally be discared during memory reclaim. This is faster
> than doing IO for swap or page cache, and makes better utilization of
> available physical address space.
>
> The feature is not enabled by default. The user must opt-in to kernel
> managed page migration by defining the demotion path. In the future,
> we may want to have the kernel automatically create this based on
> heterogeneous memory attributes and CPU locality.
>

Cc more people here.

Thank you for the patchset. This is definitely useful when we have larger=
 PMEM
backing existing DRAM. I have several questions:

1. The name of =E2=80=9Cpage demotion=E2=80=9D seems confusing to me, sin=
ce I thought it was about large pages
demote to small pages as opposite to promoting small pages to THPs. Am I =
the only
one here?

2. For the demotion path, a common case would be from high-performance me=
mory, like HBM
or Multi-Channel DRAM, to DRAM, then to PMEM, and finally to disks, right=
? More general
case for demotion path would be derived from the memory performance descr=
iption from HMAT[1],
right? Do you have any algorithm to form such a path from HMAT?

3. Do you have a plan for promoting pages from lower-level memory to high=
er-level memory,
like from PMEM to DRAM? Will this one-way demotion make all pages sink to=
 PMEM and disk?

4. In your patch 3, you created a new method migrate_demote_mapping() to =
migrate pages to
other memory node, is there any problem of reusing existing migrate_pages=
() interface?

5. In addition, you only migrate base pages, is there any performance con=
cern on migrating THPs?
Is it too costly to migrate THPs?

Thanks.


[1] https://lwn.net/Articles/724562/

--
Best Regards,
Yan Zi

--=_MailMate_64525BCB-86AC-4202-8D74-2FF72494C4AB_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQJDBAEBAgAtFiEEh7yFAW3gwjwQ4C9anbJR82th+ooFAlyUADMPHHppeUBudmlk
aWEuY29tAAoJEJ2yUfNrYfqKSFgQALRovEKyG0/MfQCHU7h0VuN+Y1Ed/08d75x8
EToYq9az+/ecbuxikO5CcMDAa7Llw6BpMkeRaldPARrXIPj3tXeJeHgwLFO6C1Wg
CC4oSM2XsZYoZ1JDwXeTDKIcO1OWCnANPHh3IbjdfcOKF8Z465sxaC70U9OCbzEb
K/Tky+mUMBqokj40A7cTq72FLcOTcrXpyXMJqoWrl188E4bTiQs87FzSaN2wIKNr
XP4MJCJR5cWcS0B1rLKfBTP/gZCWmOO6vCO9uxi/IH4QddfC8u8zZsIqzDQ3hc45
37iYKoWMxSpqeynoz0elvjFYQB5QaXEsmzKXrpDbuiHyaaB25QPl0KbbVTllQJdH
7DNe/zE2gS5MQl16r3DkHDssAZPu48vTgQNlVciDmzeEB4KURuZf/ItrGGXGfdDN
3xScDxR4+fAJ3GzDRyG9M/CwsxbCgHl3fA60/ohO/Yyg0q1E42DWyMTammRikR7z
4xI+r/jBXQMoiDrZ8DpU44QzRyWQugCJV2sX7BqtHpSxiMwlY7VR6g9PNn5bfHi9
9hlI0k3xlEhLvF8voePfAY4iKhSpT5tNkNiwCJwikGByT+IJEAZW3+ESAYmv5U69
dEZBjMSUbPS2uEVTEByjWw40FbuLWUh+7U3wloXwvKpfqQJby1RBl5gEKKIi8xBu
PZ6qi/3K
=WKXP
-----END PGP SIGNATURE-----

--=_MailMate_64525BCB-86AC-4202-8D74-2FF72494C4AB_=--

