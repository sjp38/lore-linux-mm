Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6091CC3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 04:38:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF03722CF4
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 04:38:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="haCfRM1m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF03722CF4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AFF76B0007; Tue, 20 Aug 2019 00:38:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45FFB6B0008; Tue, 20 Aug 2019 00:38:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3753A6B000A; Tue, 20 Aug 2019 00:38:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0189.hostedemail.com [216.40.44.189])
	by kanga.kvack.org (Postfix) with ESMTP id 148356B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 00:38:41 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 703158248ABA
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 04:38:40 +0000 (UTC)
X-FDA: 75841550400.09.order84_85e3a65aa4c2b
X-HE-Tag: order84_85e3a65aa4c2b
X-Filterd-Recvd-Size: 3372
Received: from mail-oi1-f195.google.com (mail-oi1-f195.google.com [209.85.167.195])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 04:38:39 +0000 (UTC)
Received: by mail-oi1-f195.google.com with SMTP id a127so3106418oii.2
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 21:38:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=pTsJc2XB2ULhT5btNfz5YqFDZzAMX4YrlKJzpdakKHA=;
        b=haCfRM1mdP3nfX7azXTUWTkX4VYJbjwY4jc+E3ak3zb/Q1+VOGqLgRgEbsy3pyWICB
         zvAYiCgBRK+8dAkVv4krDHbFmnRdtaPjhz4cpLHCAE65/wVsfPUFMFMcixGZheTPXPms
         aafV2W8tyjSi4gBburO/Opb1eLDzEo0j/90LUSBXS17sLm1C/53R+92S1YUt8vUBzN+/
         U4+YUiQZEu4DVvSOKNCDAYmdydy1ywzQLQF1LZnqZ2ysxAuQMGigKwXhAw4JExvC1809
         LC3e0idPYuahq4WIZQeLES2Pzu3+u4NlHkHZDkmoTlbB8qQQWmc7sgdaCXV41prJKu5+
         po5g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=pTsJc2XB2ULhT5btNfz5YqFDZzAMX4YrlKJzpdakKHA=;
        b=Xbqs+bZER2xZQjrsAMcCeAmw71ZodX0lF94D8EjdY42dufTFrYEGlnYndtL1gmurIP
         +C/n5m19FFmed+hiHAgmxijhJdGhQjFXN5qvQFS31pSvWk/wnbLZ6MduSlWV+i6E57eY
         NOy3zubeaWzdfHRN0IsAmhXdYVHcdAMgQF5EPJ5N6ktb/GIiI81jqcwXe4pMNVWXDTHb
         VymMa9OgvT080WKjn5eCjKIwvVwQ+eWZzqeCfCZ7GUco5KoEHne0vL1PqS2hB+oSUKIq
         c9qLRbzr67zJ2/X3Zva1oo03Fk6CJ0d1hgxgd6Z8eeAd6thu9tkYfrMZrW7/1LZ3Gk8M
         PxaA==
X-Gm-Message-State: APjAAAUBmrYVYkT/cPlrmv46FmyJGXvwWmSPE8AsC0+ytIMhR4t9yO8b
	2gZLuwts/gRsCGocwvcwJR8SOTa+2u4ctypXFQ6kGw==
X-Google-Smtp-Source: APXvYqwNAdmv8U/MMocqDHerUy4sI8jbpH839Mf4eiVmaYDc08GdXYIAOnJ1qD656K+Q7iTrImqncBEbLElGaGG5fV0=
X-Received: by 2002:a05:6808:914:: with SMTP id w20mr15019903oih.73.1566275919132;
 Mon, 19 Aug 2019 21:38:39 -0700 (PDT)
MIME-Version: 1.0
References: <20190818090557.17853-1-hch@lst.de> <20190818090557.17853-2-hch@lst.de>
 <CAPcyv4iaNtmvU5e8_8SV9XsmVCfnv8e7_YfMi46LfOF4W155zg@mail.gmail.com> <20190820022619.GA23225@lst.de>
In-Reply-To: <20190820022619.GA23225@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 19 Aug 2019 21:38:25 -0700
Message-ID: <CAPcyv4hUC5ReY9v=Lt0M=jPtg3V05suOgt4fVdT4niO_k4hN8Q@mail.gmail.com>
Subject: Re: [PATCH 1/4] resource: add a not device managed
 request_free_mem_region variant
To: Christoph Hellwig <hch@lst.de>
Cc: Jason Gunthorpe <jgg@mellanox.com>, Bharata B Rao <bharata@linux.ibm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Ira Weiny <ira.weiny@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 19, 2019 at 7:26 PM Christoph Hellwig <hch@lst.de> wrote:
>
> On Mon, Aug 19, 2019 at 06:28:30PM -0700, Dan Williams wrote:
> >
> > Previously we would loudly crash if someone passed NULL to
> > devm_request_free_mem_region(), but now it will silently work and the
> > result will leak. Perhaps this wants a:
>
> We'd still instantly crash due to the dev_name dereference, right?

Whoops, yes.

