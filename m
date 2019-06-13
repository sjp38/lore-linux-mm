Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A29DCC31E49
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:48:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E4FE2173C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:48:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="W8RFMGE2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E4FE2173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD3FF6B000A; Thu, 13 Jun 2019 16:48:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5EFB6B000C; Thu, 13 Jun 2019 16:48:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD8AE6B000D; Thu, 13 Jun 2019 16:48:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 714DA6B000A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:48:34 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 14so153849pgo.14
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:48:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Nd3CksYN7ROJNyC0XgGmubA0zbLo2CWKKnS9ZGVJC/w=;
        b=jOHJpxinSLKK/c6AA9mn2l1gTyB7/ewuD42PAK+d4OtgwFADf3/nDwR5zCrd95bsZP
         RVpsUTB9MTIDaQTXgWBXWbZ88k9KbICHD9j+wnIiN2QuXJR7YNrZUeUlDGvOiyYl6oEX
         LR807y37Wlmk/CNGqYnTJ3j/4Sc4WB45qDgRY+lXwVl3TGLTNa2IspdTXFnOnRASFDdK
         ElU8xSnLOpqFBShxeDFDD2Z1Ca+YQqz5SqSbeoWzsOfDvpunNjXXGTgvnxvfW3XcOsxA
         3reoeBw88HrcpyT1r0scJpHQSGC2WkLT/YjGK/w9yC+QRshx+9Y9QnMsL6FBdQenN2/y
         YaSw==
X-Gm-Message-State: APjAAAW0AHqXjZ9OjNkS7ZdrNXRoUZWT/qkm+TYgptw8/V61+kRv/ISj
	tJQYHP5UUKg1JvHnXATmqO83ASNuKrhnQc5EmE9ikt3Tphqj4BApcwt6K/331l3LYLePffKsSE9
	+8L0oKpNi9ytpLMpgKtHFLHOqWMioVZ7qfjFMD60kFbqrYpMs1/EM8jO2t81pli1GVA==
X-Received: by 2002:aa7:9095:: with SMTP id i21mr88931694pfa.119.1560458914023;
        Thu, 13 Jun 2019 13:48:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwgaKE71tZ9m+kzAa9BMRzwhr3u9qFSBuUpqR7QNU9PR+63Yftv06AezbbdQg3N+xWHxab
X-Received: by 2002:aa7:9095:: with SMTP id i21mr88931655pfa.119.1560458913409;
        Thu, 13 Jun 2019 13:48:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560458913; cv=none;
        d=google.com; s=arc-20160816;
        b=kLJzjIePQ91n1fSlDCN/4Bqc0bWG3vYNeSJcJ77EyyNpWyoDb3D8k1sqtwYWMF/8yI
         v/0LedZHH+1wbkFrPplu1HA6pd7158h1rA7kR0hbom97sGuOkVJ+oO4dk9ZFbDvyfBkk
         /1fPLhwWR8Tgx7gW1MmyY+bv5dkAm8xQ7VjfjMnmaWshOs3oH7mY6VSkXvcAENskeOI+
         8EjYDXVTJE6MNN7ftpza1CcvK2EJQD063iwyXuroihRROr2YCr/ldAKUDNNON4kaNiR4
         I9EvBY2/MKV4QmYholKVTwSzYko/P/Q6lMnJ3Fho6Lwp6yrP/SjzibTzM15O6jY+g9DH
         GvQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Nd3CksYN7ROJNyC0XgGmubA0zbLo2CWKKnS9ZGVJC/w=;
        b=a6heeF9mq7KG9Q1ArxI6yNm9fxpfR34ttqRk6SK2TfFopYV8RmtuMDXYBBSzhsWfRK
         Hp/p343jL23TnfGvRpI4HTxd50FaednJ90MPPOU8nkwGpiB7H4l3AIM6zZdD8fhbTQ4o
         qZdxee/wgKzNFB0K+k6B5QxsXnqXwOa7eIJKDiycyFgWfrs9DqW+8CMNmcb4erg4l+rk
         vH41BPBWGguMlhbaNnetxvWT7PS0KwMCHF0rmRYSLb1Gz+5RCMwSNhxz+UhscXTUZJ5h
         el/MFpWtW4usnR5wLbJftEtBizWsj2ouzKlVryaqoRIPdN5bYQPyFynMnugX8urJomNE
         DjSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=W8RFMGE2;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m6si598156pgq.275.2019.06.13.13.48.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 13:48:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=W8RFMGE2;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8B3942133D;
	Thu, 13 Jun 2019 20:48:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560458913;
	bh=QBKFiYL+IE6QfIxDxWONJrMHcfZVbZUqMyER/iI/i+c=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=W8RFMGE2XEBfIMgZiJVLDJlgDCfrRRk8a5YMGm6NJWq3iOW7BFqDgEcE3jR3EzuxH
	 6mecnfow3Qth0X+c0FNOd8EU7Tgs7NtIzjtvm3fET+fi8GtnZHvccohCORja+Kjvbx
	 qMyCzCY6jdHR6rPl/G9MUU/Sgsma/isYN3+x1ZvE=
