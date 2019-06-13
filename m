Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40624C31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:21:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1E892147A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:21:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="f8QwnyQT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1E892147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98CE26B000A; Thu, 13 Jun 2019 16:21:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 916936B000C; Thu, 13 Jun 2019 16:21:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B8A88E0002; Thu, 13 Jun 2019 16:21:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 501936B000A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:21:39 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id x27so118093ote.6
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:21:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=8C1DPfN32M3hy89DclQbm10r/6nHw68ntXJVKpP7b9Y=;
        b=BGeNBbqb5q/7eyrUnQq8D3EOP80hbbzB1oOOga3uk618NmC2a9T+ODe5ck5u4IUEJE
         qDMkoPSruRDFQCFYJ+Fh2CPn58D/LKpvXyvFT34Ai780Bi18BhulbjpbjRbjNihpPjwZ
         F8EMXbO2lRpGErQXbKbmENuDik9QVbf2W8cNtdRxwGeG9/UN5WDO/C+dYeZAuXWnIQIm
         skQfpWyy6qZQUoL6/kFCQOb9TcX3xkmcEa/SX+E6ZZ8kAnT6VhCJRVIl7BOt3xGHKQr1
         kiaR7dp2zTfV2teNvqgbODR4DBrSHzz715XshaOmnY0YbxPHWIZeaJjbC3GqgbisMpnk
         6vMA==
X-Gm-Message-State: APjAAAV3f7AZnU3Tk8aY0AaHsY/OcIsIZgYos/tV88dOCZFs5utUO4Lh
	rE83rxG+PYDMkN0hgfAyODN9QydZH5+Ygn0pXINXDEwHKTcQi+er6SzZqK4/o8T1Dx9q/dgbdu5
	m4ZMqrfB8TREwJ7VdxurH40YXoA4i/sltqC4pPKwXyd5elpnU8Er9nCjjmaCy3ZBqIw==
X-Received: by 2002:a9d:39a6:: with SMTP id y35mr1470473otb.81.1560457298975;
        Thu, 13 Jun 2019 13:21:38 -0700 (PDT)
X-Received: by 2002:a9d:39a6:: with SMTP id y35mr1470440otb.81.1560457298372;
        Thu, 13 Jun 2019 13:21:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560457298; cv=none;
        d=google.com; s=arc-20160816;
        b=chZdCimTh0QWJ6PqqBakc49NQJxbS01enr7f5E5HvtnIeelfyqovkXVkwo3fr0sUms
         6MVjupdi7pNA0KB9ubpY0BlLOGfpKf/xY2iwB1tv5UkFrkKl+WF5fSD9dQED98DcM4t6
         rVg5Ctd08gBQSyIUaN9u70YS5vJdpc5jxOP0IyOLYDqO2YNfy03bXQyMgFjmHPd8QIr9
         h8ugQtmxeWPivxJ6V60xBNDax0NXqtNrFDTF9V2wAkDkiQdZzprQ7A+xbBIC+s/tFH1m
         vQu50MxjSB3sNtnVjlS/bP6C/rcgr350ggAHhia0wax+GjW5CRaI1pRiJcErAyk0b3px
         dKCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=8C1DPfN32M3hy89DclQbm10r/6nHw68ntXJVKpP7b9Y=;
        b=FUJtmC4OoP7HGuw45T4sMYA+Ul8fMp2/eQ9X4MxCRHBFzPPCisVqLHZpkqCMi/2sLj
         8ndf6VoiRdDQQz8/WxfOHQ2O3IqkxvNPHNCHcXyPqB77VugwM2Yc5McGJb/XZLGNKF4E
         /Da3h1WOEyHYLzb3oqt7iLcLyXzUBYiW30ZtXcfvOcg3cQbE8Iw0xX/bX08YhFgEhM7k
         EfN5hWtgst7eM7Mp8CtfQE5utVBXTIsbwiss/fEGNKyUN2OFYkFFje/5Dy9SGZhTw9G3
         Okego/p6veCM2ePyxUeCGRipAjzOG/71dXX5/QB7panFdnu9PXh2HPRAC56JBI3OAXit
         jE+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=f8QwnyQT;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c15sor537539otr.178.2019.06.13.13.21.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 13:21:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=f8QwnyQT;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=8C1DPfN32M3hy89DclQbm10r/6nHw68ntXJVKpP7b9Y=;
        b=f8QwnyQT51rXgqH07uWM2kqXhbWRJNnV74LW/yRvR2x776SPj5Pfk2O+kG2AmGkO8T
         trYSPptgpa5/GXF/WDtITF1+EbHojK5NlrUWtkmk/zSrRfZi5l9VktyZN13ffa5Hc6Ev
         0msFAvfYWphm24CFoDY7wyxaucG4FVHRbGTisLD6oBUXsztdH3fUW9TN5VMHOpT3cvr0
         sCPmY0lNjqi+LcWw5XMhpewNnmhVYTSePA2WSDRkeUne9k6nQVV9YwwkLBcNkm4aAYQp
         hwiX33VeD0WOTvpFOoQcm71sdbaOX7SnxHZ9aM2nx+Itu4NnNsqFxSwSt5OwJVwaJq25
         COoQ==
