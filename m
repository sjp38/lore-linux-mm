Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44977C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 06:20:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C5E324B72
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 06:20:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C5E324B72
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B6896B000D; Tue,  4 Jun 2019 02:20:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 967266B0010; Tue,  4 Jun 2019 02:20:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82DFE6B0266; Tue,  4 Jun 2019 02:20:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 364E16B000D
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 02:20:47 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d27so203146eda.9
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 23:20:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=eHyQiJSise48agNV3lIMDqHOs424fUmklxkPGM5JfwU=;
        b=dBVW7oFvhKLmoIsvQXgPgz3KNP1YLcUW36Sfwx2lO24DqH/zkqsZ72OUdhHGBqvszh
         PaA8DORkRvLCgRBO6GmhJH+GlpwJwAol5s1UitzYmnKwnngCp/HDaOn8RzvF7UNkSn9e
         ctw21No8qRhB03M1Om5j5ZCVOZrArKybVzCVqhj4z3RbErkDUmfLoi8mPw8CE4D/gXTV
         q2dExgJCLDMkGqnqBhw+3w/YPiRYoGGYf3Pg5e5L1/KVrrq2PTr1z+u8Tm1FHw6f3FmA
         835/6rAIwPs1qlTElNElRhKJwHvROtg42EHFgzAq/7Nv7aPOha5L+OkTkZfMdPe0CNBI
         Ou/Q==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXd9005pjEvVfZ563gfUiSI9pvSrvn0RDWjh1M2OrHZZIfVzHB9
	0QDPpUluLHZcUix0LzI/92gd/7qBotukunfniApcUmwNm5e3nh8vLoVVxlmrz7YdDMsTRu9FTZo
	LCSf2DlufI7mCLXxrvkaIOLm2DL0Xr3yx05bbAHc9iyXCuUmK2/GYsj36wenavxI=
X-Received: by 2002:a50:fb01:: with SMTP id d1mr33347535edq.267.1559629246793;
        Mon, 03 Jun 2019 23:20:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwia1axN+ADY7NVkPPo112BinLbEhpRmL6LZTHLB+K+G272NRaNWbfbrGGmX/KqlHQ7zBIc
X-Received: by 2002:a50:fb01:: with SMTP id d1mr33347464edq.267.1559629245951;
        Mon, 03 Jun 2019 23:20:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559629245; cv=none;
        d=google.com; s=arc-20160816;
        b=WKkuKecko+9dLtdONwVXW/8BJ8zzOahhIojfKJSFA+Bkc9MCG0oFoBZLt6khWfajWC
         T/Cen0iznf+CVEoB2+vr4AfR/4yrnnTH9u5ApwY4mNuJnysPHuS17z7oWz5gncRC3mJH
         w7+JKeREIGC16E98NhfULHU266CegCagN0z5VxcsI3JnvtWSrhvgPDq/LTJe9hyD5Tnv
         1j0dh9yta83DVY2iMjSxK6M0ZsWDJ+OLh6CrNZU1O7J2n4zm1aKN5f5afZ0o9fKnu63W
         bofzhUhrbSyjB2HK/zJwyM2BrknNJnT+IcZ4ETS2r3tUQr3D8hLE5W8jmtUqRGhd1X1e
         EoVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=eHyQiJSise48agNV3lIMDqHOs424fUmklxkPGM5JfwU=;
        b=as7moBWAy05AJKQSCEXVOU7NUkSOSam5mIkopoFnx/cmSE+cNcFLGOceulsi+/VL/3
         TfRDlGZiV6UTtoajtyPbVznXepfvJkFzi9h4HNyVKiqm8PjuL3z7Q9Nm/K3MtF9C3Ade
         oajF7UNe63rcW/NJ7LWqHLUUFh/8evX8yXw2p5DBZMvECD64TMLKav8HjIrvTrMmhPF0
         cqms85wZxokTNwujNfhB1+xQxdaagh2t/q0oIoWfsPz9Ttv1DThs9CnG8GWPmIWz/hqC
         wGBYvnVn4Qj/mdPfXYC8oRkuTpT4HwsWzkfGeykivOMl/mFfjFrFHzeh7FtsegzKeFoC
         Fs/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id 39si6401214edr.449.2019.06.03.23.20.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 23:20:45 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.197;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from [192.168.0.12] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 49FAD1C0009;
	Tue,  4 Jun 2019 06:20:38 +0000 (UTC)
Subject: Re: [PATCH v4 05/14] arm64, mm: Make randomization selected by
 generic topdown mmap layout
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Albert Ou <aou@eecs.berkeley.edu>, Kees Cook <keescook@chromium.org>,
 James Hogan <jhogan@kernel.org>, Palmer Dabbelt <palmer@sifive.com>,
 Will Deacon <will.deacon@arm.com>, Russell King <linux@armlinux.org.uk>,
 Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, Paul Burton <paul.burton@mips.com>,
 linux-riscv@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>,
 linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-mips@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
 linux-arm-kernel@lists.infradead.org, Luis Chamberlain <mcgrof@kernel.org>
References: <20190526134746.9315-1-alex@ghiti.fr>
 <20190526134746.9315-6-alex@ghiti.fr>
 <20190603174001.GL63283@arrakis.emea.arm.com>
From: Alex Ghiti <alex@ghiti.fr>
Message-ID: <e8dab94d-679e-8898-033e-3b5dbf0cc044@ghiti.fr>
Date: Tue, 4 Jun 2019 02:20:38 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190603174001.GL63283@arrakis.emea.arm.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: sv-FI
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000004, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/3/19 1:40 PM, Catalin Marinas wrote:
> On Sun, May 26, 2019 at 09:47:37AM -0400, Alexandre Ghiti wrote:
>> This commits selects ARCH_HAS_ELF_RANDOMIZE when an arch uses the generic
>> topdown mmap layout functions so that this security feature is on by
>> default.
>> Note that this commit also removes the possibility for arm64 to have elf
>> randomization and no MMU: without MMU, the security added by randomization
>> is worth nothing.
> Not planning on this anytime soon ;).


Great :) Thanks for your time,

Alex


>
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
>
> _______________________________________________
> linux-riscv mailing list
> linux-riscv@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-riscv

