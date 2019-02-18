Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D207C10F01
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 17:59:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0ADD5217F9
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 17:59:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="NPjmsRzx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0ADD5217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 952828E0004; Mon, 18 Feb 2019 12:59:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D8B28E0002; Mon, 18 Feb 2019 12:59:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 779338E0004; Mon, 18 Feb 2019 12:59:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4358B8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 12:59:03 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id g123so11435712ywb.20
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 09:59:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:dkim-signature;
        bh=yljpbhmUSpbK3ZHxUMPa6QcOvurPZMhS7eG0xTM1hHc=;
        b=MI1e+vtpPSLrlTk4Nrn2LQwLrlL1xxKrSIjW3RuxCBWASlKcE75llRDEKz1E63Xl/G
         0aBnrpigfejXfNbGpMVUTqEpEhj2tdRl4Yf5eup0xKwljp/o8eMpvRt/s06Ko9TQChvc
         Sxxq6kkHYccCoSOrKdzhiys0SmEtq+IQXm4ZKaFb4pgm3U7bwUStnHTsz/HDUDYl0hN9
         UYnRLgWyxn8ASJwBDIHizy/ovpOatySYG87sq6CN8EI1j6EetL/uMZit2kQ0EoBXV49O
         X1MA/rtdwdRMkCWb4597/CA0w24UcEMxPm+jHOvssW0BpxG32MWa7p44oAo/j0WyIkoI
         W6/Q==
X-Gm-Message-State: AHQUAuZuklm4VeypjbXgzxGDKoSTP2JxRUxuVN5vu4IrOHGEC7oOyH20
	wNYcF8blWWzDJdoVSp3naWNla9N45daWqLv7YzYpXRqXwVPasQi/esKuZasKPP3cVM1YtGkuq2L
	BDHcLyy4+lKXNyrnky7pB4FOvwIBPem4u5UHxLmVK7ihA5uUhvqoQGrez25DSYgiZtQ==
X-Received: by 2002:a25:c1c6:: with SMTP id r189mr20555372ybf.109.1550512743013;
        Mon, 18 Feb 2019 09:59:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibruu3yMN3Nr99/UWjHGwfFqj0IQjnjG4vtUL2/YRaN/A07TVX0hJuPpVmPVSpDiSxhMuYI
X-Received: by 2002:a25:c1c6:: with SMTP id r189mr20555349ybf.109.1550512742610;
        Mon, 18 Feb 2019 09:59:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550512742; cv=none;
        d=google.com; s=arc-20160816;
        b=FVlVJjydo/PaxMmIvb53A/5mwUEjDkVPbRuhYNTs3aWFVhno6iVicuvF+82mcER/1O
         nANSsryL9Rz6OhEliKN058RJDAOUgIFM/2fdKxD+b9vNjQiaLbRALS9hdI7AHZQdVGuH
         5E5wgXjqUW1v3OlRwCW+oYY+ubtKmBHYrgkyw1e//uJNWU9a1u+V9vBvg2cl1BTVp3Mu
         f3h9zYCB6NKGIwNOHegb0YcxAvDyDK+12yvJqpW2798aWw40kwUXco4D6AUD5xW4BY9+
         PJT/LlnZvJzDNXahsPSXqR/w5msWcscZcwlFts85k8H9iIOMMPlioSmOyAr53g0VHkyj
         +9cA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from;
        bh=yljpbhmUSpbK3ZHxUMPa6QcOvurPZMhS7eG0xTM1hHc=;
        b=qGG7HQHae2ZH9Vw7+1o7WTlDTbWY6XitaNwqFnk+uFHoLLPg9n7cDGGFkDcSxHlffm
         0H+er7UUjJRjhS1Jui5I28mvtbeJkbQKUuF0tuZS/tAfY4JUvWL/Av1Nlb0tMhGp4WTG
         vTiB5yvNQj7WVUmYOQysUBy6YzXbiRXgwF/9wpznXzJ4HvbP2yLy26DIjnpDBmmwjaQx
         CuJOWruG13oy8waRK3/cr6VUQIV8FwUmlx2k6EpvPbhF0E7y3/cfFUEtuLxUuMFa2OCG
         5LrNUKocc0R4yAa4XcMG1aSQZtQQA3BeCW6EQpF8VcQZd7eZ+3PadYhOWf/ZyPW4yfHi
         tiIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=NPjmsRzx;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id b203si7920938ybc.447.2019.02.18.09.59.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 09:59:02 -0800 (PST)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=NPjmsRzx;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c6af26a0000>; Mon, 18 Feb 2019 09:59:06 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 18 Feb 2019 09:59:01 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 18 Feb 2019 09:59:01 -0800
Received: from [192.168.45.1] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Mon, 18 Feb
 2019 17:59:01 +0000
From: Zi Yan <ziy@nvidia.com>
To: Matthew Wilcox <willy@infradead.org>
CC: Vlastimil Babka <vbabka@suse.cz>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>, "Kirill A . Shutemov"
	<kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>, John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>, Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>
Subject: Re: [RFC PATCH 01/31] mm: migrate: Add exchange_pages to exchange two
 lists of pages.
