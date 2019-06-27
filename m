Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39264C48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 15:31:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2ACE2064A
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 15:31:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="ZYF+qGGa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2ACE2064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70A636B0006; Thu, 27 Jun 2019 11:31:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 693F58E0003; Thu, 27 Jun 2019 11:31:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 535168E0002; Thu, 27 Jun 2019 11:31:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2CE406B0006
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 11:31:37 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id p18so3565902ywe.17
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 08:31:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:dkim-signature;
        bh=vDxVQVvJQ3+Sqi/Q2QIRj6FMeyjJ9wfmkbAsVSsgX7w=;
        b=POBFuEdtdykV1SWLv/ixq3ZDKQxUGS140vGvsCnbq7HqwDCib3aaOHc3159AhWt0MP
         99pSzE8/LGNNCZKcgPpmyu7/IzS1lXYJeq2KNbTSIMxnzLff8kTHHXg7TwQ+y/jDGVo3
         lIjO1zxtVUZJRCtdzTQ6K+eCVonUBcGThgmdQdNd+wWyeT5DaEIx3UQ3H9Gc4SlzoNNV
         Ngto+bToHVKu+ibf2UrQ8SeVnTrHqVizKGP3TcVCrspb07gI9o4QGfrCgSk2VGK/pqIE
         odz8sdgXhq4ggKK/Fhq1aKhufwQVz5FiWrpTEvD08ovn0luHGns2wy+w3RlFybEd1C0r
         o3uw==
X-Gm-Message-State: APjAAAUp1DidxoW2q/A7ST2EVvbz8RfmYfaGm3EUcUUIIk5mmDKT8ZYS
	72j1He4Q5YHHxXEWUaxAiLeWOYsgC7HFasn8gvvhxQ5YhKPdrNnxJEUZHnk9aeqSRv3I+q/d9yk
	1SMGEyLnlcNAfHG4fGt9DKpSGtSuDW1h0DABDzyKCN6/1IGDcwm0WtqcrbWOyiiFXRw==
X-Received: by 2002:a25:bf85:: with SMTP id l5mr3073581ybk.45.1561649496872;
        Thu, 27 Jun 2019 08:31:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzT1daJyP8toefdcpeDgm5LzqXnu9lnLkmGgrW2cYQiSFZoyyKyM9DK+Z/B7eHU6x/E9jkv
X-Received: by 2002:a25:bf85:: with SMTP id l5mr3073526ybk.45.1561649496081;
        Thu, 27 Jun 2019 08:31:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561649496; cv=none;
        d=google.com; s=arc-20160816;
        b=bwP8zbr9fIyfzyqln6tKl2J57cKs3po6Bp8IV5pR9cSUDiPCOWqaMrOrfGuhdkLTL7
         3vruy9wK1a99mq+dwUkPZSphkxe4BVwMAizdxoYthtD1+Z6TWT6oi52FL2XhhPzZhsi3
         oQtNOzq8mxTVATcx0XWTG/bsKTNVLRHD0AaP/IIuIOaJ5T3RP51omKOmIpyiQcLPvY5o
         peA15f6ooPm0RDGSJnnMykxvSIfSoV6DrlXHTiK2WT3kkh2rUL8DoF9WpBXqJPCJ1YWj
         uo3LBvPlmE046+3b3g3iCjYeS2oW5vlGhvtMf0vqdqmlG+7v9N2P/IEtOVp34mOjqUVi
         B6Nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from;
        bh=vDxVQVvJQ3+Sqi/Q2QIRj6FMeyjJ9wfmkbAsVSsgX7w=;
        b=nv/QB/DbbQKbOBx3jXONbalWPJGpm/0oYBn+ou4p/g9qvVSAnUJTT3spV3zN03vUA7
         /aRO9mQNpnWFGdBUEWffIk28E8XpdL+OM7dj+HE5fWIuftgTKFFfnsobEWXvzrcAN1Gm
         AUtknlG4DBAwsnW7IvckKT69gewpc938FeNjD2/ugPSWeHeSaNGXHWpLsIDO3ic0fZih
         kvPFtDCrzuo6xXDyY1waUWLlkpaJHLK3E2z5DJTX67osKsai1htLQGMpH1uzLR8RhGnL
         Gu6RJSi6FowF4Ks9djftF3fs4rp9JY2vsaWCQi4n/zMkqS2M0cZSc2QTNWWPQSqozSns
         0PsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ZYF+qGGa;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id y4si16826yba.80.2019.06.27.08.31.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 08:31:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ZYF+qGGa;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d14e1540002>; Thu, 27 Jun 2019 08:31:32 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 27 Jun 2019 08:31:34 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 27 Jun 2019 08:31:34 -0700
