Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EDE3C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 20:17:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 338F021E6E
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 20:17:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="sEN1paER"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 338F021E6E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C12076B0007; Wed,  7 Aug 2019 16:17:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC2586B0008; Wed,  7 Aug 2019 16:17:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD86F6B000A; Wed,  7 Aug 2019 16:17:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75B886B0007
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 16:17:01 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id j96so8098995plb.5
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 13:17:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XpaIVnkd/BjfYjmfO2aXpXQJdXfWej63oBAOIpZvzZY=;
        b=OXBbgLKMZCGHqnv6JbcrSaF+zK/OuQQdCKvRrjXg4cgWXTnkk/n0j8e5PIc4sAQyhE
         G5QSsm3uKVMUoTyX0RKIq2lLlSlq4EOG38yvOSYIXXNWioT2PeDddZpTNvP0tlCNdEgl
         blJ8UkVPQf6CbLG8ay5CWTCnceDBQZGsXmAaZVJemNKtzgUJR6CLQ7zYo7dgahPp8vk3
         3/xA7vnpOr3d3Kib9MGCephAS1+QOgWvBD/1folU/UQwjN8iV9uZBE5kztH6aKDIetU3
         EUVo98XUhoFSETbA+Z7YZyAkpQcXFooyRe1YKsluOwPYXFtbOSOINVpxddk64ghc196x
         1Z0w==
X-Gm-Message-State: APjAAAVlV+teLhg5Q6gscV7puhlOPoK4V3ox6DwI6gp8PRb/6xNtrmpl
	L/YFSMW8MYqLgSzJatJuHHSdgKLBelGtsf/KUOjcxHTvn8lszIq5FZWbzdGi86uROh/tK2nQ1cI
	eBbOVg2IQivrpbL1qHxJ/rXoej0ySM5voRZTnv3jlxoVtQBTzGSt0gsKzTADAl9HenA==
X-Received: by 2002:a63:3006:: with SMTP id w6mr9360158pgw.440.1565209020997;
        Wed, 07 Aug 2019 13:17:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2QXnjTCJ9CdEDL6tRzdIlJEZ8pypGSs1XXoQkSAR/XvaanBu7kq4m8lt0/DTODyoQ234z
X-Received: by 2002:a63:3006:: with SMTP id w6mr9360115pgw.440.1565209020232;
        Wed, 07 Aug 2019 13:17:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565209020; cv=none;
        d=google.com; s=arc-20160816;
        b=HTG+VeK3SApfAuWUZiU58GvjHENplbssnbvQID7lCAHuUex3HWR875n5O+iyqeMHj6
         ZS0n9ynbjnYnT2urkXOU5N0rJWXCgebq4UiLckvIqDzyPl1pWuBj6Pst2PmZG0MYtfP1
         6bdu7pfOW/nWNi98jVUpARRcbQrbu4CQ6ZaHj5HKQ9HKwsrOvxbp1AahD7rIufAr6w6z
         f2gnPViTlgAk1LygUgUSzTTFeKw3+JbWdJTKDTyQJJC/0blaD9Ad7N86SCOJu+zqP8Vg
         xGnUjrFWYi/p9zjNxlkU08aM3hI2cllllRAm1egfcvF1Q/9cfCjwrQp66FmJ9qrCSuLg
         cokw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=XpaIVnkd/BjfYjmfO2aXpXQJdXfWej63oBAOIpZvzZY=;
        b=vmi128TaxtbJEcdIvV/HOUSt2ERpg4l77Rgr6vLp4zki+tEqxgVGXFgBgby9zC6mXW
         7nVJo4kchNERA93AiCe1270J4H/0xJo6G14D4RG2a8nngcudZamHyF31rw8d3txPNHsc
         uFC6jJAVV6aNkTl/kW890GwyLfQ1L6aPP2hPkZgysYWeXNtDuCem8nivHSmKUOn+ZmJ/
         wTM7OCH7irdAh8UZYOl+HuU7ZJG8zpYaMf7736ccLj2swh5kF4ny2X7q/xaRURGIKLHI
         QEBX851je744e0t+BWGxbq5kts5dKm7zXL32sLNiiegJNcWamvyGZ5tIUaItL0wR45E1
         Xhyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=sEN1paER;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w2si49507179pfi.183.2019.08.07.13.17.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 13:17:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=sEN1paER;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2EAC82199C;
	Wed,  7 Aug 2019 20:16:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565209019;
	bh=9jrCLwX3LNqceRPrIp1jyjebmoHx3o9gZO1ZatQ4skM=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=sEN1paERUMluEqczWXfNlPMKbSdmYQaq4T7rTni0CxSxEnrjjHKQ765sgQWu8A8s0
	 QKx24YVdqUtvGPcVbdAJxRFJMxYJyV6Ah+0UPLJtP5uaP8snDxXhkkuBKnRyRw75Aq
	 iNGGe6IBLOd1dbfd+9eQdQKz0RAljH5GsNO+CLMo=
Date: Wed, 7 Aug 2019 13:16:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Steven Price <steven.price@arm.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>, x86@kernel.org, Arnd Bergmann
 <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Peter Zijlstra
 <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave
 Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse
 <jglisse@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov
 <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin"
 <hpa@zytor.com>, James Morse <james.morse@arm.com>, Thomas Gleixner
 <tglx@linutronix.de>, Will Deacon <will@kernel.org>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>, "Kirill A. Shutemov"
 <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v10 20/22] x86: mm: Convert dump_pagetables to use
 walk_page_range
Message-Id: <20190807131658.08793793a97fa4310af4f495@linux-foundation.org>
In-Reply-To: <066fa4ca-5a46-ba86-607f-9c3e16f79cde@arm.com>
References: <20190731154603.41797-1-steven.price@arm.com>
	<20190731154603.41797-21-steven.price@arm.com>
	<20190806165823.3f735b45a7c4163aca20a767@linux-foundation.org>
	<066fa4ca-5a46-ba86-607f-9c3e16f79cde@arm.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Aug 2019 13:58:21 +0100 Steven Price <steven.price@arm.com> wrote:

> > ./arch/x86/include/asm/pgtable_64_types.h:56:22: error: initializer element is not constant
> >  #define PTRS_PER_PGD 512
> >                       ^
> 
> This is very unhelpful of GCC - it's actually PTRS_PER_P4D which isn't
> constant!

Well.  You had every right to assume that an all-caps macro is a
compile-time constant.

We are innocent victims of Kirill's c65e774fb3f6af2 ("x86/mm: Make
PGDIR_SHIFT and PTRS_PER_P4D variable") which lazily converted these
macros into runtime-only, under some Kconfig settings.  It should have
changed those macros into static inlined lower-case functions.

