Return-Path: <SRS0=GuKW=WG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EBDFC433FF
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 17:52:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A28732085A
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 17:52:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A28732085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2EFA6B0003; Sat, 10 Aug 2019 13:52:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE07D6B0005; Sat, 10 Aug 2019 13:52:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCD806B0006; Sat, 10 Aug 2019 13:52:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id A94EE6B0003
	for <linux-mm@kvack.org>; Sat, 10 Aug 2019 13:52:45 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id c22so880517qta.8
        for <linux-mm@kvack.org>; Sat, 10 Aug 2019 10:52:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=66SEGc5TGIf1NyUu+jEpEXEpotUOCLnMVCZU4G+UmoQ=;
        b=HgNGANXi94YlQvjE13QTVAbffhl9QfcnlFJcctN6WftMruw3OhWbXdQM3UlC216XL+
         2jGKAsnYZmJJ4+eiANiJdDikI77vSCv53rLzOwsg8L4qNN/tKELuNU74Enhwr9ndPi9B
         cuxdluCcNp8u+Hyd4B34GQkZPxNrrQE1/jjl/YgT6HiTlLLRuK4r99Rftn/jzBqr0Q9w
         l81IX1/YaqCRutXZSq9+Wjl3uKciBDVQ3s/Tri5143PR2M3BswuOAnj2NEFNfJDNmihV
         VR3Xhadjlu7jDltC/jHi4W25uGRUf8sdjj4Hx+q0bNf+L9bTCZ+vLGwnMQWRtivLDRUM
         XSGA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV4T3S/JKRYmwSNFdWNdodLvHb62wya91zIVi10ASMrg46eafdZ
	UjUjqcysFepsm3FFLAbpvXnjEzwQ1keI4Q1zYsiN5ABHIa83gWqeHRE2Mo7lnhvoEeA03xJsP5L
	qhWFgWGWbeS6fPj73euGTJLGOZVLM/7cpMfXmyflpLnaVf7YR0Pqd++Usm0p8JhRH8g==
X-Received: by 2002:a0c:9e27:: with SMTP id p39mr23519646qve.151.1565459565427;
        Sat, 10 Aug 2019 10:52:45 -0700 (PDT)
X-Received: by 2002:a0c:9e27:: with SMTP id p39mr23519624qve.151.1565459564796;
        Sat, 10 Aug 2019 10:52:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565459564; cv=none;
        d=google.com; s=arc-20160816;
        b=LKsAlOwvPbrln7Qi1sfMInDkul0fBZoE72eN30IT+vdojj4KfKTFqCjgcU+q0/FzXV
         XgPrTyIx7y7sTudc4GFKgS+zSZ2P9mSS92rgi7sjV4VjdrwXusZdL4Umg1/7+Iv/vhfa
         +6YatiFf1pepXe+B9YMEkoZ0myM0kCOa+d+u1ExWstKvZ7HvL4qsfSrlHM9vT3eAqUKs
         k7fHDbAxx0ayv2XGMhwuVvwcliCTFzd0bBM6b91t43IMMRKIsHE3FT2gWZCWtN6PMW20
         xWgEaz7sfAh2/SZ+yJgMSosh6GIHBRuAKZLUynR8nfTUK75L6Bu0uJyJavkLyagXr7NV
         +zLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=66SEGc5TGIf1NyUu+jEpEXEpotUOCLnMVCZU4G+UmoQ=;
        b=N059K5P9kE2VTZtlgM3rsVR96OFcrA+VG0cQ/9lF5NnlrVl+dSqRHtNoM4NrJwhGQA
         8CS6TICtAiopEeJeIqTu0V+HyFCpB6k7ygn4OwDdylIhpQyQ0Oyt/eRVR1uiZ4RVhT2j
         Gs1I1qW4xBdBfJ8sUKtipimr0JmRgz31e8gbPVTA5/29KyGKM21dQFtnQ9bF3JI3Q641
         WAiDCgYPLoTbYTKRbE3TwDEqYxktd/8c3dRNPWR13NiuvQrEykNhSlBfhLPbzheG5OmM
         qMbJj6wRZoWgLsLwN0u8iMWnBU5l8E2Y5jx8q99/19ZL5FXcTXjZGwkfHYp9qgW91r3w
         Ek9A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i11sor14479422qtr.15.2019.08.10.10.52.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Aug 2019 10:52:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyu+J3eoZAKc/L0K7nzHrnvjWmGtHdW7l8r8vj9yQS0QK9zcmeYBT3jtDeUTZAm2K2OrM0azQ==
X-Received: by 2002:ac8:2fc8:: with SMTP id m8mr23627567qta.269.1565459564445;
        Sat, 10 Aug 2019 10:52:44 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id a135sm45568245qkg.72.2019.08.10.10.52.40
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 10 Aug 2019 10:52:43 -0700 (PDT)
Date: Sat, 10 Aug 2019 13:52:38 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, jgg@ziepe.ca
Subject: Re: [PATCH V5 0/9] Fixes for vhost metadata acceleration
Message-ID: <20190810134948-mutt-send-email-mst@kernel.org>
References: <20190809054851.20118-1-jasowang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809054851.20118-1-jasowang@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 01:48:42AM -0400, Jason Wang wrote:
> Hi all:
> 
> This series try to fix several issues introduced by meta data
> accelreation series. Please review.
> 
> Changes from V4:
> - switch to use spinlock synchronize MMU notifier with accessors
> 
> Changes from V3:
> - remove the unnecessary patch
> 
> Changes from V2:
> - use seqlck helper to synchronize MMU notifier with vhost worker
> 
> Changes from V1:
> - try not use RCU to syncrhonize MMU notifier with vhost worker
> - set dirty pages after no readers
> - return -EAGAIN only when we find the range is overlapped with
>   metadata
> 
> Jason Wang (9):
>   vhost: don't set uaddr for invalid address
>   vhost: validate MMU notifier registration
>   vhost: fix vhost map leak
>   vhost: reset invalidate_count in vhost_set_vring_num_addr()
>   vhost: mark dirty pages during map uninit
>   vhost: don't do synchronize_rcu() in vhost_uninit_vq_maps()
>   vhost: do not use RCU to synchronize MMU notifier with worker
>   vhost: correctly set dirty pages in MMU notifiers callback
>   vhost: do not return -EAGAIN for non blocking invalidation too early
> 
>  drivers/vhost/vhost.c | 202 +++++++++++++++++++++++++-----------------
>  drivers/vhost/vhost.h |   6 +-
>  2 files changed, 122 insertions(+), 86 deletions(-)

This generally looks more solid.

But this amounts to a significant overhaul of the code.

At this point how about we revert 7f466032dc9e5a61217f22ea34b2df932786bbfc
for this release, and then re-apply a corrected version
for the next one?


> -- 
> 2.18.1

