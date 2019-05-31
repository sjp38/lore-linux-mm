Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D7E4C28CC3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 04:17:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E970120717
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 04:17:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="CS6BO+r0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E970120717
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A6F06B0278; Fri, 31 May 2019 00:17:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 657176B027A; Fri, 31 May 2019 00:17:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 545E46B027C; Fri, 31 May 2019 00:17:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 292E96B0278
	for <linux-mm@kvack.org>; Fri, 31 May 2019 00:17:22 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id x23so3911623otp.5
        for <linux-mm@kvack.org>; Thu, 30 May 2019 21:17:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=/b7zMtPyyoD7Z9H0ZcAMOMDecBLUC3B4wOXIPVDeoac=;
        b=VzSWUSxEys4prwNleiMYTReVYnSujn7XRCyWdFGZ9l96ptiLBGNBmyeu00RbEpD75t
         cxg6JGQmQAfVEqFtkKoBfIHkJy43zQaq5BLRks7sAZc9JAJZOL+5AdFYqLeTWGCkmF2y
         qXqU/tSI1f7pRUJgYmw3kLwpOwgzlsY5cQdIKfgrWnIXfbnTl54sukHP8dfwBjkVJfku
         bE7U03hKkjaAODJN8ecexZ16SF3BWrTkXcs6FLICul7SBuCu9uiT0fQkn/ixwaZsXC2K
         uug3QG5cSkQGMsP4duyhI7Q2qezIws/SGuTGxVmXyVE2fUnZuXicBKKSDdGWs3Gh8Fig
         mEjA==
X-Gm-Message-State: APjAAAX7Rlo6g7+KMhaS+wUKG6yXUgs4tkqYkMDPGn/v0jAoKsGTc+pk
	jJ/hl4DAP0NftSLYi2dziD9pHZ6mdSpbXArzw6PKa5T7BCR7j2iAPCWRLaySQKH2gcvpfFQTxRt
	PvwsiCIVHrTm+ccBvfjxaU46V0Db5TdGNivZ9bGDK+gcfMwsrv+LHTyS/CMwcarEY9A==
X-Received: by 2002:aca:3645:: with SMTP id d66mr4660112oia.64.1559276241642;
        Thu, 30 May 2019 21:17:21 -0700 (PDT)
X-Received: by 2002:aca:3645:: with SMTP id d66mr4660086oia.64.1559276240843;
        Thu, 30 May 2019 21:17:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559276240; cv=none;
        d=google.com; s=arc-20160816;
        b=DPizzRBJPCSdCSF5DfKTsw3r4UvXM4fMieuklLJSOjjQO9OV7C6VKdmJnl6b6s6fqu
         jAqvOW7bJmIFzFciQFGXJHUaE/Uj2XUwer2/8GhAuDRyGV0Dj15xRiw+pIaIsMnU5RI5
         /3TPT7EX4QZAZOGQSzzIUz7agyn8NbZgN3y8Vc+ttpIHtX6ytaEA9S+PuXzyIIxaGhGx
         Tct3bqnHQLbFcDak82p42Lo4UnDwxsf5XZc8jbrx9SF4YhU9Jlc9AQVRlV+EATjiN+An
         2dzrNskOGDm0OEMod1BVJuMASvyydgzdJsb9VSpEMb+CKnkVscjLLcACjnU4b0xihdWu
         hbJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=/b7zMtPyyoD7Z9H0ZcAMOMDecBLUC3B4wOXIPVDeoac=;
        b=qq1+s8xGzs8gJmM+U89Vcrrc8sWWs+XiZ/kG5T7r1lKXbeKJGIKBMlCviTiRqIe0Gz
         EVK9JzSzJVYG++Wj1oX0oUPb1atdV1Kumi2pF53Ef3kqb/WM4qgZPBPA2OxM8NUU8v6Q
         bV2Hk+W/txvk2fIRzIIyIUm2dljBD4DN4c3oeAyzVQi0/iB9tQAJAVMivmSiyiAWFIbQ
         AzuVuzygw+QCiFFGjpCAF9ybA8cjJ0x2sJASaHY3jejkrm/fYL/57mM0tLIgWl3MluQa
         KVVJTPx/RAvfN0W8P2vabbzvU0dy1EIiyqWZ5pv5zfFqycTLyGBv/2jCaLRDE9aDdfR0
         3iJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=CS6BO+r0;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e66sor1596441oif.152.2019.05.30.21.17.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 21:17:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=CS6BO+r0;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/b7zMtPyyoD7Z9H0ZcAMOMDecBLUC3B4wOXIPVDeoac=;
        b=CS6BO+r0JW9ceL73927ELSkUvJTEKgXX5d2GEA9im/bil/5XILFxf2n+JoVpDxAOQg
         p56uLAxZzgOfT0XX0L20Vm5uXC0SUX5RuImjl8jA820vIjcXM8U+KaCcdTSJ2YzayXm5
         ZUgMZ9kBllyvxZiqB6VnZORFA0fvmvRsC5pPOpXZ/w9W6WVqD55gBeW2Hz6ohgTEyc4w
         Dq2w3csJ0lnkSAzAvNlNOyD4zHirgUaJ1ds2y/C0e4G9GrZEDD88y1aN5TaFgceavrGg
         vpL/4OC1IOPY4HHqpSusL5qd2VVww8l+sTRupWy8p8rLplToV7VLd9ZoGdQGLY0xyhev
         VEWA==