X-Google-Smtp-Source: APXvYqyjtP3QbVJvzI3dCCMhA8qeDJqydQ8D7TK+PF2b5eiWZzF3IhMkwvK4lONxsyfmaoM/M+8Dcj6PJdtpVy6CFmg=
X-Received: by 2002:a9d:7248:: with SMTP id a8mr1406727otk.363.1560457298006;
 Thu, 13 Jun 2019 13:21:38 -0700 (PDT)
MIME-Version: 1.0
References: <20190613094326.24093-1-hch@lst.de> <CAPcyv4jBdwYaiVwkhy6kP78OBAs+vJme1UTm47dX4Eq_5=JgSg@mail.gmail.com>
 <283e87e8-20b6-0505-a19b-5d18e057f008@deltatee.com>
In-Reply-To: <283e87e8-20b6-0505-a19b-5d18e057f008@deltatee.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 13 Jun 2019 13:21:27 -0700
Message-ID: <CAPcyv4hx=ng3SxzAWd8s_8VtAfoiiWhiA5kodi9KPc=jGmnejg@mail.gmail.com>
Subject: Re: dev_pagemap related cleanups
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-nvdimm <linux-nvdimm@lists.01.org>, nouveau@lists.freedesktop.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>, linux-pci@vger.kernel.org, 
	Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 1:18 PM Logan Gunthorpe <logang@deltatee.com> wrote=
:
>
>
>
> On 2019-06-13 12:27 p.m., Dan Williams wrote:
> > On Thu, Jun 13, 2019 at 2:43 AM Christoph Hellwig <hch@lst.de> wrote:
> >>
> >> Hi Dan, J=C3=A9r=C3=B4me and Jason,
> >>
> >> below is a series that cleans up the dev_pagemap interface so that
> >> it is more easily usable, which removes the need to wrap it in hmm
> >> and thus allowing to kill a lot of code
> >>
> >> Diffstat:
> >>
> >>  22 files changed, 245 insertions(+), 802 deletions(-)
> >
> > Hooray!
> >
> >> Git tree:
> >>
> >>     git://git.infradead.org/users/hch/misc.git hmm-devmem-cleanup
> >
> > I just realized this collides with the dev_pagemap release rework in
> > Andrew's tree (commit ids below are from next.git and are not stable)
> >
> > 4422ee8476f0 mm/devm_memremap_pages: fix final page put race
> > 771f0714d0dc PCI/P2PDMA: track pgmap references per resource, not globa=
lly
> > af37085de906 lib/genalloc: introduce chunk owners
> > e0047ff8aa77 PCI/P2PDMA: fix the gen_pool_add_virt() failure path
> > 0315d47d6ae9 mm/devm_memremap_pages: introduce devm_memunmap_pages
> > 216475c7eaa8 drivers/base/devres: introduce devm_release_action()
> >
> > CONFLICT (content): Merge conflict in tools/testing/nvdimm/test/iomap.c
> > CONFLICT (content): Merge conflict in mm/hmm.c
> > CONFLICT (content): Merge conflict in kernel/memremap.c
> > CONFLICT (content): Merge conflict in include/linux/memremap.h
> > CONFLICT (content): Merge conflict in drivers/pci/p2pdma.c
> > CONFLICT (content): Merge conflict in drivers/nvdimm/pmem.c
> > CONFLICT (content): Merge conflict in drivers/dax/device.c
> > CONFLICT (content): Merge conflict in drivers/dax/dax-private.h
> >
> > Perhaps we should pull those out and resend them through hmm.git?
>
> Hmm, I've been waiting for those patches to get in for a little while now=
 ;(

Unless Andrew was going to submit as v5.2-rc fixes I think I should
rebase / submit them on current hmm.git and then throw these cleanups
from Christoph on top?

