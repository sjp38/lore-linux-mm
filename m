Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F5E0C48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 13:19:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40F742084B
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 13:19:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40F742084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEC118E000F; Thu, 27 Jun 2019 09:19:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C75B18E0002; Thu, 27 Jun 2019 09:19:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B65A88E000F; Thu, 27 Jun 2019 09:19:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 93D1E8E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 09:19:14 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id c1so2340253qkl.7
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 06:19:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:sender;
        bh=YKuH8UXrOfSMaSfMQKy7ub3ETqWKthFhz8Zb4LW7d9M=;
        b=RztrxpMpJkyemDq5FGD+l86hMfPrLzKgszS+UfkuRyNzWDsnpVGnT2NXMWdOSv++9+
         SzlbJRRwjWRn9t6x8Xg9ds43d7D7QBRViPK0r3kC96vlTl1/yvwg0CcYuGABuA412q//
         7ad6newUnTTt9tSvDzjzstk0wcVBiwUKHqjdIB2Ph73QuSW5qOZABeiF+MYODeHf0g3F
         q9KWi+w6U+zu29sT2w4BrfARjEzGiA5DI90xEhCJjeaOnTLKkAe11WDTKn5T8cRF0VhE
         Cjtva441lFh4Kum9M2DujG3iK0m77NuCJZACwSxoOuzXTqpn/l+LytexNOM2umbqK9hN
         1BOQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: APjAAAVDY/IZB1XQT0e6c9Ds16tQKeJlyBrxv2NMZeljWGk3tFZ+c7Qn
	3PwZ2gM1YBigAkBxmnJDYcNlRGVznT1TYmEvo3tMGHHE1yiq+sW5P5qiJXbiWwL9xvX2RSnBMKp
	pwbuWDp190gfaZXYZWk8+0Ic67OsflFzVIexsax+81bOjawqR2CS4ByjtBiXqM45TgA==
X-Received: by 2002:ac8:4a10:: with SMTP id x16mr3083919qtq.282.1561641554396;
        Thu, 27 Jun 2019 06:19:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPlH4bfbRTvlPYEcgpgVElYCROZQswTo5Bh1EJRw4EgEtCskMlX9QJJgqZRwiavvUt6XW3
X-Received: by 2002:ac8:4a10:: with SMTP id x16mr3083886qtq.282.1561641553943;
        Thu, 27 Jun 2019 06:19:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561641553; cv=none;
        d=google.com; s=arc-20160816;
        b=jT80Zc8txfP7HGJTLLiVM3+00nODbGrqeUV3uekGx+SPqnmZyDnn9xGkFXV6Db6F30
         ZqzJRmpR0cKp/oOxDnXE+cPKOpjQspptFMP0hM1atIHEbFWrE8koQ3y3UKliLxliQkFV
         dG91rpQESksXyxFFYp/OC8aUDW3gUo5l2q2nUBa0XsWhsYv8btBhsMnUHJ5eCMzwYWgY
         ceCSaF2GoSa+S11BHT2cWj7TJaATbSOZQbs29huPi8jpuEyhE8qbVc6datReh5yJXPMG
         94YLwF751NsycO/a9p7VgNHrOTZ2RF8OX0BykjCbetTAm9qEoYZJJ+pjgUEIdUw36+4p
         lUDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:user-agent:references:in-reply-to:date:cc:to
         :from:subject:message-id;
        bh=YKuH8UXrOfSMaSfMQKy7ub3ETqWKthFhz8Zb4LW7d9M=;
        b=ZWN+JQpFdw14NHKD0PNYoIq8swlWTLAIE3s+exx5NdWLw3IgnNbA86ICyCmIg0cm2b
         7VEpZEi+S8SD3ntzL7Qw9I61EOTRhU4pVmtM/mMRs/VhAsgOv28nvktzFSx1hBUaYAOZ
         8ZEODKKohkyGTcUrXMc7HqEBgG+tF6NYCfI6LcFlFP86js5ugBis1kjQYVtIBRNWqQAp
         jFEVc0U1V0rC/eEbksgY2bl+w1D950sWNVQLdUTJCFLGyvWyvDvuCwwaB7f849JXklpY
         X9FgdHzVitB5sjLWoVqwPrpOpVV2Qeh4Sy++w2+5J/q+ZaOkyS8Mjh9NxeqJUvJAlLy7
         PvRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id c79si1752420qke.134.2019.06.27.06.19.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 06:19:13 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.92)
	(envelope-from <riel@shelob.surriel.com>)
	id 1hgUIz-0006BR-AX; Thu, 27 Jun 2019 09:19:13 -0400
Message-ID: <2f94b350ce562701bf31820d0ba745a06c983223.camel@surriel.com>
Subject: Re: [PATCH v9 4/6] khugepaged: rename collapse_shmem() and
 khugepaged_scan_shmem()
From: Rik van Riel <riel@surriel.com>
To: Song Liu <songliubraving@fb.com>, linux-mm@kvack.org, 
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: matthew.wilcox@oracle.com, kirill.shutemov@linux.intel.com, 
 kernel-team@fb.com, william.kucharski@oracle.com,
 akpm@linux-foundation.org,  hdanton@sina.com
Date: Thu, 27 Jun 2019 09:19:12 -0400
In-Reply-To: <20190625001246.685563-5-songliubraving@fb.com>
References: <20190625001246.685563-1-songliubraving@fb.com>
	 <20190625001246.685563-5-songliubraving@fb.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-XX3VlRGl2hyUPeG85tjf"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-XX3VlRGl2hyUPeG85tjf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2019-06-24 at 17:12 -0700, Song Liu wrote:
> Next patch will add khugepaged support of non-shmem files. This patch
> renames these two functions to reflect the new functionality:
>=20
>     collapse_shmem()        =3D>  collapse_file()
>     khugepaged_scan_shmem() =3D>  khugepaged_scan_file()
>=20
> Signed-off-by: Song Liu <songliubraving@fb.com>

Acked-by: Rik van Riel <riel@surriel.com>

--=20
All Rights Reversed.

--=-XX3VlRGl2hyUPeG85tjf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAl0UwlEACgkQznnekoTE
3oMxUQgAifzfEQEqWrpF79WAQuJKF6M1RfFVcdGX22cjDZlnZKZdbZM16fG55kdN
0AsMM+3LHgBLS1mYq/8d/sjFPxCH8UH3qebrvr8RgZSOIQ6Yiy+GWoPMYgkfDqPd
RX08C+un8MGcnzIcHnot4Ha8v4i/+AUFcYWcEdChkrXvaooEdjjOUPeoAaNt3um/
lAP/vIGiFh+7paL/LSk0VGG5OUMn5EXtIBWiCRdcU8adw+2tcprzDBexQH5kGnA/
qUpJSGlHjJzLgb/zan9+kc8ajJRqf2ybIMCTLmhpuFFHLOnhfly8aYkZiwOtvlmL
nGKZ3qK9CZZrKTTQJwpQ70zomYRxQg==
=37zQ
-----END PGP SIGNATURE-----

--=-XX3VlRGl2hyUPeG85tjf--

