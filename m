Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3518C43218
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:52:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47AAB2053B
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:52:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47AAB2053B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D896B6B0272; Mon, 10 Jun 2019 18:52:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D39AE6B0273; Mon, 10 Jun 2019 18:52:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C29596B0276; Mon, 10 Jun 2019 18:52:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 97E996B0272
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 18:52:36 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id x27so5545978ote.6
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:52:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=NofsTw7jVbXikjywTcUvOrrzN4+CxtF5jV068k/vPhg=;
        b=oQ1hYWYgafdLSq/+uHRrt7ib0BiW0E1gdKScKKNzUwM4gxRuWmSSQUn876HwyC60FU
         Ic0ZWdffsVpj8uIkzY9GFIxZ3ofcBMI6L++Slp0iKWMxhCxMmUbrlPE3YCkjR556SZTF
         BUEa659tYt7YLsPbYDaIxLOw4BtEfqecZfRwuZNUpKfngu0jaJyLeJ/SFNs/+fKplbn2
         t5zGVFcxEXNh4+WUMecIcvDTtAG9vj05XnmQoRawDyhsBFoNIyCdb52boUcKloiaFh1D
         QC1FhlkrrF6osqhTQe7jYskcjEOVT0vgNrsG3zAi02pnOCvPJjBW1J6IU8jCt7nfXGs/
         /YDQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAWjunVnN56DY+ZQxrihx40k3rpDVxycPr77JfnrK9rJWzFvywt+
	dQQ8nzX4u2nLW7dNRtDLJVjuFRp+ib8gp8igPAcaEsO35sdh4iSCIkSXpnpN8nuHQJPuwnE7WBy
	BDFV1ukSj3MzMPyONJLJKlWm+x+26Jr9hMnY2gz4MvTBnHkgexenAd+WmN/Hs4HW4Lg==
X-Received: by 2002:a9d:191:: with SMTP id e17mr1545899ote.315.1560207156219;
        Mon, 10 Jun 2019 15:52:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiTUzdr6ABiCqnSGF8Fp32s80OLMtq9pltizoJ5PAtGEo0+OVFlPiKGKkHIEwhPVIaENkY
X-Received: by 2002:a9d:191:: with SMTP id e17mr1545855ote.315.1560207155286;
        Mon, 10 Jun 2019 15:52:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560207155; cv=none;
        d=google.com; s=arc-20160816;
        b=eInzS7g9hePC7ig/vuY6/qlmNbB4Vpp4aP/5eAogfHDIxK0zVQUM08gd5QDypma24q
         ybXnFs3OEo05V381Aut006LUm8wEpdHiQ0ON+JGOr+DggWhzsQm6E2YHhukQlldY61Qi
         0GkiboUcE2yjr7i4FzoyDHX8omznm5RG11xZ7L4P7DzJ0lL6LkkIYLhVLRgIG9oRfFhb
         FCfzLN8FDox40vQdXDov5GT5NoborqmTtlWJfsugIh5lSEbZIBpjfmYGx6UZFelD+guO
         z2geD7bWThsVVvZorgxCKcowllgYgCLdQCnR/r45YgNlxjbod3qcvLXcZB8WSPAlSPTF
         pwiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=NofsTw7jVbXikjywTcUvOrrzN4+CxtF5jV068k/vPhg=;
        b=rzNtzlVW35FB5s3MHGPLzA89rnVN69v6BZdTY5CFdQ7hPl7azNIxmDDiXxOnclXy9V
         qLnQ9Sm/NUDbUO5wGVwag4IMQzNipU5cH7EXfygQF6VqmqeRxFMuRsFTATrqqINQ0rFj
         dlKYW7VQd7somY2kYQ/9yCwClzlITXbamZmAHmTi3estSMdA/sM/1YBNvsmKc36R4Iaz
         mfedY9l46xZUIdrICcTrGwlgVNDS+Lhkwwj/9ceDeTAUVKAt6P7zYuuuJCdE67OczzyB
         LZE6nKEd5dgLmgfU3jTQgw7WnQ0LeGDN3I1Wzz76lPsb2KdlNfcwTeLt575Eq4FVrzQn
         kr3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id l22si6295627otp.185.2019.06.10.15.52.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 15:52:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) client-ip=114.179.232.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo162.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x5AMqLnn024430
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Tue, 11 Jun 2019 07:52:21 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x5AMqL6q016179;
	Tue, 11 Jun 2019 07:52:21 +0900
Received: from mail02.kamome.nec.co.jp (mail02.kamome.nec.co.jp [10.25.43.5])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x5AMpo63002979;
	Tue, 11 Jun 2019 07:52:21 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.152] [10.38.151.152]) by mail01b.kamome.nec.co.jp with ESMTP id BT-MMP-5829201; Tue, 11 Jun 2019 07:51:34 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC24GP.gisp.nec.co.jp ([10.38.151.152]) with mapi id 14.03.0319.002; Tue,
 11 Jun 2019 07:51:33 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Michal Hocko <mhocko@kernel.org>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>,
        "Chen, Jerry T" <jerry.t.chen@intel.com>,
        "Zhuo, Qiuxu" <qiuxu.zhuo@intel.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2 1/2] mm: soft-offline: return -EBUSY if
 set_hwpoison_free_buddy_page() fails
Thread-Topic: [PATCH v2 1/2] mm: soft-offline: return -EBUSY if
 set_hwpoison_free_buddy_page() fails
Thread-Index: AQHVH2UNBW9Lhf3e5UinMjf59GXrMKaUzwKAgAAZdgA=
Date: Mon, 10 Jun 2019 22:51:33 +0000
Message-ID: <20190610225140.GA30991@hori.linux.bs1.fc.nec.co.jp>
References: <1560154686-18497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1560154686-18497-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20190610142033.6096a8ec73d4bf40b2612fb5@linux-foundation.org>
In-Reply-To: <20190610142033.6096a8ec73d4bf40b2612fb5@linux-foundation.org>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.96]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <03697C5541B2D04CB700AC95BD5D6F50@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 10, 2019 at 02:20:33PM -0700, Andrew Morton wrote:
> On Mon, 10 Jun 2019 17:18:05 +0900 Naoya Horiguchi <n-horiguchi@ah.jp.nec=
.com> wrote:
>=20
> > The pass/fail of soft offline should be judged by checking whether the
> > raw error page was finally contained or not (i.e. the result of
> > set_hwpoison_free_buddy_page()), but current code do not work like that=
.
> > So this patch is suggesting to fix it.
>=20
> Please describe the user-visible runtime effects of this change?

Sorry, could you replace the description as follows (I inserted one sentenc=
e)?

    The pass/fail of soft offline should be judged by checking whether the
    raw error page was finally contained or not (i.e. the result of
    set_hwpoison_free_buddy_page()), but current code do not work like that=
.
    It might lead us to misjudge the test result when
    set_hwpoison_free_buddy_page() fails.  So this patch is suggesting to
    fix it.

Thanks,
Naoya Horiguchi=