Received: from [10.2.163.244] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 27 Jun
 2019 15:31:33 +0000
From: Zi Yan <ziy@nvidia.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
CC: <linux-mm@kvack.org>, Catalin Marinas <catalin.marinas@arm.com>, Will
 Deacon <will@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Marc Zyngier
	<marc.zyngier@arm.com>, Suzuki Poulose <suzuki.poulose@arm.com>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>
Subject: Re: [RFC 1/2] arm64/mm: Change THP helpers to comply with generic MM
 semantics
Date: Thu, 27 Jun 2019 11:31:31 -0400
X-Mailer: MailMate (1.12.5r5643)
Message-ID: <7F685152-7C6C-4E99-99DF-03DDD03D6094@nvidia.com>
In-Reply-To: <1561639696-16361-2-git-send-email-anshuman.khandual@arm.com>
References: <1561639696-16361-1-git-send-email-anshuman.khandual@arm.com>
 <1561639696-16361-2-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: multipart/signed;
	boundary="=_MailMate_B99B95B9-F3F7-4559-91D4-01BCFC794027_=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1561649492; bh=vDxVQVvJQ3+Sqi/Q2QIRj6FMeyjJ9wfmkbAsVSsgX7w=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type;
	b=ZYF+qGGah37ytxxKVO/Snol52FyL17Y5EeBAZdecBKuQZZ/ypxmCOma8lPQTFPPbU
	 SmwaYsAHf6HqDRaSqmByfCgjrFwR5W6v3EA9G0kyqu2sRSR3A247kZkKBOyJd2e9q8
	 X3l2fk0vzPNx/6HDJLRcV9QqEvI7NtedkdxPV8QykTjddZgM6dgrJg7H5gWPe/4pqN
	 Rzr2cUvvgMTyPZ+TRFvuEd4/4dH2jdO5G2bJJX5du8ciX7Q0wHRIRthELuNqRGLMc+
	 u1HSa7SJiKz3fk/1IsEuoICh1HzNqxSG/pg4dsrw1IDg4QGfNHUe2tGZYVrsf2KI+E
	 0nFCTVBs4M5jQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--=_MailMate_B99B95B9-F3F7-4559-91D4-01BCFC794027_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 27 Jun 2019, at 8:48, Anshuman Khandual wrote:

> pmd_present() and pmd_trans_huge() are expected to behave in the follow=
ing
> manner during various phases of a given PMD. It is derived from a previ=
ous
> detailed discussion on this topic [1] and present THP documentation [2]=
=2E
>
> pmd_present(pmd):
>
> - Returns true if pmd refers to system RAM with a valid pmd_page(pmd)
> - Returns false if pmd does not refer to system RAM - Invalid pmd_page(=
pmd)
>
> pmd_trans_huge(pmd):
>
> - Returns true if pmd refers to system RAM and is a trans huge mapping
>
> -----------------------------------------------------------------------=
--
> |	PMD states	|	pmd_present	|	pmd_trans_huge	|
> -----------------------------------------------------------------------=
--
> |	Mapped		|	Yes		|	Yes		|
> -----------------------------------------------------------------------=
--
> |	Splitting	|	Yes		|	Yes		|
> -----------------------------------------------------------------------=
--
> |	Migration/Swap	|	No		|	No		|
> -----------------------------------------------------------------------=
--
>
> The problem:
>
> PMD is first invalidated with pmdp_invalidate() before it's splitting. =
This
> invalidation clears PMD_SECT_VALID as below.
>
> PMD Split -> pmdp_invalidate() -> pmd_mknotpresent -> Clears PMD_SECT_V=
ALID
>
> Once PMD_SECT_VALID gets cleared, it results in pmd_present() return fa=
lse
> on the PMD entry. It will need another bit apart from PMD_SECT_VALID to=
 re-
