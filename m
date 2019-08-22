Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCDB4C3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 03:39:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FF0B21848
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 03:39:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="eXE3475x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FF0B21848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 321586B02CB; Wed, 21 Aug 2019 23:39:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D24D6B02CC; Wed, 21 Aug 2019 23:39:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E90C6B02CD; Wed, 21 Aug 2019 23:39:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0141.hostedemail.com [216.40.44.141])
	by kanga.kvack.org (Postfix) with ESMTP id F420B6B02CB
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 23:39:45 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 6FF1F55F9C
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 03:39:45 +0000 (UTC)
X-FDA: 75848659530.13.stem91_1adfc3989b436
X-HE-Tag: stem91_1adfc3989b436
X-Filterd-Recvd-Size: 5090
Received: from mail-oi1-f195.google.com (mail-oi1-f195.google.com [209.85.167.195])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 03:39:44 +0000 (UTC)
Received: by mail-oi1-f195.google.com with SMTP id t24so3283428oij.13
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 20:39:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DcgDXQJ7Sbm8FXh01qFeLyuuK1Iph1Tzrxc/aBWGcaU=;
        b=eXE3475xcHKKW5d+UZ3aQkd3F+q2lJG32c4rQx+Ll5k/X1A8KvcDqn+zrnRMvF2zXu
         DvqY89e1izlDq1R7kc5hmQRlOI+bJRAO1zmN4/b3qaKNzXZEkGJlRFKeT4CTOupOuefj
         zg9VgInCIVMy17OpVT7sSsuEFLnfkPgH4Gpr0vKEB8Vx/2OPR6n/2+AhC+sMP0CDaZU/
         FdO6j0esA09TtJJjBjWhXyr0/bc6Xz85XfBzDl4KZ06k2rGr/ypYbAv5CJMHqZLXIPHd
         tFqZvTuZvIngmIS+OxaCARJSeAjrwdpjWtfnrGylPxg7K5loiMiHMpdLjy2Eaq/1cmyW
         dn7w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=DcgDXQJ7Sbm8FXh01qFeLyuuK1Iph1Tzrxc/aBWGcaU=;
        b=Osu4D8UtdEUX9Q2L7DOT+LC8EzsAZC5oU/xDd5XGeb8sbWzuTClOJJC1Lzrb9mt1Qu
         Nm9fgkkPqf2dxkaQO/AKfpgZXZpCaGYJ9dYQn7YFsypl+mnpGqjTn2IHsEjPYhad8+kn
         Z/6Y2ylrnVzilmPr4wZz3P9G6x1Rfi7yPinyYOGUKCj3tUqgfPoKqGKHsomejl2gve+E
         MADkJo2et7zP6AhB0W4tUl1/BkWvUiCV6oHuo/igbM/KErrgJlZuRMRd7DewIsh0YmIY
         Wy7EWXKKVTnbv+gdmt8y8uto5oH34aQCO66uLWGy6ExQEYJoD/awjkTYjf+s/Sy8n44a
         Unpg==
X-Gm-Message-State: APjAAAXfgPi/ocwHyADSqbtVlN5K+TIlTS1wvWXFMfA7J1Ho6JAJNCXk
	fqQaC6BVXmaoS1q+ViFsYbODT9gpV968aA9dC2aWzw==
X-Google-Smtp-Source: APXvYqzSAJh90ed5uEoS1LSslo2SckTHl8JI7KY/tC5msX3Q9Ql8Er8WnuH87s+JOWBY8v+KaWLN9APIZd2VEdUR1OM=
X-Received: by 2002:aca:d707:: with SMTP id o7mr2421106oig.105.1566445183805;
 Wed, 21 Aug 2019 20:39:43 -0700 (PDT)
MIME-Version: 1.0
References: <20190818090557.17853-1-hch@lst.de> <20190818090557.17853-3-hch@lst.de>
 <CAPcyv4iYytOoX3QMRmvNLbroxD0szrVLauXFjnQMvtQOH3as_w@mail.gmail.com>
 <20190820132649.GD29225@mellanox.com> <CAPcyv4hfowyD4L0W3eTJrrPK5rfrmU6G29_vBVV+ea54eoJenA@mail.gmail.com>
 <20190821162420.GI8667@mellanox.com> <20190821235055.GQ8667@mellanox.com>
In-Reply-To: <20190821235055.GQ8667@mellanox.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 21 Aug 2019 20:39:32 -0700
Message-ID: <CAPcyv4iiuFD+5qNEpU9Cpg7ry-tLu2ycvLv8Hfomnuu+857sww@mail.gmail.com>
Subject: Re: [PATCH 2/4] memremap: remove the dev field in struct dev_pagemap
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, Bharata B Rao <bharata@linux.ibm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Ira Weiny <ira.weiny@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2019 at 4:51 PM Jason Gunthorpe <jgg@mellanox.com> wrote:
>
> On Wed, Aug 21, 2019 at 01:24:20PM -0300, Jason Gunthorpe wrote:
> > On Tue, Aug 20, 2019 at 07:58:22PM -0700, Dan Williams wrote:
> > > On Tue, Aug 20, 2019 at 6:27 AM Jason Gunthorpe <jgg@mellanox.com> wrote:
> > > >
> > > > On Mon, Aug 19, 2019 at 06:44:02PM -0700, Dan Williams wrote:
> > > > > On Sun, Aug 18, 2019 at 2:12 AM Christoph Hellwig <hch@lst.de> wrote:
> > > > > >
> > > > > > The dev field in struct dev_pagemap is only used to print dev_name in
> > > > > > two places, which are at best nice to have.  Just remove the field
> > > > > > and thus the name in those two messages.
> > > > > >
> > > > > > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > > > > > Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> > > > >
> > > > > Needs the below as well.
> > > > >
> > > > > /me goes to check if he ever merged the fix to make the unit test
> > > > > stuff get built by default with COMPILE_TEST [1]. Argh! Nope, didn't
> > > > > submit it for 5.3-rc1, sorry for the thrash.
> > > > >
> > > > > You can otherwise add:
> > > > >
> > > > > Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> > > > >
> > > > > [1]: https://lore.kernel.org/lkml/156097224232.1086847.9463861924683372741.stgit@dwillia2-desk3.amr.corp.intel.com/
> > > >
> > > > Can you get this merged? Do you want it to go with this series?
> > >
> > > Yeah, makes some sense to let you merge it so that you can get
> > > kbuild-robot reports about any follow-on memremap_pages() work that
> > > may trip up the build. Otherwise let me know and I'll get it queued
> > > with the other v5.4 libnvdimm pending bits.
> >
> > Done, I used it already to test build the last series from CH..
>
> It failed 0-day, I'm guessing some missing kconfig stuff
>
> For now I dropped it, but, if you send a v2 I can forward it toward
> 0-day again!

The system works!

Sorry for that thrash, I'll track it down.

