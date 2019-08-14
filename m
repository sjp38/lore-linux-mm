Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C650C32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 14:48:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3013F208C2
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 14:48:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="VGmsuSut"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3013F208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2E4C6B0007; Wed, 14 Aug 2019 10:48:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDEFB6B000A; Wed, 14 Aug 2019 10:48:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ACF036B000C; Wed, 14 Aug 2019 10:48:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0063.hostedemail.com [216.40.44.63])
	by kanga.kvack.org (Postfix) with ESMTP id 8A3356B0007
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 10:48:40 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 2B2FA180AD7C3
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 14:48:40 +0000 (UTC)
X-FDA: 75821314800.04.meat57_115a76d26183a
X-HE-Tag: meat57_115a76d26183a
X-Filterd-Recvd-Size: 4576
Received: from mail-ot1-f68.google.com (mail-ot1-f68.google.com [209.85.210.68])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 14:48:39 +0000 (UTC)
Received: by mail-ot1-f68.google.com with SMTP id m24so29944062otp.12
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:48:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=TuidyYaeRyKNuzkufRgN6Ec9LRr2Ifgbce3UwZKDqAk=;
        b=VGmsuSutDmh/CjlBsd4sxqgbi8um+dCHzh+K0g76f30mKTKa4vnjEUi5IghOvDT2TU
         IiuduD1hp/FbpMVaMr/e7wBsaqMWdJ6XHtQ/1mBsBItSP4Wnk6xfU27TabVrZ7CxNxNQ
         xk36x4tWlqqM3zgQ+imkzsVY04ipeNiKK+QA1YnFVauQbb2Je88bjQTJ7UYiJXdobeSQ
         8yXovyKKvS5GfjCCiA8ng2LVaXxNaFUycGFOD1MJp5B3wtPnD6SMS1YSM8AN/j0ewy4K
         946ksv8AZDHbxIlpfzizsK/Ykelqs/5V6AZKhURom457TIKDaqNjmkxGJQw/75l6BLCF
         rGkA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=TuidyYaeRyKNuzkufRgN6Ec9LRr2Ifgbce3UwZKDqAk=;
        b=PSAM3kr4rWKAJm4v4l6GPyVfD0sHQq2Vnu4E8rQczAPCdZBx5y2XS8xuVFz78NUYE8
         SUlXiXwEkz5wlZzbEgGsVc8H5MSYPqoTnB+1E4+V+L+iSkARnM2wY0IFjU9fdyOOetej
         rImF9vv333HTSg8Jm08xGDuJ8Q7+jtfzyqpRE6X8ZAkJLQ7Wnxn/YF+Ahnm5zj/1syR9
         NzCGa3jjbxVybR6k5yf2733C9ytJFVjm6YtCEXUt75zCS6aVh+s6U2fNQeelm4K+tSOT
         AbXKS4U8cb7euHZ7IqNurVJZEcNMepWP6n6rxm5fCDEYC9N+cY0djdRMbGxabGUJjMKz
         yBpQ==
X-Gm-Message-State: APjAAAUoyP53gZTN7XqSyncTv/aVYjOhUmXozKQR17cND1yDTdIeKcHS
	f7UGL74i3Y4ZjTHdMj0pO8TBnzio1IW5U+KUATvwDg==
X-Google-Smtp-Source: APXvYqz7zm4exw86gTxj/ItuLHdqDfdPZkzMbuPMtbbm6xwrB+umcFhlOUSiQC4HRsH79R5rtenZdkZ3lrgt5XcFI70=
X-Received: by 2002:a9d:6b96:: with SMTP id b22mr2732383otq.363.1565794118373;
 Wed, 14 Aug 2019 07:48:38 -0700 (PDT)
MIME-Version: 1.0
References: <20190806160554.14046-1-hch@lst.de> <20190806160554.14046-5-hch@lst.de>
 <20190807174548.GJ1571@mellanox.com> <CAPcyv4hPCuHBLhSJgZZEh0CbuuJNPLFDA3f-79FX5uVOO0yubA@mail.gmail.com>
 <20190808065933.GA29382@lst.de> <CAPcyv4hMUzw8vyXFRPe2pdwef0npbMm9tx9wiZ9MWkHGhH1V6w@mail.gmail.com>
 <20190814073854.GA27249@lst.de> <20190814132746.GE13756@mellanox.com>
In-Reply-To: <20190814132746.GE13756@mellanox.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 14 Aug 2019 07:48:28 -0700
Message-ID: <CAPcyv4g8usp8prJ+1bMtyV1xuedp5FKErBp-N8+KzR=rJ-v0QQ@mail.gmail.com>
Subject: Re: [PATCH 04/15] mm: remove the pgmap field from struct hmm_vma_walk
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Ben Skeggs <bskeggs@redhat.com>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Ralph Campbell <rcampbell@nvidia.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>, 
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, 
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 6:28 AM Jason Gunthorpe <jgg@mellanox.com> wrote:
>
> On Wed, Aug 14, 2019 at 09:38:54AM +0200, Christoph Hellwig wrote:
> > On Tue, Aug 13, 2019 at 06:36:33PM -0700, Dan Williams wrote:
> > > Section alignment constraints somewhat save us here. The only example
> > > I can think of a PMD not containing a uniform pgmap association for
> > > each pte is the case when the pgmap overlaps normal dram, i.e. shares
> > > the same 'struct memory_section' for a given span. Otherwise, distinct
> > > pgmaps arrange to manage their own exclusive sections (and now
> > > subsections as of v5.3). Otherwise the implementation could not
> > > guarantee different mapping lifetimes.
> > >
> > > That said, this seems to want a better mechanism to determine "pfn is
> > > ZONE_DEVICE".
> >
> > So I guess this patch is fine for now, and once you provide a better
> > mechanism we can switch over to it?
>
> What about the version I sent to just get rid of all the strange
> put_dev_pagemaps while scanning? Odds are good we will work with only
> a single pagemap, so it makes some sense to cache it once we find it?

Yes, if the scan is over a single pmd then caching it makes sense.

