Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC613C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 20:23:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E6B7208E3
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 20:23:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="CITJOOm3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E6B7208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E02756B0005; Tue, 25 Jun 2019 16:23:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB3468E0003; Tue, 25 Jun 2019 16:23:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7AE18E0002; Tue, 25 Jun 2019 16:23:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 916706B0005
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 16:23:55 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id x13so26018pgk.23
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 13:23:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DiiT5ejWGAbepeGCBF5bxq/cFE8C403Rhj5sAo53Vn8=;
        b=ZUZzO14oxMCVDIW58xvn4/FatM9wC1/CJQ+sloDTd1WxqVAtoZecSoKsq03uxTE9Bk
         SoNP/Jp3bF0j/swjo6NMSMqlfx+PzBHq9aVNXksoGto1gmIXm92Y6njCSMquvngjGRSg
         EZncN8aDqZauLgOoSrRLgGrgV9pg5BZAyKDLKCJVVrbX2kSLzTou15ibxbU2CehHNkgW
         XnLe1sirmLLKmCDE16Tm+DI+COwVVuPTAC7J/WJRNyjFnA6rGyodSGlU2+ia6wvDGpcB
         fLQX80IrB+YBD6If46S2fXNCh8op4g56+k/+H1McAtn3j0MNrIiB3boI9ioMJAKR1NMg
         l37w==
X-Gm-Message-State: APjAAAXWRrGvDS5EWsj1pVi7JWCAHZZTeHSYE3ylu22u/gvCySvnWLUa
	c23WBlXYFw4XcIAn8x4Kgvmwj9qMOKPuax02EVK91jCIENXWN/RHXM4p0P/o8aEteVse1Ts6LZ0
	S/wQFdaAEwtGPCwmBuVp84uvnEYDCkiSvIURMfgWyW/VWzFETP0HagX38v/UIN7gtGw==
X-Received: by 2002:a17:902:31c3:: with SMTP id x61mr541553plb.331.1561494235146;
        Tue, 25 Jun 2019 13:23:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0Gbxh4r032dKj6ClUZiBVc+u0MBLefzaH3yqULtgPMN1vzbanNpW2HcLJA96DSJcuYua6
X-Received: by 2002:a17:902:31c3:: with SMTP id x61mr541506plb.331.1561494234463;
        Tue, 25 Jun 2019 13:23:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561494234; cv=none;
        d=google.com; s=arc-20160816;
        b=LVlahmD4H7HddFRcEbQf0yyJTpMeGdL9IC2kIYQ8ijaQWHv/3Xrbe4+ye+6ve9fQFz
         myXepxVnTCSfrsnaQucSUjn7uBeyTJylF/jQUYYhcam6x/3EaHIQOtSIkMd9xLcwTIzQ
         W0fLtAdCsmuTeBbudGa0ddzqLBIRD74Ek9pIdFHfeFNUq0TgmVeeApCkqCOfp+WjcFQD
         Si9YlOdtciDshYBYex2H6NROjYnT9diTYpVS5jYZPbMaXEmiTbxZGzO+TQdh/QAcvVPZ
         ovOlZYPQra7+cqth2U+za14CE9AMIyitVXZfKHXlRovIKTlIwWm66jJrGP8f5y7QtcpG
         BmEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=DiiT5ejWGAbepeGCBF5bxq/cFE8C403Rhj5sAo53Vn8=;
        b=aUFPHkP5RP1VVlXOP9Myspa+LFGLTQukSJC7YYTz8a9YwYryHhuXFi8CuLmO4zyNrT
         1u/0FJSYirwhZfouiVQqA572+OjVy1K1+5Ke6tC8cN056ADH938oWVwD2JXKm8H7IJsv
         vP0wePaeXYhW8QcVHP00VadkgpabKuFKQNFIeq4MNUVvodxbzjHHWnw0Ucq4ckdyim33
         2mKTPl5g9z1MCtCeOdbQpu7acjnalwz5ilC9brrBXV8cwxeF4HeGVZxi+GtONsC+wzCY
         2ejN/lKDzNvfJ+bdFM4D93dfGZfOv4NqEBYknDSd5P+O/LW27YICts8BeePE2bc3QiCq
         g+oA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=CITJOOm3;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f10si8141898pgm.353.2019.06.25.13.23.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 13:23:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=CITJOOm3;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 88B4B2085A;
	Tue, 25 Jun 2019 20:23:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561494233;
	bh=ty8OSeUCz/5XvL7ic9s3yUJgWM1ofmFAG2h2f5h8eOQ=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=CITJOOm379AFpZGiqQaxvlLl8CMO38VIjXbovh/3uocIqEnmtaRAdl8ZZnNvzMF+t
	 7y0jyLhD6my9mIEPL31WT0Wn00z+MlSfk49SVd3BtPxyg4LZmFlXwHYPWXvlLS6DEh
	 KpNI+8QriqEKN54YTmS06SIeRqjo9OOOqloxzZ+s=
Date: Tue, 25 Jun 2019 13:23:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Doug Berger <opendmb@gmail.com>
Cc: linux-mm@kvack.org, Yue Hu <huyue2@yulong.com>, Mike Rapoport
 <rppt@linux.ibm.com>, =?UTF-8?Q?Micha=C5=82?= Nazarewicz
 <mina86@mina86.com>, Laura Abbott <labbott@redhat.com>, Peng Fan
 <peng.fan@nxp.com>, Thomas Gleixner <tglx@linutronix.de>, Marek Szyprowski
 <m.szyprowski@samsung.com>, Andrey Konovalov <andreyknvl@google.com>,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH] cma: fail if fixed declaration can't be honored
Message-Id: <20190625132353.ba16040d27366fae4ec5bef0@linux-foundation.org>
In-Reply-To: <1561422051-16142-1-git-send-email-opendmb@gmail.com>
References: <1561422051-16142-1-git-send-email-opendmb@gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Jun 2019 17:20:51 -0700 Doug Berger <opendmb@gmail.com> wrote:

> The description of the cma_declare_contiguous() function indicates
> that if the 'fixed' argument is true the reserved contiguous area
> must be exactly at the address of the 'base' argument.
> 
> However, the function currently allows the 'base', 'size', and
> 'limit' arguments to be silently adjusted to meet alignment
> constraints. This commit enforces the documented behavior through
> explicit checks that return an error if the region does not fit
> within a specified region.
> 
> ...
>
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -278,6 +278,12 @@ int __init cma_declare_contiguous(phys_addr_t base,
>  	 */
>  	alignment = max(alignment,  (phys_addr_t)PAGE_SIZE <<
>  			  max_t(unsigned long, MAX_ORDER - 1, pageblock_order));
> +	if (fixed && base & (alignment - 1)) {
> +		ret = -EINVAL;
> +		pr_err("Region at %pa must be aligned to %pa bytes\n",
> +			&base, &alignment);

CMA functions do like to use pr_err() when the caller messed something
up.  It should be using WARN_ON() or WARN_ON_ONCE(), mainly so we get a
backtrace to find out which caller messed up.

There are probably other sites which should be converted, but I think
it would be best to get these new ones correct.  So something like

	if (WARN_ONCE(fixed && base & (alignment - 1)),
		      "region at %pa must be aligned to %pa bytes",
		      &base, &alignment) {
		ret = -EINVAL;
		goto err;
	}


