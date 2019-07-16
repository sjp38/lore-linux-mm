Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21F04C76188
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 12:10:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1DE020651
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 12:10:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1DE020651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 069CF6B0003; Tue, 16 Jul 2019 08:10:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 019386B0005; Tue, 16 Jul 2019 08:10:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E24938E0001; Tue, 16 Jul 2019 08:10:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 90D4C6B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 08:10:29 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id g8so10436981wrw.2
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 05:10:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=54gIuNnOCiLjXU45Ged+V0x2kmUe/5Bt5gvEV7MxorI=;
        b=H0w+mv6wr0FlVMuzOQqQxcBmp9+DKerlHzo4CRQsS9aYiKs1+ryyFnzt97IuJPiAcp
         3p/wxmHsCwVvLFAHHQkDB++eB5URZykEL/ramCMms/wlrz/9tqGCsJyL1YP296Dx5G1P
         jSCbO1UEq9zvBZJn7Owd9avz3VyJM9jyoxfJoS011m/SUZNiOZuEeZM1FCfvyxVahFYE
         a0F96HxQ24ZX4KmI82+OOPiyTzahbQcCNUOMsPkemCwJHRWBVjnarorlsQh+bNQCFrPj
         Ngf9+tuCTDp7jz0bow5c/Mm7P/GeFLCW75yxVsnQQl1EFuSyppQ4sEntoEOXC6hqp/Ya
         mz/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWDN5y6guvH7bVmA17WPtC/OgPOt1K3OI5ExYu4xexPq2sX3FDR
	Q8g9AtekLmL6ilLWYES5g+wdOjt5cShyFgdtbAWoVF2kegYveQ9xjO8N0FVRqw8nc7kTAqrcV1A
	koo7CLF1DI99ksZm86DusUnowjEEjS1pnKlpxMsJdegw5t1MupAXWeY3nFhPkEaYa9A==
X-Received: by 2002:a5d:4941:: with SMTP id r1mr34497591wrs.225.1563279029135;
        Tue, 16 Jul 2019 05:10:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYTIlAdtBUv+ilM1GS6cSsaXLLEwONGsR7Gu6t/8pmw90ULORsI78gc5IohdmNZ1ta9cfp
X-Received: by 2002:a5d:4941:: with SMTP id r1mr34497532wrs.225.1563279028329;
        Tue, 16 Jul 2019 05:10:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563279028; cv=none;
        d=google.com; s=arc-20160816;
        b=GTa3ZHh1sNg/nbd4cycREhCX08ATdZ3M5wOMCJ3D/TFioay9h3svFKWvmqybUt02QT
         /R2AoCQiKkzfRdQVcnZ9ACoguXun88sANofDTWls4dxTn/JEFXpjxXSBIPozO4Fe+PDO
         9SDVwiY4nboNBdv5TLfn3b5Q0/9R1jS0QfAcr07vP2SKuEGK7x3Cjn68u3aW3qKzs03n
         s0XA6ebnLLL6PZR5Oa/yLC3C/9XsEL9sZruhGwFM9FUOW/Ioh8duq5cVDwyKKbBd1xkJ
         oYP4PPW0zsrKIgBFxGBNlzsNob/ZMa3YOSMYJagwP1nblKaBAzKfec0idzd5oeIrG0Tc
         WCaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=54gIuNnOCiLjXU45Ged+V0x2kmUe/5Bt5gvEV7MxorI=;
        b=FFdMrT1hHR6ADD92KteEz6WS7C6mZHUpKpR6i0s6l8Zhy1zZQTDN+VbTrTBDSrwyYm
         0bKmrmGfc+HIZ+Y9SV3HPhphIPbu5GZRpZrLeNzIs88zSIvWYIoZpb8+kEmOZePWdWnW
         O1qeDlzvSo3GWX1wiVFdy7HtHPXorhuWtKnV2y1kIJskcgZWU/FdJHSE06LfjqKLKau/
         XvoK2rxPsIbFZxPNvgp2UXLj/9z7TruuhvMffWOvTql67AKwSGFUX3142hxj/w7Z3BZv
         +ETtD6cYrG8mM52OgHWlQ8wvmGtMq169cHCfcFyx66TMT6gjuXCmR+nCgbXAx5v+CyQM
         3mLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id j11si16900626wmh.89.2019.07.16.05.10.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 05:10:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 9A83F227A81; Tue, 16 Jul 2019 14:10:26 +0200 (CEST)
Date: Tue, 16 Jul 2019 14:10:26 +0200
From: Christoph Hellwig <hch@lst.de>
To: Robin Murphy <robin.murphy@arm.com>
Cc: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	iommu@lists.linux-foundation.org, Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@kernel.org>, pankaj.suryawanshi@einfochips.com,
	minchan@kernel.org, minchan.kim@gmail.com,
	Christoph Hellwig <hch@lst.de>
Subject: Re: cma_remap when using dma_alloc_attr :-
 DMA_ATTR_NO_KERNEL_MAPPING
Message-ID: <20190716121026.GB2388@lst.de>
References: <CACDBo56EoKca9FJCnbztWZAARdUQs+B=dmCs+UxW27yHNu5pzQ@mail.gmail.com> <57f8aa35-d460-9933-a547-fbf578ea42d3@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57f8aa35-d460-9933-a547-fbf578ea42d3@arm.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 16, 2019 at 01:02:19PM +0100, Robin Murphy wrote:
>> Lets say 4k video allocation required 300MB cma memory but not required
>> virtual mapping for all the 300MB, its require only 20MB virtually mapped
>> at some specific use case/point of video, and unmap virtual mapping after
>> uses, at that time this functions will be useful, it works like ioremap()
>> for cma_alloc() using dma apis.
>
> Hmm, is there any significant reason that this case couldn't be handled 
> with just get_vm_area() plus dma_mmap_attrs(). I know it's only *intended* 
> for userspace mappings, but since the basic machinery is there...

Because the dma helper really are a black box abstraction.

That being said DMA_ATTR_NO_KERNEL_MAPPING and DMA_ATTR_NON_CONSISTENT
have been a constant pain in the b**t.  I've been toying with replacing
them with a dma_alloc_pages or similar abstraction that just returns
a struct page that is guaranteed to be dma addressable by the passed
in device.  Then the driver can call dma_map_page / dma_unmap_page /
dma_sync_* on it at well.  This would replace DMA_ATTR_NON_CONSISTENT
with a sensible API, and also DMA_ATTR_NO_KERNEL_MAPPING when called
with PageHighmem, while providing an easy to understand API and
something that can easily be fed into the various page based APIs
in the kernel.

That being said until we get arm moved over the common dma direct
and dma-iommu code, and x86 fully moved over to dma-iommu it just
seems way too much work to even get it into the various architectures
that matter, never mind all the fringe IOMMUs.  So for now I've just
been trying to contain the DMA_ATTR_NON_CONSISTENT and
DMA_ATTR_NO_KERNEL_MAPPING in fewer places while also killing bogus
or pointless users of these APIs.

