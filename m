Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5318C48BD9
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 13:18:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71BD6208CB
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 13:18:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71BD6208CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17BBC8E000E; Thu, 27 Jun 2019 09:18:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12BB78E0002; Thu, 27 Jun 2019 09:18:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0419C8E000E; Thu, 27 Jun 2019 09:18:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id D64188E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 09:18:44 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id k31so2335239qte.13
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 06:18:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:sender;
        bh=Sa5PVO7TcYptMQVHIYjD2C29YDrST7pQ/fPpLfEiaaU=;
        b=mVs+Is5kfb4WR9Skx46LFU4hswCzQ9hNXSbAK6N3KHtgo/uA46lgsCKFcLk8fWBZAL
         NCei/jgq9uuCJhbhAEkSrjVYXpfSWV9txcXq5MaghSNI4Ckz//Di9HTuEMdEGfDLeS2B
         3vpMjeFP7OWDHUFNZzV6SDaLN/teZtZERwokGUbwe0jQVG7qjm6iLsqssfNNKfggU3Hf
         yB/HnyN10qJJPU/MCe6jp7s8GVRWQ5M64tzv7n3SfmrhFkYHgHtpXHilrVI8C7KvtPfi
         78VsXwxGoOyxefoWH7AxQuvNINWRIwFgcazz4gzmhUrqEAlI4wD+EvpE04uRPZjX8tgS
         wVUg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: APjAAAWMFDFMiLpU2Id+sFUFobgXQsqQ2DRF5htwrmUPyNeaWVhI7thV
	bAeNOTqsiasFVUmMK6jwzoYILMPiCxK8l6rdzournIuYDPsMcxDQ2BFs6KOYwN8FFxJD+aRWzGi
	y0fFX2zMnjzBF7fulq+7Yvvi73cQasUaI+ndcuVqDGCxBGeRlD2JQzOUwfXe6gRYwrA==
X-Received: by 2002:ac8:431e:: with SMTP id z30mr3074635qtm.291.1561641524662;
        Thu, 27 Jun 2019 06:18:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzL7NR4VfjwwRL0CxLxhAtjRV2Zoh0UI/BOJvXPUWp0wjijZKbmKiWLzNYVdWIXVwxq8Hz0
X-Received: by 2002:ac8:431e:: with SMTP id z30mr3074573qtm.291.1561641524002;
        Thu, 27 Jun 2019 06:18:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561641523; cv=none;
        d=google.com; s=arc-20160816;
        b=qryXnvOb4hXW9qCwAAsRI4dXC/labV1IDGlSsAhKun3ZqVrEJBRwBw8vkODlxcUfEx
         uwc9GgPfI0i610xMDcRxC06oc13phpAL/H0MCGBF0QmrSfddNlTMOa0wT+hxhdnVQX6O
         NWw0VSDM1W7sz2PLEJ+jt25pWi+zw4nQkLiruvb4nd6mJurRHtMJJqwOpUoqJwkG0Ka6
         GJ5VgXfA7q14/UTF6pgeqQx+NIWwH5m01CYQ9JE55b6Wxgb+S2W64d3KwvQx/hpJFALM
         0eaCgbOjbe6/HX4DbxgSdkeWu/t3ats6A1mTDxEo/oUd3mbXOR1RR2penr+YU+je7dc8
         jNTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:user-agent:references:in-reply-to:date:cc:to
         :from:subject:message-id;
        bh=Sa5PVO7TcYptMQVHIYjD2C29YDrST7pQ/fPpLfEiaaU=;
        b=VJ8fFgLY8+WhNYRGbMNx6eGpYIx99MB/vfKHZYE1lhitw9RDhpPV/+BX8VDqhgJgRk
         j2j7NDKRfka1b76rg1ZOqP3MyTcs+g30UB1N9s99w/3sjlh8yf7NTifHseIeAAbg2hTf
         o6wGQlP1q5/gEcjvXQucKB2YrOjqeTqGTA2h0dIy/SW7aYa7LcVxl6L7IDMwQ78QQlCO
         FRicDm0JHLxWksWIp/qohbU3P2lB9B+rCviApeFO3/DVQH8OefFpXlDRgNfp4xASATZi
         Ycat4AZkJRWXxLrrMoa6rNDqL9gDHjRQ0TnPmD8kqHKMO6/WxI96N+LoW/xIMr9LtjII
         A+tQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id k39si1634226qvk.128.2019.06.27.06.18.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 06:18:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.92)
	(envelope-from <riel@shelob.surriel.com>)
	id 1hgUIO-0006Ad-1j; Thu, 27 Jun 2019 09:18:36 -0400
Message-ID: <8026a0341c83ceee69d04cbe55f1e0fa3d6cb610.camel@surriel.com>
Subject: Re: [PATCH v9 6/6] mm,thp: avoid writes to file with THP in
 pagecache
From: Rik van Riel <riel@surriel.com>
To: Song Liu <songliubraving@fb.com>, linux-mm@kvack.org, 
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: matthew.wilcox@oracle.com, kirill.shutemov@linux.intel.com, 
 kernel-team@fb.com, william.kucharski@oracle.com,
 akpm@linux-foundation.org,  hdanton@sina.com
Date: Thu, 27 Jun 2019 09:18:35 -0400
In-Reply-To: <20190625001246.685563-7-songliubraving@fb.com>
References: <20190625001246.685563-1-songliubraving@fb.com>
	 <20190625001246.685563-7-songliubraving@fb.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-WfH5iiK7XcqIOQRh+gpO"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-WfH5iiK7XcqIOQRh+gpO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2019-06-24 at 17:12 -0700, Song Liu wrote:
> In previous patch, an application could put part of its text section
> in
> THP via madvise(). These THPs will be protected from writes when the
> application is still running (TXTBSY). However, after the application
> exits, the file is available for writes.
>=20
> This patch avoids writes to file THP by dropping page cache for the
> file
> when the file is open for write. A new counter nr_thps is added to
> struct
> address_space. In do_last(), if the file is open for write and
> nr_thps
> is non-zero, we drop page cache for the whole file.
>=20
> Reported-by: kbuild test robot <lkp@intel.com>
> Signed-off-by: Song Liu <songliubraving@fb.com>

Acked-by: Rik van Riel <riel@surriel.com>

--=20
All Rights Reversed.

--=-WfH5iiK7XcqIOQRh+gpO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAl0UwisACgkQznnekoTE
3oNDZAgAhCigDJCHSHlL1abXwMFGGvkGQl64ICm1ia7nRSP9ppL9746ikxugPxnz
oCURzm/HvLsSaR6w5Orpm9e/su04mjAOdax5Ab1+ZyVTAzRTY7353e12znTqSLBL
p4ABWVBJ8LRquZvHJCD3XMUMtkyrfiA4pm10cP5irPZI7BEnmnpSR3FxhXOLJOxg
DVvD5fo/0JRBgh18pLOaw1BdZXW4MlbRrnsEmkCr+cHP/oViU6S0LwKKnandYKoh
y2s8zhUH4+aPl0lLLy3irNfXkXzPfnPDzBtwFaboLO/iUI1+bTrd8nax43O1pTxV
AoHIzhfHDW7cPSs7GDBgvNa9PTgohw==
=trnf
-----END PGP SIGNATURE-----

--=-WfH5iiK7XcqIOQRh+gpO--

