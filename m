Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E111C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 12:36:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D048F2067D
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 12:35:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="agR9AvYO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D048F2067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50C0F6B0005; Tue, 13 Aug 2019 08:35:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 496496B0006; Tue, 13 Aug 2019 08:35:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35C8E6B0007; Tue, 13 Aug 2019 08:35:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0248.hostedemail.com [216.40.44.248])
	by kanga.kvack.org (Postfix) with ESMTP id 0CBD96B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:35:59 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id AB52A1CBE
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 12:35:58 +0000 (UTC)
X-FDA: 75817351596.26.toys12_6e55b11f41e4e
X-HE-Tag: toys12_6e55b11f41e4e
X-Filterd-Recvd-Size: 5594
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 12:35:58 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id e8so5597040qtp.7
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 05:35:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=S54lLa6bgYl50xMneQkBqoB3M0F5v0sM817U2bzthXY=;
        b=agR9AvYOrhFisIq3zyRg4IM/ZRdhZf5/0lqKd2pNTQa5RoGvsDs5PPhxDI9RK9Ol3C
         qf5Mt7bSLQVchVswI/LpN3Hdt+DjL7mwdWm1lQsCA1Hvf5dhov2H0jnYUWm8AOBJwhaD
         aQy2Y5h7zApILOwcTVb/pK5XYc+Y03KG7nbm7a6wJjzBgu5tk4jTHz8a5qyha8hJ8yhJ
         k38Z2rz1wQNMBxKbrr1vwAZyySgH7XW6ZSSj3keFjJ2+8Cw/Nc5nKW9dF0YTcWM8Y8GI
         uCH4ArZP7E+cApAfFDOTSvvER6PZp4dC8dQQhKcwStWa123KCF/qCHrhqTDnceK27Sm7
         YhoA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=S54lLa6bgYl50xMneQkBqoB3M0F5v0sM817U2bzthXY=;
        b=ZzYaSiQRV92Q7uojnAoNQxJir3e85XWSfhHe5aGGl9gzK4faffoUK3SBLhbuhm53uC
         jiLIdYXC9P9ucXDlBdleig1YSKjOJvbnAfnp7qvE5JGH9J8Jj4jndtqdqsBmK3ls4Vki
         hZHU4wd4E6WxnmpNLsQvyY8s3NMwxXnpmQ3/1EmTkW5GcQktKac00ZyVNPH5mcrbxb6C
         ehggF/yet6VRg7i7UFp2NoGVCE4N9wSZA9NmW8iQbGYwzI3dfU68BOgYYKCqzHiEN0GH
         qRK/X33InRX0lWfTJAvtXI0wju1RLKMxEe0E+b4duWS/sGVBfB1X7E6Knm202iDpRK4Y
         JQnw==
X-Gm-Message-State: APjAAAWPPGFXXra0XDcfNPRcAb/k18kxfgFb8ajQ+Fhwv0Ekr9nKNBfU
	SSxaffGfgHzX57M2uOnG6OGsHw==
X-Google-Smtp-Source: APXvYqxtXmnf0GGchCLA6EVm/YadIfQw8wWVCxKFsbu+A1RacfwS39mJeDS31/OUgGDLvtQ1S4X/rQ==
X-Received: by 2002:a0c:fa02:: with SMTP id q2mr5488260qvn.28.1565699757517;
        Tue, 13 Aug 2019 05:35:57 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id y25sm10208095qkj.35.2019.08.13.05.35.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 05:35:56 -0700 (PDT)
Message-ID: <1565699754.8572.8.camel@lca.pw>
Subject: Re: [PATCH v3 3/3] mm: kmemleak: Use the memory pool for early
 allocations
From: Qian Cai <cai@lca.pw>
To: Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
  Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>
Date: Tue, 13 Aug 2019 08:35:54 -0400
In-Reply-To: <20190812160642.52134-4-catalin.marinas@arm.com>
References: <20190812160642.52134-1-catalin.marinas@arm.com>
	 <20190812160642.52134-4-catalin.marinas@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-08-12 at 17:06 +0100, Catalin Marinas wrote:
> Currently kmemleak uses a static early_log buffer to trace all memory
> allocation/freeing before the slab allocator is initialised. Such early
> log is replayed during kmemleak_init() to properly initialise the
> kmemleak metadata for objects allocated up that point. With a memory
> pool that does not rely on the slab allocator, it is possible to skip
> this early log entirely.
>=20
> In order to remove the early logging, consider kmemleak_enabled =3D=3D =
1 by
> default while the kmem_cache availability is checked directly on the
> object_cache and scan_area_cache variables. The RCU callback is only
> invoked after object_cache has been initialised as we wouldn't have any
> concurrent list traversal before this.
>=20
> In order to reduce the number of callbacks before kmemleak is fully
> initialised, move the kmemleak_init() call to mm_init().
>=20
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> ---
> =C2=A0init/main.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=
=C2=A02 +-
> =C2=A0lib/Kconfig.debug |=C2=A0=C2=A011 +-
> =C2=A0mm/kmemleak.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0| 267 +++++-----------=
------------------------------
> =C2=A03 files changed, 35 insertions(+), 245 deletions(-)
>=20
> diff --git a/init/main.c b/init/main.c
> index 96f8d5af52d6..ca05e3cd7ef7 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -556,6 +556,7 @@ static void __init mm_init(void)
> =C2=A0	report_meminit();
> =C2=A0	mem_init();
> =C2=A0	kmem_cache_init();
> +	kmemleak_init();
> =C2=A0	pgtable_init();
> =C2=A0	debug_objects_mem_init();
> =C2=A0	vmalloc_init();
> @@ -740,7 +741,6 @@ asmlinkage __visible void __init start_kernel(void)
> =C2=A0		initrd_start =3D 0;
> =C2=A0	}
> =C2=A0#endif
> -	kmemleak_init();
> =C2=A0	setup_per_cpu_pageset();
> =C2=A0	numa_policy_init();
> =C2=A0	acpi_early_init();
> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> index 4d39540011e2..39df06ffd9f4 100644
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -592,17 +592,18 @@ config DEBUG_KMEMLEAK
> =C2=A0	=C2=A0=C2=A0In order to access the kmemleak file, debugfs needs =
to be
> =C2=A0	=C2=A0=C2=A0mounted (usually at /sys/kernel/debug).
> =C2=A0
> -config DEBUG_KMEMLEAK_EARLY_LOG_SIZE
> -	int "Maximum kmemleak early log entries"
> +config DEBUG_KMEMLEAK_MEM_POOL_SIZE
> +	int "Kmemleak memory pool size"
> =C2=A0	depends on DEBUG_KMEMLEAK
> =C2=A0	range 200 40000
> =C2=A0	default 16000

Hmm, this seems way too small. My previous round of testing with
kmemleak.mempool=3D524288 works quite well on all architectures.

