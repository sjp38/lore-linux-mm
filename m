Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD2DCC3A5A0
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 02:22:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5528522CE8
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 02:22:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="zKdVom0N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5528522CE8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2F836B0007; Mon, 19 Aug 2019 22:22:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE01E6B0008; Mon, 19 Aug 2019 22:22:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CFA46B000A; Mon, 19 Aug 2019 22:22:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0053.hostedemail.com [216.40.44.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0686B0007
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 22:22:54 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 292AB180AD805
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 02:22:54 +0000 (UTC)
X-FDA: 75841208268.29.bat97_70895a0660f36
X-HE-Tag: bat97_70895a0660f36
X-Filterd-Recvd-Size: 3274
Received: from mail-ot1-f68.google.com (mail-ot1-f68.google.com [209.85.210.68])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 02:22:53 +0000 (UTC)
Received: by mail-ot1-f68.google.com with SMTP id m24so3608972otp.12
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 19:22:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=dGaKAdU7Kzz4IRqMPbeMcHc/uvSVrliEnlndetCK0L4=;
        b=zKdVom0NZGDuaHrgxklgUVhp5ExnznDDaFFfOxYdgCUPF9H/QOmK2okCnSBv7TG1iD
         8VgVkvB+roi1O3wId/DNGT8ohuOBrvtAfFus1UIgy09kWcIHqe6sdGmcCfrddDiGjVfQ
         Afc6z9YQXk8loHn3UQOdSWjNKRrrWri2tNd/Ct3340IOvPhfEVjetCZPcUMPwssOPcPh
         gcT9UtKBwAP+mwb+m6SX2ozuyxus2NlfyohT9yJ4NcRTRyeoKama6VEntAVh0vYxR8l2
         sRgjoQgP2IKMeZVgEwTLIZ62YZ8rqzp3S2/EPPh3bvEnEXheYWNfsqDls665h3cp2/Xk
         liEw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=dGaKAdU7Kzz4IRqMPbeMcHc/uvSVrliEnlndetCK0L4=;
        b=GjplEE/KnXtG5ykKw1sra3BehpFI27O2z23nv46PWs9SwvaGYvB2KlpdJ1H4zoPY3t
         3g8nUkExCPDXx/rFehMEshhD/ytQa5Tf06+j9Y4ag0x3uHP9wNtDRhIQToITcobUqD0y
         nL0IEO9lQ5p7Z4JW+ugxKWujERvNKm48+yDG7514GmmXpUKm4OFSHcZhMiMQft5Gciwm
         E1/CRqFzwy+sIMubhCdGT89JSKkFXtOQoyyG+tfz9jK3kR6kdyHcttIWsgAwSA3FMn46
         dvwCM2C5ffj7SNUdA3aGWO7e0MNya3gWRlHC81ed/pcVE8Th6htIwcUjlRg/jGGfTDLG
         BobQ==
X-Gm-Message-State: APjAAAUM7QpW/1rEyve4rT0k2sk51ZHcdN1M28K5ds3idKESCGWld4Jl
	dPloA7Zo0cfEiXMK+BhrKTEMP0c7IRcDO6PCc0gAqg==
X-Google-Smtp-Source: APXvYqxMJSoi3xcOuG4kdSjiGcLdWTp8DOPjIJI3WHkmC8gPmnKQsuPiwRsZyF/AEjqfvhoUMKVUtbKpNU6WT1lmw68=
X-Received: by 2002:a05:6830:458:: with SMTP id d24mr19986229otc.126.1566267772164;
 Mon, 19 Aug 2019 19:22:52 -0700 (PDT)
MIME-Version: 1.0
References: <20190818090557.17853-1-hch@lst.de> <20190818090557.17853-4-hch@lst.de>
In-Reply-To: <20190818090557.17853-4-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 19 Aug 2019 19:22:41 -0700
Message-ID: <CAPcyv4h9Bp=D4oHEb-v9U7-aZE3VazmsTK3Ou3iC3s3FTYc4Dg@mail.gmail.com>
Subject: Re: [PATCH 3/4] memremap: don't use a separate devm action for devmap_managed_enable_get
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
> Just clean up for early failures and then piggy back on
> devm_memremap_pages_release.  This helps with a pending not device
> managed version of devm_memremap_pages.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Ira Weiny <ira.weiny@intel.com>

Looks good,

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

