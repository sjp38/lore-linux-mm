Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AC5EC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 05:45:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7BE7206DF
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 05:45:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7BE7206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B72A6B026B; Wed,  3 Apr 2019 01:45:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73F036B026F; Wed,  3 Apr 2019 01:45:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 607C46B0274; Wed,  3 Apr 2019 01:45:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 413AD6B026B
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 01:45:51 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id j8so5164008ita.5
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 22:45:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=9O1LLV4sT1FAfPm5rHvY3vURdVZR4h54IY5KnAtfx2g=;
        b=et/UJrI8xbPz5BDKOtRqG45Y27Mc/joPHCwAC3vKzRJrcPs42rZkWsQJlQkUueS4dl
         ZZ3EXfSAZcl+XTT16Ckgs7LckExduMl4Gh+++cn0zk8gfBOq87/rwTpMnYNq4Az8LeNk
         W09FyzigO+8fQyx//MY7ZnD9dCW3cgfKmmVMjbNqe0eC2E7jEwYpEY6wGdAppEeYWExJ
         34aXE1zRCRYLY5c+3UsZA1muypYcmV1XEDQn6tonTLvjLufUF0YK3VAGz8Y1SwQKo5yL
         EM1BwXNutkBZVc6RVxDDLJI8EeSSjb7LXBBe6YQREADJIm7rZfcAT4ojn3He876XAS35
         6waw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAXao9gJZygkW/5aRtCR3T3gYR2lcPizljJaiylFEFyM5oQ4Z0Rf
	tGfhDhrNrQAvrzTThSH6ZTsjRvmroAVdnxdFqDhrMYbB57bcvRJ9guqIMcArETyySDeA3aJVbx4
	HnQfn+scNLzVfcwfOmoo8GUg/kM20BHDcN80lXETL/oSkSYtH66OcHzLNDsO8jKZOwQ==
X-Received: by 2002:a5d:9292:: with SMTP id s18mr50343972iom.87.1554270351002;
        Tue, 02 Apr 2019 22:45:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQ7+ScGK1cfv7UHe0jgpBop44yEzOCNS/KnzwjR26pGVsN228LkXAa6hbrkUyMvErOFwje
X-Received: by 2002:a5d:9292:: with SMTP id s18mr50343956iom.87.1554270350413;
        Tue, 02 Apr 2019 22:45:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554270350; cv=none;
        d=google.com; s=arc-20160816;
        b=NkFmcJ9SggR2MS1I7tyrTgIKsiJns5cV0TfckLomQ6o7yIa9VZ8YcU7lO23zONa4s8
         isCd/4pk6rGqwK5TSTd9Y7bkRUMBefWuh3C+RXKu7Xv8kenP8NEjlyG4iGibL5j62fhZ
         IFBBoLRKN3DQS8Ec8p2GfZGM/NDUwjnbbOg/JtiAF85icCb1Yut1+A+NCWszJfmoquBU
         7ynbGyoaK67dVcqE/6q+NoNwyPECAK1hqIpyeAMSKXH+TKZ/Oz+m5x+MJqXRw4UdyN1j
         MdtR0+X1MCbsLAnYKPLBzOZGaTITcgKl9ifb8uq2woxOJl40ay8jGA2vAagPwEgAiDlP
         EqDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=9O1LLV4sT1FAfPm5rHvY3vURdVZR4h54IY5KnAtfx2g=;
        b=C2u/eqUTJFi2b/M+VSi9vSNmK/SnyY9SHirAsmm6+s3u/BTZonVJa2Dao6NaIEKMRO
         SVSgj1CL26Kxu4EpGPTJ+MOVpUwUEhZxvjN1dUXk07U+3BVasD4wt6pR8/XWRprJXr7c
         wvAkKCSNyx655vTBuw3mcbRtTDIyWmN9yvq+v8J9dIcRMA3GSKR4Duwa3+bhi/1qx+P0
         tUjcjphAhE53rCiJdIGWGF/RIsWQeaWVpSw22l10mlreis+CbFWVaYqUKRgNJAwuAhYC
         u/+09wm3qKfc+VMk7U8fTFjYG1qRmh8K3lH9/ntHOpjIcIK4V0Q3txTuRvf+cdXG8K7N
         eZkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id v9si7652417itb.51.2019.04.02.22.45.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 22:45:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) client-ip=114.179.232.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo162.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x335jlHi032156
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Wed, 3 Apr 2019 14:45:47 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x335jlLm010089;
	Wed, 3 Apr 2019 14:45:47 +0900
Received: from mail02.kamome.nec.co.jp (mail02.kamome.nec.co.jp [10.25.43.5])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x335jGb1003185;
	Wed, 3 Apr 2019 14:45:47 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.148] [10.38.151.148]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-3939739; Wed, 3 Apr 2019 14:44:36 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC20GP.gisp.nec.co.jp ([10.38.151.148]) with mapi id 14.03.0319.002; Wed, 3
 Apr 2019 14:44:36 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Oscar Salvador <osalvador@suse.de>
CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm/hugetlb: Get rid of NODEMASK_ALLOC
Thread-Topic: [PATCH] mm/hugetlb: Get rid of NODEMASK_ALLOC
Thread-Index: AQHU6VjR5Ud9L/BTCUi9Q0MuQPILkqYpVxOA
Date: Wed, 3 Apr 2019 05:44:35 +0000
Message-ID: <20190403054436.GA20228@hori.linux.bs1.fc.nec.co.jp>
References: <20190402133415.21983-1-osalvador@suse.de>
In-Reply-To: <20190402133415.21983-1-osalvador@suse.de>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.148]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <5D36004EC50BF549823C713D0A9EDB9A@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 02, 2019 at 03:34:15PM +0200, Oscar Salvador wrote:
> NODEMASK_ALLOC is used to allocate a nodemask bitmap, ant it does it by
> first determining whether it should be allocated in the stack or dinamica=
lly
> depending on NODES_SHIFT.
> Right now, it goes the dynamic path whenever the nodemask_t is above 32
> bytes.
>=20
> Although we could bump it to a reasonable value, the largest a nodemask_t
> can get is 128 bytes, so since __nr_hugepages_store_common is called from
> a rather shore stack we can just get rid of the NODEMASK_ALLOC call here.
>=20
> This reduces some code churn and complexity.
>=20
> Signed-off-by: Oscar Salvador <osalvador@suse.de>

nice cleanup.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=

