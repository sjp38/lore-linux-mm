Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47937C28CC7
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 09:08:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CEDE926232
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 09:08:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="OFyk4NY4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEDE926232
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F7776B026C; Mon,  3 Jun 2019 05:08:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A74B6B026D; Mon,  3 Jun 2019 05:08:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 496276B026E; Mon,  3 Jun 2019 05:08:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 10A076B026C
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 05:08:02 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id y9so2133240plp.12
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 02:08:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to;
        bh=h6Fj2ozHuj77zgS40GFazXvJc+FDsN3Yq/DTDWaWFpw=;
        b=GLW0Yegqg0/A4YHQJcqnQ5MyP5aAiyNjAskzFychdgcn0UZWOCulEzNPJSqm2UjtJf
         DmzNV7C4X3DZbw8Z5AqbFuTXxCiEkuoIg0MSSbIycp0Axa5VAA1P2SgsK1W3UPb7IxVd
         LmqRkDWNDitwa0tHie9m550mAVgPU0c0XtgrOQXhnF8/ZUUvlyFusZdDiWRGJGXWkFHe
         CppmiBWgg4K+9TTVhTbBRWDhTc8dXCsvE4uMdzE1RTrgsAlHB+hFg9xoo5VjT95OXGHb
         JkqOzDvRXh+8kNeN4F9krhiY2hPYQUkMPCm+jEp31LxxeV68MdJ0sy4+SCArx1Vwa2GZ
         OKuw==
X-Gm-Message-State: APjAAAXrRdaRwefNNa+OvnpjMobyXN9EBvYCS7R4tjDDWYQXZDQVoP0b
	9cIOOr/acB4amBa/6ZBoVdbIZPevaOTQwwueCpA2Tuu9MS0PPiUsSeWILR5Ah0RlsvhzTHTmd6/
	H4/g+uhvqKKGLUGOx7tXj6t2MLoqg3qfVnKw0IVGRI0dN4j9V1I9fZIyuLW4pXbNPJw==
X-Received: by 2002:a17:90a:c503:: with SMTP id k3mr28900699pjt.46.1559552881489;
        Mon, 03 Jun 2019 02:08:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxh28w3lU30tToJnIg3lVtYVymetPvs4lgIsFLlKzesx0dAQBDe6cjPM3iPXEOGTI2PfRXa
