Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B608C5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 20:54:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA631218A6
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 20:54:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="NJc3a/ai"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA631218A6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D3716B0003; Tue,  2 Jul 2019 16:54:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6846B8E0003; Tue,  2 Jul 2019 16:54:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5745A8E0001; Tue,  2 Jul 2019 16:54:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 248726B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 16:54:21 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 30so120002pgk.16
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 13:54:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MGIF/a6QSZfs+BOzI8L0+66UJj0lLre51BCUjleld2Q=;
        b=tNNcRbb5JaMDsk6aBefU1Q1RZcv/yTqFQ0/Wq/XIUYfk48mCUrrdRpSENNtfid7erI
         qqFlgXmk8ayYFmorU1IYX/6sR0/eFFjKQbJdl5BW2Dm+Mem642AzvBivT7Ch/EGxUEAc
         WIMsbR7sSrLwTEv4szzIKyKdhREh03aOxqVES4Dwk/Xzbn2srUStwi0aoIOQlQd+SBL5
         n3jR7mw+0+vCHnYsYIEDWInGPV5s0Lih7d9qPLo/BXtg1pLUGtvZwQaOVrBZ8VdPQWSL
         JBNHPpVEpFLcl3LdM9MJHCNZig4wngLB67UvntZzmBR50zMHK6uBnOzGXiwUqtuB04gA
         uafg==
X-Gm-Message-State: APjAAAXX4XpMYLsl6rhRAIa3jkRZs2T1zv6RGXLwBr4UzzKfUbuchGAM
	q0UvM7BfAteGM7EjyYa0+vNc9kWgwnkTQo2+78LfNjmP2gYZsFarnr9Zv9oPq5Hytf8qZMfFFma
	cL1jCOa+uenoPS6KGk3Xzk98/XZ8SfggZPKqoDgJ+DmAaqRV0hdzRT7AtBwNj+h3BLA==
X-Received: by 2002:a17:90a:342c:: with SMTP id o41mr7849678pjb.1.1562100860622;
        Tue, 02 Jul 2019 13:54:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgfiX+D1tyHfEvpYOID8ohfJAlwPVA/FQ1z0+isVe8f6dvmNqz5+EimQf1lQ18APKR5iZ7
X-Received: by 2002:a17:90a:342c:: with SMTP id o41mr7849641pjb.1.1562100859865;
        Tue, 02 Jul 2019 13:54:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562100859; cv=none;
        d=google.com; s=arc-20160816;
        b=Sz0G+vYmsfs7oHV3+G+sTAqZ9GxfaoyaXgOdyxR7qFQWcXEunD4ca72dMzIiVkd9Op
         gzasR59Av+esCsycsltssdeUTe3/GOnaMP3Zuqt5TddSqP/gQKoGWXFcQCPgtngVc8h5
         Qym1K1rv2euWg5wLLlegRGFuJFHKThTaTBsbQkGNoMatbBv0jouM4FRzEiJlA+SxVB6G
         9DA/M+wOWih6+pK3WMn82Fg54nmRv1xcfldkNj2V6PW6zRqVNHIsfSsm4L2AvgYOdbWl
         fxjDH2mXEfTBtUdKrMwR66t4hKHJ2+MfEZGN2tOgl2cJakOyyBdJFPnQzJFtro1evXHO
         4asA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=MGIF/a6QSZfs+BOzI8L0+66UJj0lLre51BCUjleld2Q=;
        b=DGsPdhnEksa0A19zU+fFQ4TsYISbcjIBSRbE/7s7vHtm4hpm3gB/cGtvYE8hMQrDzB
         3pPmKMovPaqvmXZ3G4GxvFQuz/0rLc26RFZk8LUNel9wzYC/RUgFBMZNUOFrDbhdVZ1R
         GtmoYrLxWX1Ng7l/toq4PoqNgAWIPPETUPCp0snHQTQI/uI04oifM7ldGEid8tRtIMQ9
         Td5ylJfzM7SI38uxZJlX7wnVEzsEqt3pD0SI1qr115PGNGylc2VBsuFQaSPFexUXFhvf
         uOHI6hmeoTOZ/ILLLanMntLbpNkbfkPLtfRJOcnMxG16YjXIP27HslYnR+y1SpH8TZEX
         U1tg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="NJc3a/ai";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w186si7379142pgd.48.2019.07.02.13.54.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 13:54:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="NJc3a/ai";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3344D20673;
	Tue,  2 Jul 2019 20:54:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562100859;
	bh=rVBWY9NKk3peUyI1EC9GF70mJHGF/edO4QPbzMYTAPs=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=NJc3a/aiBmbIeNeNSP0XS9Oba/camnFTOL9hqC8zm7j1dF2QBonphwxy7DsLeJtYF
	 taFkYBHmMv1mufJj2/5bJblCqD5zSvM01FR3QX6HWCg5fFJ3YTOzltXbwqPlS9VVVr
	 MZDir0n73svKaPTv20CmYRaLCPorogn8uUu9W1GY=
Date: Tue, 2 Jul 2019 13:54:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: linux-mm@kvack.org, Stephen Rothwell <sfr@canb.auug.org.au>, Robin
 Murphy <robin.murphy@arm.com>, linux-kernel@vger.kernel.org,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH -next] mm: Mark undo_dev_pagemap as __maybe_unused
Message-Id: <20190702135418.ce51c988e88ca0d9546a2a11@linux-foundation.org>
In-Reply-To: <1562072523-22311-1-git-send-email-linux@roeck-us.net>
References: <1562072523-22311-1-git-send-email-linux@roeck-us.net>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue,  2 Jul 2019 06:02:03 -0700 Guenter Roeck <linux@roeck-us.net> wrote:

> Several mips builds generate the following build warning.
> 
> mm/gup.c:1788:13: warning: 'undo_dev_pagemap' defined but not used
> 
> The function is declared unconditionally but only called from behind
> various ifdefs. Mark it __maybe_unused.
> 
> ...
>
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1785,7 +1785,8 @@ static inline pte_t gup_get_pte(pte_t *ptep)
>  }
>  #endif /* CONFIG_GUP_GET_PTE_LOW_HIGH */
>  
> -static void undo_dev_pagemap(int *nr, int nr_start, struct page **pages)
> +static void __maybe_unused undo_dev_pagemap(int *nr, int nr_start,
> +					    struct page **pages)
>  {
>  	while ((*nr) - nr_start) {
>  		struct page *page = pages[--(*nr)];

It's not our preferred way of doing it but yes, it would be a bit of a
mess and a bit of a maintenance burden to get the ifdefs correct.

And really, __maybe_unused isn't a bad way at all - it ensures that the
function always gets build-tested and the compiler will remove it so we
don't have to play the chase-the-ifdefs game.

