Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 309DBC3A59F
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 01:30:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD832215EA
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 01:30:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=omnibond-com.20150623.gappssmtp.com header.i=@omnibond-com.20150623.gappssmtp.com header.b="tRuQF9NG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD832215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=omnibond.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D2876B0008; Thu, 29 Aug 2019 21:30:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85B3D6B000C; Thu, 29 Aug 2019 21:30:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 721DA6B000D; Thu, 29 Aug 2019 21:30:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0089.hostedemail.com [216.40.44.89])
	by kanga.kvack.org (Postfix) with ESMTP id 4ACAC6B0008
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 21:30:02 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id D39DF1F202
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 01:30:01 +0000 (UTC)
X-FDA: 75877363002.28.snake22_578737c9add28
X-HE-Tag: snake22_578737c9add28
X-Filterd-Recvd-Size: 4620
Received: from mail-yw1-f67.google.com (mail-yw1-f67.google.com [209.85.161.67])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 01:30:01 +0000 (UTC)
Received: by mail-yw1-f67.google.com with SMTP id m11so1851441ywh.3
        for <linux-mm@kvack.org>; Thu, 29 Aug 2019 18:30:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=omnibond-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yDmQxANGbqTJGtO1OhTa4PkciZSXcUVcA6Y2VnUF5Ug=;
        b=tRuQF9NGsWriwh9rOUGWV/XnpvxEIfrIBLDnzsNlL2DcXYptI5uYx9v9XRgXG9ikj+
         lAdRFBmN8WWgzpxjYwMBvOBMGH9vQkyzn/bAHiywFTqTy8Rv0zmy7NK3LdyKNjjgvNdr
         mcLlIarH9lbZWT5t7oU7MIVWXKIhgWd4FFEn+XvtJUHOlIO0rItLGA+Zt6tlzfYijXTt
         MmEvGy0xnlwDGgt/OUq/OkC9egtS+p7sT3eJ3BcAb9vNf6OatXnbSWZ0hHXVonsgbMVH
         pMy2zHMasv+EgzYrXDb3idQdrvXUOVYyNS1FKC2EzXUecfAda8U+O/uwCTXSTJ6SOTSm
         T3ow==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=yDmQxANGbqTJGtO1OhTa4PkciZSXcUVcA6Y2VnUF5Ug=;
        b=L09tZbgjTmusaOIhuzKuWalXuSe4sU4Wgs5eoxynh76Tc5hbbG135S8uxyMwAGpXV2
         JDCCJ8jeNPKoYI7MrvrSB4ljAunxtTEPyYT8EK506VP1SckMi8f7UgzTRORsER+iH1Ro
         eH5oRwD3CkYbI7wp+maL+iEANOFl2v/xuUJwg+ZbPkMdhPIin+mtI7t8MxMDB+jxW4vx
         k48vLHjRYRqfwfHAOQssRuYpPw8FW6E3u0ZXMUrYgHde7OLEQNRat1IR6X6dXBs5Rnpj
         fL6wsrgjESON6a1kiYzs0l+gt+aTVWKDAU11AEP37VijS9I+6lT3sZrxuihVNIleIKJQ
         INhQ==
X-Gm-Message-State: APjAAAWM1mYR5W7cBYrqVUy7AwWr7rsXrx174qzISF1VYfS3mu5Ff137
	G6WYnFHzJt3sjD91A8MEQyP7zoGQFRoas192RYQ7ZA==
X-Google-Smtp-Source: APXvYqyIDKOrxjb28zWL9kagM4gqNHMvZYp0EWQP/d+eBC6/dEWbXTKwXclpCyHxrYDHzsr0mwrMijbohn/hHGTlziQ=
X-Received: by 2002:a81:3681:: with SMTP id d123mr9802172ywa.348.1567128600919;
 Thu, 29 Aug 2019 18:30:00 -0700 (PDT)
MIME-Version: 1.0
References: <20190807013340.9706-1-jhubbard@nvidia.com> <912eb2bd-4102-05c1-5571-c261617ad30b@nvidia.com>
In-Reply-To: <912eb2bd-4102-05c1-5571-c261617ad30b@nvidia.com>
From: Mike Marshall <hubcap@omnibond.com>
Date: Thu, 29 Aug 2019 21:29:50 -0400
Message-ID: <CAOg9mSQKGDywcMde2DE42diUS7J8m74Hdv+xp_PJhC39EXZQuw@mail.gmail.com>
Subject: Re: [PATCH v3 00/39] put_user_pages(): miscellaneous call sites
To: John Hubbard <jhubbard@nvidia.com>
Cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>, 
	Christoph Hellwig <hch@infradead.org>, Dan Williams <dan.j.williams@intel.com>, 
	Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org, 
	ceph-devel <ceph-devel@vger.kernel.org>, devel@driverdev.osuosl.org, 
	devel@lists.orangefs.org, dri-devel@lists.freedesktop.org, 
	intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org, 
	linux-arm-kernel@lists.infradead.org, linux-block@vger.kernel.org, 
	linux-crypto@vger.kernel.org, linux-fbdev@vger.kernel.org, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-media@vger.kernel.org, 
	linux-mm <linux-mm@kvack.org>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, 
	linux-rdma@vger.kernel.org, linux-rpi-kernel@lists.infradead.org, 
	linux-xfs@vger.kernel.org, netdev@vger.kernel.org, rds-devel@oss.oracle.com, 
	sparclinux@vger.kernel.org, x86@kernel.org, xen-devel@lists.xenproject.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi John...

I added this patch series on top of Linux 5.3rc6 and ran
xfstests with no regressions...

Acked-by: Mike Marshall <hubcap@omnibond.com>

-Mike

On Tue, Aug 6, 2019 at 9:50 PM John Hubbard <jhubbard@nvidia.com> wrote:
>
> On 8/6/19 6:32 PM, john.hubbard@gmail.com wrote:
> > From: John Hubbard <jhubbard@nvidia.com>
> > ...
> >
> > John Hubbard (38):
> >   mm/gup: add make_dirty arg to put_user_pages_dirty_lock()
> ...
> >  54 files changed, 191 insertions(+), 323 deletions(-)
> >
> ahem, yes, apparently this is what happens if I add a few patches while editing
> the cover letter... :)
>
> The subject line should read "00/41", and the list of files affected here is
> therefore under-reported in this cover letter. However, the patch series itself is
> intact and ready for submission.
>
> thanks,
> --
> John Hubbard
> NVIDIA