Date: Mon, 18 Feb 2019 09:59:00 -0800
X-Mailer: MailMate (1.12.4r5594)
Message-ID: <C84D2490-B6C6-4C7C-870F-945E31719728@nvidia.com>
In-Reply-To: <20190218175224.GT12668@bombadil.infradead.org>
References: <20190215220856.29749-1-zi.yan@sent.com>
 <20190215220856.29749-2-zi.yan@sent.com>
 <20190217112943.GP12668@bombadil.infradead.org>
 <65A1FFA0-531C-4078-9704-3F44819C3C07@nvidia.com>
 <2630a452-8c53-f109-1748-36b98076c86e@suse.cz>
 <53690FCD-B0BA-4619-8DF1-B9D721EE1208@nvidia.com>
 <20190218175224.GT12668@bombadil.infradead.org>
MIME-Version: 1.0
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: multipart/signed;
	boundary="=_MailMate_0BB521CA-1CAD-4EA1-A067-DCAFAE90573C_=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550512746; bh=yljpbhmUSpbK3ZHxUMPa6QcOvurPZMhS7eG0xTM1hHc=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type;
	b=NPjmsRzxI4Znr1hzBLzzxCI+yt/7CUxfGhpVkEJBB0Z32UeGbrQMJIQrQAOEA533M
	 ccK+V7tOtviV3OdFezrVfLYJOZ/19XUR3cgdYg7HgWQ0O/0AVYEK4LDNwJoQG7YCJ3
	 yV6SAWrj7w2nNFcIC0hFQr1Q9kVcdnmMcr0Urt2sYRVC7betMBJrY0NADKk8DJejxI
	 GjxqXFJPP/z6z4L35qtsCcpjEMLIoCt4kkHv2T7o2cnefuHztsS9IALt5AILUg3NLf
	 p/IWPTmMEMaKmCor2rb2fy08/MKuog9yeoygzQEZneA2i3/j/vrCi8pxz4oYRzxdzc
	 g9/7UcwdZDlnw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--=_MailMate_0BB521CA-1CAD-4EA1-A067-DCAFAE90573C_=
Content-Type: text/plain; markup=markdown

On 18 Feb 2019, at 9:52, Matthew Wilcox wrote:

> On Mon, Feb 18, 2019 at 09:51:33AM -0800, Zi Yan wrote:
>> On 18 Feb 2019, at 9:42, Vlastimil Babka wrote:
>>> On 2/18/19 6:31 PM, Zi Yan wrote:
>>>> The purpose of proposing exchange_pages() is to avoid allocating any
>>>> new
>>>> page,
>>>> so that we would not trigger any potential page reclaim or memory
>>>> compaction.
>>>> Allocating a temporary page defeats the purpose.
>>>
>>> Compaction can only happen for order > 0 temporary pages. Even if you
>>> used
>>> single order = 0 page to gradually exchange e.g. a THP, it should be
>>> better than
>>> u64. Allocating order = 0 should be a non-issue. If it's an issue, then
>>> the
>>> system is in a bad state and physically contiguous layout is a secondary
>>> concern.
>>
>> You are right if we only need to allocate one order-0 page. But this also
>> means
>> we can only exchange two pages at a time. We need to add a lock to make sure
>> the temporary page is used exclusively or we need to keep allocating
>> temporary pages
>> when multiple exchange_pages() are happening at the same time.
>
> You allocate one temporary page per thread that's doing an exchange_page().

Yeah, you are right. I think at most I need NR_CPU order-0 pages. I will try
it. Thanks.

--
Best Regards,
Yan Zi

--=_MailMate_0BB521CA-1CAD-4EA1-A067-DCAFAE90573C_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQJDBAEBAgAtFiEEh7yFAW3gwjwQ4C9anbJR82th+ooFAlxq8mQPHHppeUBudmlk
aWEuY29tAAoJEJ2yUfNrYfqKvz8P/2QWoZ7BWe9DN+EX/xH7sX2+WgzwoOXSbqud
Q1DOF9mtLfTCPyxff+My2P2j1h2fyptIoVN5SE4J6j8BggLKN5wp1IH+rfl0z1Q1
oN3+L4cOKtOGl9/kVEDcCng46pMgCXBr4JrkcR/tbpe+lqlgcxJQKSMThLDg+NC2
k9LUt1mY5AG+3SgCmRayI4ROjsmsRjk2mlQq6e+cXLKToaByJ5GlTc+IebjXevVo
Fbet14T79dJWG+FHpMA1RwqFFJk48y5NYf0kMvWY+SnZHaeNm0gFUKnKtgH3EbK3
I7RQaVEvPnEptOEXsHXD24ukVLAaELib/molyY7OLeVw0W1X1jN0ARF3vwbTDf7x
TepaHrzK+Ft7VX08Lc/W3yOH0RSipkoobDUPiZwxnWf13PKKxl5C84tiAMvxj7zL
7vxOO0uEaSCRP5johYsCvglRoPLZ4YUR8yxF8uhOat5UQbymt2w10V67+nyAAsoQ
+rHZ84bWhpOuX/ussS0zjz6AVchq8z1w9PanYHLU0Wm7HcJzHbcVWTcn2lfyESiH
o50VP92H1w4biHlNIOUiOjl2ColtSOCUXhrBycd2/cSLL6Ub7oEbLCNr3ivF60PL
GcywjYloQ/lQtFWUStFSN9UXONpj+urQ3GfXJj4owAK/rgwXX1cVH87a098zRm3z
uMDfSnJx
=Hhar
-----END PGP SIGNATURE-----

--=_MailMate_0BB521CA-1CAD-4EA1-A067-DCAFAE90573C_=--

