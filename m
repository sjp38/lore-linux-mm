Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8345FC48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:47:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51C6220644
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:47:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51C6220644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F03746B0003; Tue, 25 Jun 2019 03:47:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB3D18E0003; Tue, 25 Jun 2019 03:47:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF1058E0002; Tue, 25 Jun 2019 03:47:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9665D6B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 03:47:22 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id 17so222406wmj.3
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 00:47:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DPpKHbOhMs3h6I3GZ/QnVIHiyr7HOEOv2IYIYAhQBQw=;
        b=FCrAf7kTWroXLzkxt/vzBGVo1smGhoeb1nz81f4AP3vvt1QqGsiFCuHVaF+R9dnygD
         WQlutyjHloIOtHbTGulkf4lz3GnSRIxEjqgviGCxQdDnAcxJkcy3LHIzzoXPHj9II434
         HMBsuEzYw8f95Pp+Mj714BtDZN3sXrcJc9jPECiE8wL5Z/dWo8ohc7sPChTXgMaHoCmf
         3DTvi4QgNH28fLNmqEkTZbnWKhlujK17ps68EaT6wYTnv5e88eEFCvCT0PnjrkmEHk+x
         e1xmppM9zH+XWOMS8tQiEsCjNkKkSuvgZpzTlsCbcEN7hOx9BByL1vE3Q/8bskPP/Rhe
         sfig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVNucTIHPLBXtzCmS2MD/BjHyI90lQ46ljC627xmMONb70Zg+1K
	dOxypzApfdOAX2cYOVKcAwFRPBG1IjcJWsKlqLKVvJ0dBH0i1MH2UhCcKzdsEAX00SRhkeFEzf+
	X6R/MbZa5DtThm2jKXTKYwpR3sNoARG5Uwm9pOAqMomlgkOvjPHDjWjPJtlpA5K3sSw==
X-Received: by 2002:a05:600c:2311:: with SMTP id 17mr18161972wmo.18.1561448842201;
        Tue, 25 Jun 2019 00:47:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7PfL7bHWQYA4b3PgEGw/rcscnKE934eW8NUvV/07OiVIuPrcNOccewVl69JL5dBQJC9qW
X-Received: by 2002:a05:600c:2311:: with SMTP id 17mr18161945wmo.18.1561448841535;
        Tue, 25 Jun 2019 00:47:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561448841; cv=none;
        d=google.com; s=arc-20160816;
        b=bXQbk5RboYoH3EROSdFjE7zLajjOvsK12uN3AKYLbFOw6WukbYL77ak6eoVyzmjL8m
         I8n3rBOm8bETAqtF1hU0qTBGBlaYRhpi0lkAKbl8kCXUZEEzE38X13nHo50+6my0HmEb
         9z7/ryG7ZsQ5r9wOLnucHmr5Fu+SGZduGBpUKq+ykTYNBnXLnOhx+umk3Wsnt4x+ymWu
         Br6TH01buiOqBj68ejhCtpl3592XRvCWqy55PYtkmgL/vlVX7Bmw1hku3CEH/HA61ZST
         gf/zSEMx52fQZfE6+aCUe4cl7QaPBVnxuEYmPi/S0OePgKOail/31OV9CLBllbl/gwPo
         3cEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=DPpKHbOhMs3h6I3GZ/QnVIHiyr7HOEOv2IYIYAhQBQw=;
        b=HD1xLgfQPF0tvtUaKxH0tX1rbQqxTJghwvZOCeUARtpE5AKC95rwd5rbSwq2VM6wiU
         qkt1GgaQezUFgwlBJ/1rAHBy0rGGia2F4xG4JherKI2TU9AkpwWqpYicaAg7+YEXN6gw
         ODZdY5fYbLIBFyfQyGsfa0UwbL4u1MVGhby1+tFrlNucKU6ArvqjUvF8t2lobKKdtbjo
         K7W6VkEKFwusNFOwV8HqJYRZYbe4d7WVrzygb5zDNLGAJD/9emKSONjv+6B9iJirO/PY
         wrY+jUOVuG5jPnqg21cev92perykgzzEVTPygroKoVeobOrvdKBu94tt04BiRYKsRRwj
         XTTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id t2si10721396wrs.222.2019.06.25.00.47.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 00:47:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 3C8A768B02; Tue, 25 Jun 2019 09:46:50 +0200 (CEST)
Date: Tue, 25 Jun 2019 09:46:49 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@lst.de>, Kamal Dasu <kdasu.kdev@gmail.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 04/16] MIPS: use the generic get_user_pages_fast code
Message-ID: <20190625074649.GD30815@lst.de>
References: <20190611144102.8848-1-hch@lst.de> <20190611144102.8848-5-hch@lst.de> <20190621140542.GO19891@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190621140542.GO19891@ziepe.ca>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 21, 2019 at 11:05:42AM -0300, Jason Gunthorpe wrote:
> Today this check is only being done on the get_user_pages_fast() -
> after this patch it is also done for __get_user_pages_fast().
> 
> Which means __get_user_pages_fast is now non-functional on a range of
> MIPS CPUs, but that seems OK as far as I can tell, so:

> However, looks to me like this patch is also a bug fix for this:

Yes.

> > -	pgdp = pgd_offset(mm, addr);
> > -	do {
> > -		pgd_t pgd = *pgdp;
> > -
> > -		next = pgd_addr_end(addr, end);
> > -		if (pgd_none(pgd))
> > -			goto slow;
> > -		if (!gup_pud_range(pgd, addr, next, gup_flags & FOLL_WRITE,
> > -				   pages, &nr))
> 
> This is different too, the core code has a p4d layer, but I see that
> whole thing gets NOP'd by the compiler as mips uses pgtable-nop4d.h -
> right?

Exactly.