X-Google-Smtp-Source: APXvYqwzamlHcYCuE3bgAAH931eEoiZhZTHrMpm39gRZfwR3xH7d4NpA97rBUXSRJY8nTk5JwxAjuIV9SwroNgxQ3Wk=
X-Received: by 2002:aca:6087:: with SMTP id u129mr4677154oib.70.1559276240560;
 Thu, 30 May 2019 21:17:20 -0700 (PDT)
MIME-Version: 1.0
References: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
 <059859ca-3cc8-e3ff-f797-1b386931c41e@deltatee.com> <17ada515-f488-d153-90ef-7a5cc5fefb0f@deltatee.com>
In-Reply-To: <17ada515-f488-d153-90ef-7a5cc5fefb0f@deltatee.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 30 May 2019 21:17:09 -0700
Message-ID: <CAPcyv4jJjCwbWJH648x04Cms1kXY2Cd36bxpgmDGRh+5Van1fQ@mail.gmail.com>
Subject: Re: [PATCH v2 0/6] mm/devm_memremap_pages: Fix page release race
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ira Weiny <ira.weiny@intel.com>, 
	Bjorn Helgaas <bhelgaas@google.com>, Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 12:22 PM Logan Gunthorpe <logang@deltatee.com> wrote:
>
>
>
> On 2019-05-08 11:05 a.m., Logan Gunthorpe wrote:
> >
> >
> > On 2019-05-07 5:55 p.m., Dan Williams wrote:
> >> Changes since v1 [1]:
> >> - Fix a NULL-pointer deref crash in pci_p2pdma_release() (Logan)
> >>
> >> - Refresh the p2pdma patch headers to match the format of other p2pdma
> >>    patches (Bjorn)
> >>
> >> - Collect Ira's reviewed-by
> >>
> >> [1]: https://lore.kernel.org/lkml/155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com/
> >
> > This series looks good to me:
> >
> > Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
> >
> > However, I haven't tested it yet but I intend to later this week.
>
> I've tested libnvdimm-pending which includes this series on my setup and
> everything works great.

Hi Andrew,

With this tested-by can we move forward on this fix set? I'm not aware
of any other remaining comments. Greg had a question about
"drivers/base/devres: Introduce devm_release_action()" that I
answered, but otherwise the feedback has gone silent.

