Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59CB4C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 07:19:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CCEC2084B
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 07:19:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CCEC2084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A44296B0010; Wed, 10 Apr 2019 03:19:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CA326B0266; Wed, 10 Apr 2019 03:19:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86CEC6B0269; Wed, 10 Apr 2019 03:19:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 47B786B0010
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 03:19:07 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f9so750854edy.4
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 00:19:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=GYQ0m/WbBui6hDBVZIasXKkIv+G5qz2dERX6Typpuac=;
        b=eeHdzbOc8fY21cE12m3F7yPU9onj8Olzc8VtaeTt7cheHgfVKyqMDoNgw7GbiBdgAO
         bJaHkgdPY/WQT0XcW6K1FnqBaE4iKlnWfe0aWMMvXxVMx39chJZ1NKWdN40+/Df4kun8
         x909zZcMAv6nxyD35pJx7Ueh1FZMZuPIHOSiXyiTZgvdznSgHcyNfUSkpS6ppkdOuKEn
         ZYMBws0REu3OwkKuL4pOySbw7UeFvvUKkWgpHE4j2xew38kU8o2UIbMWlx5CFQnx07mv
         UyBj7mm3OUU2CTOkYwrU+QiMALrFlrzhVjedpqFsW4q/cxUvdUf1LuaBw35yJUZSCPXy
         FOVw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.230 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAV3QRX0Wv7VgrD3hFQUGDRNoVh/X5vYX/nsQ7+gYqHSnSGorQd3
	OlCPst0Dm71CX9qfYbENG6Asnug58I0i7UBBb0+Aof9lCQhcCJzJ4NS8xsFY2awZtZbfUG165Du
	1/bNHTjbiGHunCgbw6BUSu88gd+XpleJLeYB8xdB1ur3hlfEMLmB16QbQ5EP0RzE=
X-Received: by 2002:a50:e712:: with SMTP id a18mr25728819edn.155.1554880746864;
        Wed, 10 Apr 2019 00:19:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLzbBByH84uIM3mNOLxABcO/FsJzBMaVP2bmI6ib7O9kjH3sFVi+JoBBRwdwSO+RPPUu96
X-Received: by 2002:a50:e712:: with SMTP id a18mr25728790edn.155.1554880746168;
        Wed, 10 Apr 2019 00:19:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554880746; cv=none;
        d=google.com; s=arc-20160816;
        b=lzUIoXw8bsS/ImkW+gIlJzw2Zr0DlvdXC0bsXEAWYVqz5moiFaw3WRGzylZ2WVMro/
         XtjYkDuUK+RDqAnnWpmh2ZbF0wOn3UbUD3pVoV6zG8k8qlmSslzRhBJKeVsppmAAMmYw
         ZA70GR2s5Lvoi87YBdjWzZPvF0dswdG9wAyDSLGIvWJFvUAsL/B2MY34zQnPCHe1D+hB
         7Ulcu3EvhSbamD28nIsDMNhXdA7LzmG2g22NoU/C/Tds3UXBClETLEYqwmPjSfneOH4T
         ehl13YSOj/c8wG1UzzBaOs84K0jfVH8p0NTMPu1wLMbyDukBeQ4frMWlFKvHL+FQlBCO
         celA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=GYQ0m/WbBui6hDBVZIasXKkIv+G5qz2dERX6Typpuac=;
        b=JL8fu4WWTrDG5Xab6iaFOllCLnGsplH3dmdGOrQjC0diMoSk8AlcuDW+qIMRdlnMlu
         SHtStrg0r1HTO7ORCh20MewOYYnKR8yMa7SeD0albHWTQncFgxEXQBFBzcdA6J017Xbq
         V4/KxdRTF0EZblxt44mYQxyVJHxb0xCTnXWYuzKeaCqKgguAm2WDKyA0l+dx6G3J9Lns
         VvF8jP8Mb6+LTk1uTVYDFwWCszdUNqRR07js5culG/aYqxMSobJ6PgVN1chrKCSsxd4P
         BoVCotEDHEppGNkGuQmTbm2HHTRFKTFsbSLYAV0O5yq1A6bEHX3cVkdN+gonzXivKFum
         c2TA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.230 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay10.mail.gandi.net (relay10.mail.gandi.net. [217.70.178.230])
        by mx.google.com with ESMTPS id z7si342772edr.14.2019.04.10.00.19.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 10 Apr 2019 00:19:06 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.230 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.230;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.230 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay10.mail.gandi.net (Postfix) with ESMTPSA id 857E4240009;
	Wed, 10 Apr 2019 07:19:01 +0000 (UTC)
Subject: Re: [PATCH v2 1/5] mm, fs: Move randomize_stack_top from fs to mm
To: Christoph Hellwig <hch@infradead.org>
Cc: Albert Ou <aou@eecs.berkeley.edu>, Kees Cook <keescook@chromium.org>,
 Catalin Marinas <catalin.marinas@arm.com>, Palmer Dabbelt
 <palmer@sifive.com>, Will Deacon <will.deacon@arm.com>,
 Russell King <linux@armlinux.org.uk>, Ralf Baechle <ralf@linux-mips.org>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Paul Burton <paul.burton@mips.com>, Alexander Viro
 <viro@zeniv.linux.org.uk>, James Hogan <jhogan@kernel.org>,
 linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-mips@vger.kernel.org, linux-riscv@lists.infradead.org,
 linux-arm-kernel@lists.infradead.org, Luis Chamberlain <mcgrof@kernel.org>
References: <20190404055128.24330-1-alex@ghiti.fr>
 <20190404055128.24330-2-alex@ghiti.fr> <20190410065437.GB2942@infradead.org>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <a67eeb56-216e-69a0-5905-bfd8017879d2@ghiti.fr>
Date: Wed, 10 Apr 2019 09:18:08 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.5.2
MIME-Version: 1.0
In-Reply-To: <20190410065437.GB2942@infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: fr
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000105, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04/10/2019 08:54 AM, Christoph Hellwig wrote:
> Looks good,
>
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Thanks Christoph,

Alex