Date: Thu, 13 Jun 2019 13:48:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>,
 linux-nvdimm <linux-nvdimm@lists.01.org>, nouveau@lists.freedesktop.org,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Maling list - DRI
 developers <dri-devel@lists.freedesktop.org>, Linux MM
 <linux-mm@kvack.org>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse
 <jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs
 <bskeggs@redhat.com>, linux-pci@vger.kernel.org
Subject: Re: dev_pagemap related cleanups
Message-Id: <20190613134831.a7ecb1b422a732bff156ec50@linux-foundation.org>
In-Reply-To: <d0da4c86-ef52-b981-06af-b37e3e0515ee@deltatee.com>
References: <20190613094326.24093-1-hch@lst.de>
	<CAPcyv4jBdwYaiVwkhy6kP78OBAs+vJme1UTm47dX4Eq_5=JgSg@mail.gmail.com>
	<283e87e8-20b6-0505-a19b-5d18e057f008@deltatee.com>
	<CAPcyv4hx=ng3SxzAWd8s_8VtAfoiiWhiA5kodi9KPc=jGmnejg@mail.gmail.com>
	<d0da4c86-ef52-b981-06af-b37e3e0515ee@deltatee.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jun 2019 14:24:20 -0600 Logan Gunthorpe <logang@deltatee.com> wr=
ote:

>=20
>=20
> On 2019-06-13 2:21 p.m., Dan Williams wrote:
> > On Thu, Jun 13, 2019 at 1:18 PM Logan Gunthorpe <logang@deltatee.com> w=
rote:
> >>
> >>
> >>
> >> On 2019-06-13 12:27 p.m., Dan Williams wrote:
> >>> On Thu, Jun 13, 2019 at 2:43 AM Christoph Hellwig <hch@lst.de> wrote:
> >>>>
> >>>> Hi Dan, J=E9r=F4me and Jason,
> >>>>
> >>>> below is a series that cleans up the dev_pagemap interface so that
> >>>> it is more easily usable, which removes the need to wrap it in hmm
> >>>> and thus allowing to kill a lot of code
> >>>>
> >>>> Diffstat:
> >>>>
> >>>>  22 files changed, 245 insertions(+), 802 deletions(-)
> >>>
> >>> Hooray!
> >>>
> >>>> Git tree:
> >>>>
> >>>>     git://git.infradead.org/users/hch/misc.git hmm-devmem-cleanup
> >>>
> >>> I just realized this collides with the dev_pagemap release rework in
> >>> Andrew's tree (commit ids below are from next.git and are not stable)
> >>>
> >>> 4422ee8476f0 mm/devm_memremap_pages: fix final page put race
> >>> 771f0714d0dc PCI/P2PDMA: track pgmap references per resource, not glo=
bally
> >>> af37085de906 lib/genalloc: introduce chunk owners
> >>> e0047ff8aa77 PCI/P2PDMA: fix the gen_pool_add_virt() failure path
> >>> 0315d47d6ae9 mm/devm_memremap_pages: introduce devm_memunmap_pages
> >>> 216475c7eaa8 drivers/base/devres: introduce devm_release_action()
> >>>
> >>> CONFLICT (content): Merge conflict in tools/testing/nvdimm/test/iomap=
.c
> >>> CONFLICT (content): Merge conflict in mm/hmm.c
> >>> CONFLICT (content): Merge conflict in kernel/memremap.c
> >>> CONFLICT (content): Merge conflict in include/linux/memremap.h
> >>> CONFLICT (content): Merge conflict in drivers/pci/p2pdma.c
> >>> CONFLICT (content): Merge conflict in drivers/nvdimm/pmem.c
> >>> CONFLICT (content): Merge conflict in drivers/dax/device.c
> >>> CONFLICT (content): Merge conflict in drivers/dax/dax-private.h
> >>>
> >>> Perhaps we should pull those out and resend them through hmm.git?
> >>
> >> Hmm, I've been waiting for those patches to get in for a little while =
now ;(
> >=20
> > Unless Andrew was going to submit as v5.2-rc fixes I think I should
> > rebase / submit them on current hmm.git and then throw these cleanups
> > from Christoph on top?
>=20
> Whatever you feel is best. I'm just hoping they get in sooner rather
> than later. They do fix a bug after all. Let me know if you want me to
> retest the P2PDMA stuff after the rebase.

I had them down for 5.3-rc1.  I'll send them along for 5.2-rc5 instead.