> affirm pmd_present() as true during the THP split process. To comply wi=
th
> above mentioned semantics, pmd_trans_huge() should also check pmd_prese=
nt()
> first before testing presence of an actual transparent huge mapping.
>
> The solution:
>
> Ideally PMD_TYPE_SECT should have been used here instead. But it shares=
 the
> bit position with PMD_SECT_VALID which is used for THP invalidation. He=
nce
> it will not be there for pmd_present() check after pmdp_invalidate().
>
> PTE_SPECIAL never gets used for PMD mapping i.e there is no pmd_special=
().
> Hence this bit can be set on the PMD entry during invalidation which ca=
n
> help in making pmd_present() return true and in recognizing the fact th=
at
> it still points to memory.
>
> This bit is transient. During the split is process it will be overridde=
n
> by a page table page representing the normal pages in place of erstwhil=
e
> huge page. Other pmdp_invalidate() callers always write a fresh PMD val=
ue
> on the entry overriding this transient PTE_SPECIAL making it safe. In t=
he
> past former pmd_[mk]splitting() functions used PTE_SPECIAL.
>
> [1]: https://lkml.org/lkml/2018/10/17/231

Just want to point out that lkml.org link might not be stable.
This one would be better: https://lore.kernel.org/linux-mm/20181017020930=
=2EGN30832@redhat.com/


=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_B99B95B9-F3F7-4559-91D4-01BCFC794027_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQJDBAEBCgAtFiEEh7yFAW3gwjwQ4C9anbJR82th+ooFAl0U4VMPHHppeUBudmlk
aWEuY29tAAoJEJ2yUfNrYfqKinUQAKM0LtiOpKq090Um2I0uGfI6LhFiYxu0mTu4
xn54F2sm6WjyH7iXsUexLGkOIwz2wVyY6htmKPWk6uyoP+GtvdFa8x9FGoQrvH0t
wa3NoM4fFa39jUu74HaUkBYZiRNgGJr5t4M5cAOTJ/um/KsCJRfnKDsIwCcysheF
tsvGoMZX6zzbwtbYscjvIiGlYQOXFYqdt7T5RFX7p8+k7ZG9/wyjmR3filj5kqFW
O6sTBHLVeCftBTggC9Qkn1BjC1smHBNiAm/yYG1wyLnZKyjCkVdFq4b/d2QIFS2a
BdyOPfETSAOYP/+PlmiISqaVgKxYh6pP7w1qUtJjt2Kag29cFboTHVJAnDduO/6P
JU+KLKKH54Bb82r6naLkEttksDBc+xZ9iPiso1FxyDnfyawo+eIji0luRaKeigxK
4lDTEqywX/VonL6VAc0pEJ/ZwQMPTIqr726ssWI3x99SwuZphPFjUv+b2z70bQTj
Ra/rfXGCIlHI0malYTsqyoLJ8z3kkflpyC/QPq5VmKR7dlJp8jSK92u0VkDWm596
QqI8lXd79EQ8s3DoRJwr5g8MI7mgmn5yGK0/r8XjElxZ+imK92otyJsrzLZTBcba
JSi1Za+UfoWzZgJZA38HfglnOJoFXikAWnMKVuKF0JvKHCPERZubmBtwFM5SSL9u
Y+dCDneI
=jqdz
-----END PGP SIGNATURE-----

--=_MailMate_B99B95B9-F3F7-4559-91D4-01BCFC794027_=--

