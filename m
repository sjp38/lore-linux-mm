Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D735DC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 02:24:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9611322CEC
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 02:24:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="CJP7CTbT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9611322CEC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22D7B6B0007; Mon, 19 Aug 2019 22:24:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DDE06B0008; Mon, 19 Aug 2019 22:24:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CC8B6B000A; Mon, 19 Aug 2019 22:24:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0057.hostedemail.com [216.40.44.57])
	by kanga.kvack.org (Postfix) with ESMTP id DA0256B0007
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 22:24:51 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 7A370180AD801
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 02:24:51 +0000 (UTC)
X-FDA: 75841213182.30.waves66_819c0c8a35536
X-HE-Tag: waves66_819c0c8a35536
X-Filterd-Recvd-Size: 3272
Received: from mail-ot1-f65.google.com (mail-ot1-f65.google.com [209.85.210.65])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 02:24:50 +0000 (UTC)
Received: by mail-ot1-f65.google.com with SMTP id q20so3646336otl.0
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 19:24:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yBHOOAIpl+BVp9v5InU9pcm2gaJbl2xEJrSQBhETvYs=;
        b=CJP7CTbTPhZR+phUQnNkcTI/KNVWXl0SEGDWRt6JUQ8QXyB0Ee6aK8B6XXfkWH2D2X
         FIJQnLB5WFJV/CEJA4E/Iu2JcnEey/xpN9i0OeyUTPYwhZxbAzvnq886azOWzP46T02n
         J0qfxbD6Inesz2YwKORlypUR85mXvGdZkPZcPl3EgMqeUoUQnZFm2pg5O2htZW/EMhMb
         OVWEuyEOYV90TI4cJ+wa2Dqu+Bf0RQBah7CyzDuL9yw3lUe7T3OCIgBtrdE7pwdiXtCZ
         H2FU67p4R9TZSCDOstBQu9JQ34ERrQYLwlBW2NRSBK/zEmI9YmMsyTlL87m83uQrBx2t
         brrg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=yBHOOAIpl+BVp9v5InU9pcm2gaJbl2xEJrSQBhETvYs=;
        b=CGowuXU4+QtM+GPiE7cFdKnkuSiclyGCzqREsmymcU+/n0caQT+rwvbR4ArWnErGg1
         bba5FL1+U00DfJLfHy+VKigWuqxoJ9B7jnOcU43Vrz5OuOCrJDbHSh882QLsl7W2jLX8
         wHppgw8srrrp5CihJhcrGGymE8ZUzoTF0VOZRZxg/sO+Kx/LzLOj64329y3//qDAoho/
         BOM2ROgPoKEpQDu/F2jGIEyLGmKFFbToFFbpkcHalkvf1qdA1nxI7QA+odOSRxRGQe2N
         59J6+f9cbZy1kkBJdqc6v7OVHZiAO3jM6InhhaF4XZApswr3rSemjDXm7Z3VEBZOSKyr
         0Hxw==
X-Gm-Message-State: APjAAAUSI+GSS24cWYSM2ye8O52cL+prrDl0yL8L76yXmSXdGJS1g97n
	1PqATByjUFOnsS9zsGZbJWTrxUy7ff6vl2g8hXyIaQ==
X-Google-Smtp-Source: APXvYqyNozQmsW6VwbwYlZxgLUM3eNQ/tnZ1XVJVsGuQWe47WPqdIvt2eUClmdyGd3c5FW1ejTh7V/zH1JQI72JUIu0=
X-Received: by 2002:a05:6830:458:: with SMTP id d24mr19989967otc.126.1566267889874;
 Mon, 19 Aug 2019 19:24:49 -0700 (PDT)
MIME-Version: 1.0
References: <20190818090557.17853-1-hch@lst.de> <20190818090557.17853-5-hch@lst.de>
In-Reply-To: <20190818090557.17853-5-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 19 Aug 2019 19:24:39 -0700
Message-ID: <CAPcyv4iy=RGu87Px_6Pr3f8yx5tH1hm58M85n74zYbbUTA299Q@mail.gmail.com>
Subject: Re: [PATCH 4/4] memremap: provide a not device managed memremap_pages
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

On Sun, Aug 18, 2019 at 2:12 AM Christoph Hellwig <hch@lst.de> wrote:
>
> The kvmppc ultravisor code wants a device private memory pool that is
> system wide and not attached to a device.  Instead of faking up one
> provide a low-level memremap_pages for it.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Ira Weiny <ira.weiny@intel.com>

Looks good,

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

