Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA8B1C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 01:04:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84216214AF
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 01:04:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84216214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BAC86B0003; Wed, 19 Jun 2019 21:04:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16ABD8E0002; Wed, 19 Jun 2019 21:04:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 081988E0001; Wed, 19 Jun 2019 21:04:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE25A6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 21:04:56 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id s25so1461342qkj.18
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 18:04:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:sender;
        bh=MCbXnKcdeBI8YKu+nsUS6F2K1ifk/XVUvXyNGkkPedI=;
        b=BXkFc3sPQ5SbEpGCZf2BdPwxNWF/E5mtjIUbaDN9qKcqEcVXazf4yDV9WRKiiACuYy
         V2TV8KWgVcuc24LOKq8wr5+fQA1btGgs6pmSiUHP+hUGRgN+R5pLBNZ6zS5Mmu5X1Wx+
         jeB9Iv7k1I/K3CYwf8fBfH2Mn+wiOnsPAiSGJBT2xVradPcITIIEfq86u7t63n8GmLY2
         3bghnIiMZ9bdBUDc4fC6JwbTEozX165dY6lU8yNdQZrwdk3hWthtgX23yzVXoWCjFfRe
         YPMoaz31xYTr+a+6aqf5Y/wvrsbED0NsW+Y3QeE770OZO08ldM2CkUaT3b3Cvfu25uHP
         /vag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: APjAAAVaijhKyXzzv6PY7KGGbKiy9yDfrsVM5CAu3XlbCyVQ1VjD9yyY
	it5JZST2SMnfp5JAjsJFNF6v7FwnjvoFUF7l4tRXnBAgip3FSVgovjAK4bMImVAK8wGZiYb6Mmd
	CGpRfSfoc+o7Az1EtQNNPczqeLiM4Fl6SIsvNfzmDE3vx7rOFMmBxa1VxubElUsqIQA==
X-Received: by 2002:a37:4b52:: with SMTP id y79mr4474250qka.73.1560992696662;
        Wed, 19 Jun 2019 18:04:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoKko5oCqFTpRAweKUlasB+JMpmlrw9M9mNlgNaiq7E3OAhaaGA53AQZCJxNJ5C3862QgI
X-Received: by 2002:a37:4b52:: with SMTP id y79mr4474190qka.73.1560992695798;
        Wed, 19 Jun 2019 18:04:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560992695; cv=none;
        d=google.com; s=arc-20160816;
        b=hvsTJ/Z9KXqbgfjf2xBj8ZgE8wILnONEFbQ4z/aKI8AZum9ZmyolroagMO2pPiMkQq
         bgyZdaPILfgSUreRmhrlusLfKR7wOBHYlxLFl40ApD/+OoYptOatw1ODCoT/4hJRHiDv
         HW/KlioPpKEuVKzC8YeH+ACDmQcOeCRJa1a2WDfIbvwvrKBrbywILfajuj/tRXfALQ49
         7S+V0yOcGNAn6dWjdqlbeCinC8rNrBvG4DCYIDRnKMgMw0i6IW18BgVWn6K3ZaWSSCdC
         uL5riAtcNFxj1le2YpPnpAxxjDNwKPi38A3GlQxpAxbpeAQ2VFtWsPGh6rVStfra4o+r
         3Qtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:user-agent:references:in-reply-to:date:cc:to
         :from:subject:message-id;
        bh=MCbXnKcdeBI8YKu+nsUS6F2K1ifk/XVUvXyNGkkPedI=;
        b=ffkiM8UqrPVlnf/9IcwAszYb63pwH77WgGZVqZulVHN6condpZCyusHcy5V6pNOmLT
         0WmdcvWlWmkU+wwvqLUnOAsGrDAk7JPGortOVaMSzi0EI1ez+FgNZ7wq3BrPL9sgOJy9
         B9/jnTi+/4Sz21SYVgkpISCxxFRooYjNF3sd541khDXlzKsyIAiatYggZIlhWPswqD59
         edOyhacG6jrFgF4AEeYTTdTj4Phc7+8AZsQICLdfouUfvJwzKsxSyHCDId4SBr/ad32t
         PkzGqfug9VwOdPIPMt65Sw0KjBdj8cNMhj//tMQuYXnlnQ9z5Rm4fmCPNHU4M1+BWFsO
         GrgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id v35si3713212qtj.81.2019.06.19.18.04.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 18:04:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.92)
	(envelope-from <riel@shelob.surriel.com>)
	id 1hdlVT-0002bf-1Q; Wed, 19 Jun 2019 21:04:51 -0400
Message-ID: <f1e3473438cadb6a9677dbff892a1ed02ffdeb64.camel@surriel.com>
Subject: Re: [PATCH v3 2/6] filemap: update offset check in filemap_fault()
From: Rik van Riel <riel@surriel.com>
To: Song Liu <songliubraving@fb.com>, linux-mm@kvack.org
Cc: matthew.wilcox@oracle.com, kirill.shutemov@linux.intel.com, 
	kernel-team@fb.com, william.kucharski@oracle.com, akpm@linux-foundation.org
Date: Wed, 19 Jun 2019 21:04:50 -0400
In-Reply-To: <20190619062424.3486524-3-songliubraving@fb.com>
References: <20190619062424.3486524-1-songliubraving@fb.com>
	 <20190619062424.3486524-3-songliubraving@fb.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-YmeMgumGZEx/PNAysoo5"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-YmeMgumGZEx/PNAysoo5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2019-06-18 at 23:24 -0700, Song Liu wrote:
> With THP, current check of offset:
>=20
>     VM_BUG_ON_PAGE(page->index !=3D offset, page);
>=20
> is no longer accurate. Update it to:
>=20
>     VM_BUG_ON_PAGE(page_to_pgoff(page) !=3D offset, page);
>=20
> Signed-off-by: Song Liu <songliubraving@fb.com>

Acked-by: Rik van Riel <riel@surriel.com>

--=20
All Rights Reversed.

--=-YmeMgumGZEx/PNAysoo5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAl0K27IACgkQznnekoTE
3oN5FwgAmxNVgt40kbhTretf3qlTzGbEDKIHMTWIJ62GaToY41ryi9HQR1xqFhgH
dw0d2XibkK46rFH4MhN5nBB0EGyk3rJqrV+nYPfwLeNAeDCxj4GdRgl4B8aXGVsq
KihetLbmKiMF9eyzsWguo+P6HF813Czo5iUB7oSqzCgGtiCG49z8vm4TBoGgTG/Q
Wgtoemi2f10NUHy9geMmFYtzWEHGZsNxKvXxbxFM3VJuaPR8oeKs5BKNkLrzs6cg
kvZjVZgp49K0R7t/0fD0QxLD309qDsRC/bZsZEIKLVDPJErIpRZRexQraTNeV+li
qCfJ3dTfWfQ7UgByfxW5t/lYUZzA6g==
=XAiK
-----END PGP SIGNATURE-----

--=-YmeMgumGZEx/PNAysoo5--