X-Received: by 2002:a17:90a:c503:: with SMTP id k3mr28900647pjt.46.1559552880577;
        Mon, 03 Jun 2019 02:08:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559552880; cv=none;
        d=google.com; s=arc-20160816;
        b=rfN2xe4BoUS+v8Ke9txvPN1dXFFE8W7vhd3qZZEqUzDYR5n9Ug/JFvQhFIyiOJ8iu1
         +vDoarmNsc+Sgn2fnyrUAazsa3I03LcXy8IKX/VwTcbTpS8HAw3sJ/fSzKnb2hEoBjVK
         iMulgRkKsygxKD82cM1EdtIKRsQrayXwpjXw/s4leRbTMjy+h3gwm+gr3nkv7l+ebwU1
         QoYy41xP4uePH7gte4b1bZuqRoeLYbT5fNAM8wPqm+cp8yn5ZJ3SmB1W1nWNWe1EGobc
         1cK19kEygu09aur+Tr+b8xrXva2cktkjTmyucH2ApUSg3kKP9LRZPhqe54Xaazuuy02Y
         BQ7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=h6Fj2ozHuj77zgS40GFazXvJc+FDsN3Yq/DTDWaWFpw=;
        b=l1jeb7D7qDyZ7njsZRYfxYQXaUHwNaImd2s344+8mM54CYJg7/5J7YaYDKaBHLQ8Qm
         Th4c/j+cl9+hONYicZrPk/c8STNjUQjHD11qPeHLGnqekFKm0B+O/s3YQonW6nUXcNss
         v9jQ9xFF2r6cNIc/KyC8UH8PwTNfSt37VGDBbYuDuOT7hial/sBXiFzqcew+qVaq4LUk
         rI7bG1xFllZtfdrF3qf+ho/InRNw3VgpdP7V92tzKVEIv57UbYUz7ftAKM/oC+w9n5Z4
         C+PbkgGV+88iDozEbld9UPCdqIgyEin99dPv1auFRXv/w72D0yPucAbsNDOEbtwC+i8d
         KNbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=OFyk4NY4;
       spf=pass (google.com: domain of krzk@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=krzk@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h61si19991728plb.256.2019.06.03.02.08.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 02:08:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of krzk@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=OFyk4NY4;
       spf=pass (google.com: domain of krzk@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=krzk@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-lj1-f179.google.com (mail-lj1-f179.google.com [209.85.208.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D78F7271D3
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 09:07:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559552880;
	bh=Rzr6gfXjAXNtZ72i1f03ZP5xQADxqoyjKQjlDsDgnOU=;
	h=From:Date:Subject:To:From;
	b=OFyk4NY4DclC0oTHFd+eXw4x0tlpPhoixH2tmw3kBXKOXH5TYz61qqu8iPuV6Oxov
	 pUaAnT2yl/SpS/pTBkp8RfXYzmGPLR5VVU8Rq3Bsvowc2B50/wekJgJPg8z8tp5OC0
	 3dySqY9w+R7b6avLDJk8xQJPQ038nr55Pc74dKLs=
Received: by mail-lj1-f179.google.com with SMTP id j24so15450924ljg.1
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 02:07:59 -0700 (PDT)
X-Received: by 2002:a2e:980e:: with SMTP id a14mr2097047ljj.60.1559552878019;
 Mon, 03 Jun 2019 02:07:58 -0700 (PDT)
MIME-Version: 1.0
From: Krzysztof Kozlowski <krzk@kernel.org>
Date: Mon, 3 Jun 2019 11:07:46 +0200
X-Gmail-Original-Message-ID: <CAJKOXPcTVpLtSSs=Q0G3fQgXYoVa=kHxWcWXyvS13ie73ByZBw@mail.gmail.com>
Message-ID: <CAJKOXPcTVpLtSSs=Q0G3fQgXYoVa=kHxWcWXyvS13ie73ByZBw@mail.gmail.com>
Subject: [BUG BISECT] bug mm/vmalloc.c:470 (mm/vmalloc.c: get rid of one
 single unlink_va() when merge)
To: Andrew Morton <akpm@linux-foundation.org>, "Uladzislau Rezki (Sony)" <urezki@gmail.com>, 
	Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, 
	Marek Szyprowski <m.szyprowski@samsung.com>, 
	"linux-samsung-soc@vger.kernel.org" <linux-samsung-soc@vger.kernel.org>, linux-kernel@vger.kernel.org, 
	Stephen Rothwell <sfr@canb.auug.org.au>, Hillf Danton <hdanton@sina.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On recent next I see bugs during boot (after bringing up user-space or
during reboot):
kernel BUG at ../mm/vmalloc.c:470!
On all my boards. On QEMU I see something similar, although the
message is "Internal error: Oops - undefined instruction: 0 [#1] ARM",

The calltrace is:
[   34.565126] [<c0275c9c>] (__free_vmap_area) from [<c0276044>]
(__purge_vmap_area_lazy+0xd0/0x170)
[   34.573963] [<c0276044>] (__purge_vmap_area_lazy) from [<c0276d50>]
(_vm_unmap_aliases+0x1fc/0x244)
[   34.582974] [<c0276d50>] (_vm_unmap_aliases) from [<c0279500>]
(__vunmap+0x170/0x200)
[   34.590770] [<c0279500>] (__vunmap) from [<c01d5a70>]
(do_free_init+0x40/0x5c)
[   34.597955] [<c01d5a70>] (do_free_init) from [<c01478f4>]
(process_one_work+0x228/0x810)
[   34.606018] [<c01478f4>] (process_one_work) from [<c0147f0c>]
(worker_thread+0x30/0x570)
[   34.614077] [<c0147f0c>] (worker_thread) from [<c014e8b4>]
(kthread+0x134/0x164)
[   34.621438] [<c014e8b4>] (kthread) from [<c01010b4>]
(ret_from_fork+0x14/0x20)

Full log here:
https://krzk.eu/#/builders/1/builds/3356/steps/14/logs/serial0
https://krzk.eu/#/builders/22/builds/1118/steps/35/logs/serial0

Bisect pointed to:
728e0fbf263e3ed359c10cb13623390564102881 is the first bad commit
commit 728e0fbf263e3ed359c10cb13623390564102881
Author: Uladzislau Rezki (Sony) <urezki@gmail.com>
Date:   Sat Jun 1 12:20:19 2019 +1000
    mm/vmalloc.c: get rid of one single unlink_va() when merge

Boards:
1. Arch ARM Linux
2. exynos_defconfig
3. Exynos boards (Odroid XU3, etc), ARMv7, octa-core (Cortex-A7+A15),
Exynos5422 SoC
4. Systemd: v239, static IP set in kernel command line

Best regards,
Krzysztof

