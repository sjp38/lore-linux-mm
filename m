Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 464DAC4321B
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 12:10:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C024121734
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 12:10:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C024121734
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B8566B0007; Tue, 11 Jun 2019 08:10:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 368876B0008; Tue, 11 Jun 2019 08:10:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 258446B000A; Tue, 11 Jun 2019 08:10:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E5F7C6B0007
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 08:10:49 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q6so7642795pll.22
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 05:10:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=ZW2c7nbA67j8AyBBGguxcQmXkAlMlzwIBru0l5U7iMs=;
        b=Z5ucu1Ya4AzSWilg4HJnTEhLcDOpArqSBeMiomPVTanu39yAZkDjWECnbugafpQdDt
         zCp+33i1ncPuLSy3FPbOF2G6dZvOd0i0rv1bTJH1Udz9A9Zt2pkLzqqoArhKlV0lM+fY
         Ly+3y8PLjN6bAMxcj7AOvtzU3/Sx9JjK0Wp6QQ6neGjOkd+D2sfW0/A5HY96SdKVvu5r
         uz+qm7JbLZ9+iVf8df/H4Fh+wBxNuxKAAxDHLds8+6F+37I5B3aR2OXrjaTX+/NYZZKN
         mkKOz0VKi9MYWZtUIBLUHd9y/9Ti34WXtZDmPH0dt+Cnor/gUcz3XlwvGEndvbLo27jz
         Sjbw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of cg.chen@huawei.com designates 45.249.212.188 as permitted sender) smtp.mailfrom=cg.chen@huawei.com
X-Gm-Message-State: APjAAAU8efeTb9uw9DVDLVJ8CkjBr9IfBLrM2w1Sckv1BXXV1sWPNhhD
	AnHmqefxJc18YSs0MUHMEfHxujZQ7/Yjj+os1nEgYdM3vNl20KVwQmZGJliogl44N6hPMmoQlHX
	sUw37jRNVrt+YI2o3LKi68ndcyaxVnQigc8ynkSMbIO2ygEcV5eTf7x8l5VMvyekvyA==
X-Received: by 2002:a17:902:8209:: with SMTP id x9mr76177296pln.327.1560255049581;
        Tue, 11 Jun 2019 05:10:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcT3pBREK38yqqicUL+vOsqXNUABXuK4aghcKyCmloOF6xUfoQ2jniEth2S7j7pG7gsw8L
X-Received: by 2002:a17:902:8209:: with SMTP id x9mr76177250pln.327.1560255048898;
        Tue, 11 Jun 2019 05:10:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560255048; cv=none;
        d=google.com; s=arc-20160816;
        b=EN4gNz0KW4lbhhW2fOPTrV98GkZvOrWuLXe03HDLpcewYmoqduqziDSXDua5zwA2VM
         jFMImPgkAE+CGOU/SUGO3XELjahtguZ9x3YLwxPKNj99NlFBrzlUPa8pu31B6lmJeuur
         eTPqN2Agx7OQ+49LHShgtLl2HS8Tz20m+nzaC16UbfIZ0IMX0eaO/aVaPl/yZ5OMk/lq
         iQhIBzwWObAE7G8yp0mUEeFgXzSD0Jp5eosldocHwDs0sLXPLeCBkQNp7AsMs3Bfq5Q8
         SaIRZnww+D1vrTc5PeZ+LSEP1qWAewt98BzkwvHVpZJ5Iw4+i+H8JdGcblwh9Lle6vfL
         tfTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from;
        bh=ZW2c7nbA67j8AyBBGguxcQmXkAlMlzwIBru0l5U7iMs=;
        b=mjmXkbP20cHBFRh4oIOqnlcwWpGrCghYrHsfueD8rwJuvrQE34Vt1N/S9yqMNVlg1e
         OG4pzQiQ+iB/7QcErHbCArfVlgNO6strY65IKNGeZGhgEeBZ+nfHmJKoMTi5KRc3PQ5w
         nvsGAuxlCtvgQg6f/cWGTOLUWYftOe+apYCesAE85a7+QSHrc0suTQH8Rm1hiJ+YlKLA
         JTlFZNjPtrc5AsG9OoaHHIkUXAt1CukjoJ7Ra7Yn3i8xg+ALMYnM7iBhCst5oDMJvSeB
         Z/OmHZr94OglF+UQfhcUV4aWeuO8tjowOd5mi0a5ACifEMp+O1opW3wwnlnx+2GtZZs4
         mvQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of cg.chen@huawei.com designates 45.249.212.188 as permitted sender) smtp.mailfrom=cg.chen@huawei.com
