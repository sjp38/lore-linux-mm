Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85123C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 09:07:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D3DC2087E
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 09:07:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D3DC2087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D466A8E0007; Thu,  1 Aug 2019 05:07:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF1BA8E0001; Thu,  1 Aug 2019 05:07:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C07398E0007; Thu,  1 Aug 2019 05:07:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 898338E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 05:07:15 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id n9so41309768pgq.4
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 02:07:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=AnBnyE/b1ZsELj0kzxFm7A/FUKrCeuy/mpCA3O82G2U=;
        b=G5bCzNTDOGocnIqrtaHR/IM5RFtNwUCt+s0tDerdwQ2KqSOR+2rMnrgOl1yR0hD3eg
         fVrF9ya6iSRjWnXu5YzGv7aX9O5h6S8uHgSIHhdN9dP7mbAC5gtMDL1PCn3LRHNGzRGe
         +lg88TSlNtjzl4rhZM7UCQO0YotvTMVijcCUbFoiNHzk+0ZMIYScSXX1ZGBsiaiWlH+G
         JVSwDJ7B7s8cgVCn6lZskD/Wd23l1lojgPUJ2SwiQxj4gtc9xWf/9VG3GcUrQtjHiGDZ
         w8xJgP+t2Ny+oKpaDiGmUK969Uy/P+Hqq6L0WIo/hkx2Rh7Gq+xlux3lZrSAr6DGzN7x
         TLpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAW1d6zf3G1J/d3noPfPWmkb7DH0uR/mTB1HGC7scT695GAZatwT
	WwllAx9z2bO2ldFCFVNZrlOPf30ySqOI5/GQQHSxOcK2sT/JuJqxZKKDK8KkN/sOlvYXjqUzyt2
	HP8JdwYGMyc69NjfG0secNcUtuV5U+3lcOr0xZAqVdXrG80H7oKj099QiqM1EZIW3Ng==
X-Received: by 2002:a63:3805:: with SMTP id f5mr84467840pga.272.1564650435031;
        Thu, 01 Aug 2019 02:07:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6GHm+UTqGQirAUwlw2FDlOmAzs4dNvAFfmzTyXbs6X14h7O5eAtDD03yjmLZQ70tMHvgC
X-Received: by 2002:a63:3805:: with SMTP id f5mr84467771pga.272.1564650434236;
        Thu, 01 Aug 2019 02:07:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564650434; cv=none;
        d=google.com; s=arc-20160816;
        b=uBJwJsz+CGehr32A+epoRWDhjZ2/J4RldzCPo2PzfzPMOdhvkH8QXpEJxvPatJUJOm
         0pG2CCmDXmzmKI3A3HioJlHBTjNom10E6Le8lPqcsPqrclWEWZPfxTv+OgG/qB6n3vGs
         0tJZ7AFD6dwQ9igDuaPvLRPy0aH2/AGuWK/pc2ZCqv8LoaSkCrdvZwFbfo4IwHik7IV6
         WrVdnE5kxujAqsr7jSGfFCckf33ooW9w3zM7vOiwXPlrIxwBpuWXh9TCq8fBMDmJoA78
         lK6oeeXpwx8kBFBIqkXrXjye558C5ITjrRaKAizJ+tZX3vcQiS0Wx4xlI8qpy1aQ5E8X
         GZrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=AnBnyE/b1ZsELj0kzxFm7A/FUKrCeuy/mpCA3O82G2U=;
        b=KjRDKPTLwbIJ3Wt8q4eEv0xVOOxbqLIambxdn8cOd9LLoInQE4ciXIgKK5MYEpeTG/
         XC4FiLyOSS2cSlE9d2qnXL/Jw1tbbzzg8gk3RKyXGeSchibkTbb01oPgtXTvrTooo4/H
         GXvyQkaAFsm7pOOzQ3fCfu4/+1y+tGF3pKbeNOYVJqe//MF5XNGIZuYhX4H618Xp5PeJ
         xSz/m/QUvZlFj8ZxnY8Ari/BlJv6Fj0JvgLgEpL5Khcy8Qma9dBYcy4zR54Cr2FhZf4C
         VqdjWFccdpS1oscNxAMRvU/katu4Gaq2oouxSYp8t5S07tasAyNOTHDRifbVHAbegTGI
         gkQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id j185si34461915pge.91.2019.08.01.02.07.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 02:07:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) client-ip=114.179.232.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate02.nec.co.jp ([114.179.233.122])
	by tyo162.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x7197CsK017672
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Thu, 1 Aug 2019 18:07:12 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x7197CP4008465;
	Thu, 1 Aug 2019 18:07:12 +0900
Received: from mail02.kamome.nec.co.jp (mail02.kamome.nec.co.jp [10.25.43.5])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x7196QOn002648;
	Thu, 1 Aug 2019 18:07:12 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.152] [10.38.151.152]) by mail01b.kamome.nec.co.jp with ESMTP id BT-MMP-7309567; Thu, 1 Aug 2019 18:06:53 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC24GP.gisp.nec.co.jp ([10.38.151.152]) with mapi id 14.03.0439.000; Thu, 1
 Aug 2019 18:06:52 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Jane Chu <jane.chu@oracle.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Subject: Re: [PATCH v3 1/2] mm/memory-failure.c clean up around tk
 pre-allocation
Thread-Topic: [PATCH v3 1/2] mm/memory-failure.c clean up around tk
 pre-allocation
Thread-Index: AQHVQzSRmIJeo+dcwUujsqrGBDWq6ablc6CA
Date: Thu, 1 Aug 2019 09:06:51 +0000
Message-ID: <20190801090651.GC31767@hori.linux.bs1.fc.nec.co.jp>
References: <1564092101-3865-1-git-send-email-jane.chu@oracle.com>
 <1564092101-3865-2-git-send-email-jane.chu@oracle.com>
In-Reply-To: <1564092101-3865-2-git-send-email-jane.chu@oracle.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.150]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <1FD28E0D8B0232438C43D1B28666B164@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 04:01:40PM -0600, Jane Chu wrote:
> add_to_kill() expects the first 'tk' to be pre-allocated, it makes
> subsequent allocations on need basis, this makes the code a bit
> difficult to read. Move all the allocation internal to add_to_kill()
> and drop the **tk argument.
>=20
> Signed-off-by: Jane Chu <jane.chu@oracle.com>

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

# somehow I sent 2 acks to 2/2, sorry about the noise.=

