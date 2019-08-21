Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE498C3A59D
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 02:58:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9770E22DD3
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 02:58:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="qOorDm6P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9770E22DD3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04C006B0281; Tue, 20 Aug 2019 22:58:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F18B96B0282; Tue, 20 Aug 2019 22:58:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDFC76B0283; Tue, 20 Aug 2019 22:58:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0078.hostedemail.com [216.40.44.78])
	by kanga.kvack.org (Postfix) with ESMTP id B5D066B0281
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 22:58:35 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 5140118DF
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 02:58:35 +0000 (UTC)
X-FDA: 75844926990.18.fish05_2dc1af8e33b08
X-HE-Tag: fish05_2dc1af8e33b08
X-Filterd-Recvd-Size: 4261
Received: from mail-oi1-f196.google.com (mail-oi1-f196.google.com [209.85.167.196])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 02:58:34 +0000 (UTC)
Received: by mail-oi1-f196.google.com with SMTP id g128so526879oib.1
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 19:58:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9TZ3h9XIXM46J9xL8jGJCgzDeloZeTOimF9MDrrQtC4=;
        b=qOorDm6PpWOQgpgNZ9zmOr4vJFD6fWmIZseaX2KpEDDmSUDSr1IXX+4fS6N4xb9YQ6
         JeafUS1hPydswBv2jT2nbmW5e3KtNqzCllW3DoP9Ivp9l7s1LyVGLvbQpCXmIdvbjGi/
         Vw7guluARa0Ip4m0K0RZ3094LcmC/4LVARQvNA1uJ509zGMVyPz87TGgjfE8Arwtj20D
         x+VHqobf5iooIqnblgEZSS3mBUK6ZgTXxWpTdtvQMussWhRgurBPgRBEAahbNXCcW47j
         WaLrZ5A2ALTQZeRCdgfEiHjxsTb1DXQJSIq0HNM1AdW9RXdtY9uDZbgW32ANNApRRZOC
         7F5A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=9TZ3h9XIXM46J9xL8jGJCgzDeloZeTOimF9MDrrQtC4=;
        b=LqgdRFteWQEBj1RRL0JGY2piRAPyjEBr5or4N9R38gNBFDDzlzAEQFEN7OkPQTTw9j
         NGloFb4puCqMKiZAHrhjiCrDu2RBoSMVIvgOPa/WSfGkRC+cza9k5zQbZYJIp7gUPVUB
         JAJq+PJT10i568Wo/w56wWCpqO1FBe8wlqRL1TYsd/tc7DJ1h5838st+hOPbo3q5jHSW
         HqZFRwy4gqoGCx9AypbmgXbJzWBKYPsuER32E2yBkJMLcCpy/FYV+9xp3Pd2TEAxIhwh
         BmblskCrHru0v7tFwKLRtmz56flpAqhFPcjZVDFlacpTHUS4UnstanukF3zPSkpW1T7w
         hApg==
X-Gm-Message-State: APjAAAXQQpsA5w1zVWlTQwC6JkqWs3FWJcmDozvz5wJ6ZqW4X5MU/tKG
	uAPWSm8cc/WSYiTsk/NxUnsOE9vZeyDbmSErU9pVVw==
X-Google-Smtp-Source: APXvYqzy0DftYJ4NNlH1NIMiV5YB0m8M/Dz1VUcVz6X5YJE31Eh5n7ME2g8Oz2MtJxGZ8nCBds6RncjxWyjh/YYH8Xg=
X-Received: by 2002:a05:6808:914:: with SMTP id w20mr2162912oih.73.1566356313559;
 Tue, 20 Aug 2019 19:58:33 -0700 (PDT)
MIME-Version: 1.0
References: <20190818090557.17853-1-hch@lst.de> <20190818090557.17853-3-hch@lst.de>
 <CAPcyv4iYytOoX3QMRmvNLbroxD0szrVLauXFjnQMvtQOH3as_w@mail.gmail.com> <20190820132649.GD29225@mellanox.com>
In-Reply-To: <20190820132649.GD29225@mellanox.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 20 Aug 2019 19:58:22 -0700
Message-ID: <CAPcyv4hfowyD4L0W3eTJrrPK5rfrmU6G29_vBVV+ea54eoJenA@mail.gmail.com>
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

On Tue, Aug 20, 2019 at 6:27 AM Jason Gunthorpe <jgg@mellanox.com> wrote:
>
> On Mon, Aug 19, 2019 at 06:44:02PM -0700, Dan Williams wrote:
> > On Sun, Aug 18, 2019 at 2:12 AM Christoph Hellwig <hch@lst.de> wrote:
> > >
> > > The dev field in struct dev_pagemap is only used to print dev_name in
> > > two places, which are at best nice to have.  Just remove the field
> > > and thus the name in those two messages.
> > >
> > > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > > Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> >
> > Needs the below as well.
> >
> > /me goes to check if he ever merged the fix to make the unit test
> > stuff get built by default with COMPILE_TEST [1]. Argh! Nope, didn't
> > submit it for 5.3-rc1, sorry for the thrash.
> >
> > You can otherwise add:
> >
> > Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> >
> > [1]: https://lore.kernel.org/lkml/156097224232.1086847.9463861924683372741.stgit@dwillia2-desk3.amr.corp.intel.com/
>
> Can you get this merged? Do you want it to go with this series?

Yeah, makes some sense to let you merge it so that you can get
kbuild-robot reports about any follow-on memremap_pages() work that
may trip up the build. Otherwise let me know and I'll get it queued
with the other v5.4 libnvdimm pending bits.