Received: from huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id 140si13108908pfy.113.2019.06.11.05.10.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 05:10:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of cg.chen@huawei.com designates 45.249.212.188 as permitted sender) client-ip=45.249.212.188;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of cg.chen@huawei.com designates 45.249.212.188 as permitted sender) smtp.mailfrom=cg.chen@huawei.com
Received: from dggemi403-hub.china.huawei.com (unknown [172.30.72.56])
	by Forcepoint Email with ESMTP id 5299EAC9313952D287A7;
	Tue, 11 Jun 2019 20:10:47 +0800 (CST)
Received: from DGGEMI529-MBS.china.huawei.com ([169.254.5.79]) by
 dggemi403-hub.china.huawei.com ([10.3.17.136]) with mapi id 14.03.0415.000;
 Tue, 11 Jun 2019 20:10:37 +0800
From: "Chengang (L)" <cg.chen@huawei.com>
To: Wei Yang <richard.weiyang@gmail.com>
CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com"
	<mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "osalvador@suse.de"
	<osalvador@suse.de>, "pavel.tatashin@microsoft.com"
	<pavel.tatashin@microsoft.com>, "mgorman@techsingularity.net"
	<mgorman@techsingularity.net>, "rppt@linux.ibm.com" <rppt@linux.ibm.com>,
	"alexander.h.duyck@linux.intel.com" <alexander.h.duyck@linux.intel.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm: align up min_free_kbytes to multipy of 4
Thread-Topic: [PATCH] mm: align up min_free_kbytes to multipy of 4
Thread-Index: AdUgTeBw9ORISFAfQqiB/YjSHqoFpg==
Date: Tue, 11 Jun 2019 12:10:36 +0000
Message-ID: <D27E5778F399414A8B5D5F672064BAD8B3E5FB53@dggemi529-mbs.china.huawei.com>
Accept-Language: en-US
Content-Language: zh-CN
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.74.216.69]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Wei Yang

>On Sun, Jun 09, 2019 at 05:10:28PM +0800, ChenGang wrote:
>>Usually the value of min_free_kbytes is multiply of 4, and in this case=20
>>,the right shift is ok.
>>But if it's not, the right-shifting operation will lose the low 2 bits,

>But PAGE_SHIFT is not always 12.

	You are right, and this is not the key point, this is just an example.

>>and this cause kernel don't reserve enough memory.
>>So it's necessary to align the value of min_free_kbytes to multiply of 4.
>>For example, if min_free_kbytes is 64, then should keep 16 pages, but=20
>>if min_free_kbytes is 65 or 66, then should keep 17 pages.
>>
>>Signed-off-by: ChenGang <cg.chen@huawei.com>
>>---
>> mm/page_alloc.c | 3 ++-
>> 1 file changed, 2 insertions(+), 1 deletion(-)
>>
>>diff --git a/mm/page_alloc.c b/mm/page_alloc.c index d66bc8a..1baeeba=20
>>100644
>>--- a/mm/page_alloc.c
>>+++ b/mm/page_alloc.c
>>@@ -7611,7 +7611,8 @@ static void setup_per_zone_lowmem_reserve(void)
>>=20
>> static void __setup_per_zone_wmarks(void)  {
>>-	unsigned long pages_min =3D min_free_kbytes >> (PAGE_SHIFT - 10);
>>+	unsigned long pages_min =3D
>>+		(PAGE_ALIGN(min_free_kbytes * 1024) / 1024) >> (PAGE_SHIFT - 10);

>In my mind, pages_min is an estimated value. Do we need to be so precise?

This is the key point, user can set this value through interface/proc/sys/v=
m/min_free_kbytes, so a bit more precise is better.

>> 	unsigned long lowmem_pages =3D 0;
>> 	struct zone *zone;
>> 	unsigned long flags;
>>--
>>1.8.5.6

>--
>Wei Yang
>Help you, Help me

