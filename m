Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEA59C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 06:07:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99B3920828
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 06:07:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99B3920828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 308D08E0037; Thu, 25 Jul 2019 02:07:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 292328E0031; Thu, 25 Jul 2019 02:07:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 159F18E0037; Thu, 25 Jul 2019 02:07:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id E3D7E8E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 02:07:22 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id o11so35042889qtq.10
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 23:07:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=PypuxeYUycvP8/id8ByTKjToCiSzfpYpICZWRirx1lg=;
        b=RIsouCB+TE5kWPhF0eTC9vJPmZOF6XAfYZ+6cnKyIIVIrzELMxlSHeGdtgj93iBLzT
         4MHQDVPIRqwPqfU43oUBmwD8YHs2zIv6yZYgtLyDB3Wjjs0WyWEzVfHPtcFpymOfUPyk
         hQ4swtDmVkpqHm2jm2BuzMoWjucBvoBtBvAciYMQis1ltoFICFCK/AUr6TNXmuZwzdk6
         mWtPX20TBNhhslFqgutDqg5BzM4ekZEOiY6fMLlVzYFbagIGmgz6neKT91AfHZ6HM8fw
         fPrXlxZiK+A/AFmcee21srDv0/xhYE4fgZoJs5jRQiwFnyBu3CF6OHp44elOOBZxWZLn
         Whzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVib3iMH6QvHWjGr3XAZG9dezVg7U/w2iHbpAy6WZgdBpIWbggf
	2rgx+MQ5Yjhe2NLXEbkFjiAldcytyZJjhniCuAOrITPVeKPx8xlMgRb43DXMf+BaYqdK+75etfs
	2/TpT2V5UbdphehRjuSJ1VMBE1OJ18gY9AhkOqEiapgzgdvhW6gLhw5mgkB75/+03fA==
X-Received: by 2002:a0c:d11c:: with SMTP id a28mr61760164qvh.180.1564034842690;
        Wed, 24 Jul 2019 23:07:22 -0700 (PDT)
X-Received: by 2002:a0c:d11c:: with SMTP id a28mr61760130qvh.180.1564034842034;
        Wed, 24 Jul 2019 23:07:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564034842; cv=none;
        d=google.com; s=arc-20160816;
        b=r1mrp6IxMZvPccjVJKb8dinsSApodL9Jv1chihPbh5gJT03ae7AXkd+Xl6fJ03emZw
         sL3cl4X29EMJmfkf6lQHjYjcLgVk5Zc3HIk1XDoqM9BXHTrCNqP+Nq0t2biOwdKjK3Jg
         bbL9Ne2J8CsL3OW/sSO0/becVKg7FX2u/xT5IEbKGKZMNk3jmSkFH6Z9Ln244wjI7jVb
         xp5to24Qj7rrJtOTgP+4x3QGVn8gQ2eoYgwISa+89X02cm4BMyp05ecq9KXcliL5gmZs
         WSXF4yOywSzn+Y2XFLaqe5Eg2696TpSPhmBUcpd273LDBF0+l9KI7MjMw/Lsp/ibBcGe
         Scwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=PypuxeYUycvP8/id8ByTKjToCiSzfpYpICZWRirx1lg=;
        b=BXXgHgNm8shART5e3N3Imv6HXQDAhSlqUGazoFIPtHEUQtCge/wuGMnvgS0z28fk1T
         4xyOjg5BDBcNjNOKtb+U1Qjw/fquGqhwk+hEHx1Ny5JGvH6m6OUO9dv65r3TonUcOeOD
         GokIaBATZk9vVSOlu2x3xEMFk0ZW4uLfP1J2BJ8mADSAJjRyPfmdaTzzdnuTj8atcSDe
         g9Gh2dvQxm6z0ZNgKwo8sxZR6BcX9tXLDJk5IbPZtVJFZ0iMM463IbEGZFcgCM9HAXGU
         GJkLpCQ7ulTgT6+N07gIXfE5eAEe+WdpXZUYlKwIcGnvstHG3Sjwjy302ZLUUcUinA0l
         ZDHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i11sor64177044qtr.15.2019.07.24.23.07.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 23:07:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwDG4zJA9IYJPz7Qr+XKlkzlftA6U4LgG7wMuKSilowIIArQBRTAM0ujQelE37C7kSAHEerpQ==
X-Received: by 2002:ac8:c45:: with SMTP id l5mr58170164qti.63.1564034841780;
        Wed, 24 Jul 2019 23:07:21 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id k38sm27828576qtk.10.2019.07.24.23.07.16
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 23:07:20 -0700 (PDT)
Date: Thu, 25 Jul 2019 02:07:13 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, nitesh@redhat.com,
	kvm@vger.kernel.org, david@redhat.com, dave.hansen@intel.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, yang.zhang.wz@gmail.com,
	pagupta@redhat.com, riel@surriel.com, konrad.wilk@oracle.com,
	lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com,
	pbonzini@redhat.com, dan.j.williams@intel.com
Subject: Re: [PATCH v2 QEMU] virtio-balloon: Provide a interface for "bubble
 hinting"
Message-ID: <20190725020425-mutt-send-email-mst@kernel.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <20190724171050.7888.62199.stgit@localhost.localdomain>
 <20190724173403-mutt-send-email-mst@kernel.org>
 <ada4e7d932ebd436d00c46e8de699212e72fd989.camel@linux.intel.com>
 <20190724180552-mutt-send-email-mst@kernel.org>
 <6bbead1f2d7b3aa77a8e78ffc6bbbb6d0d68c12e.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6bbead1f2d7b3aa77a8e78ffc6bbbb6d0d68c12e.camel@linux.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 03:27:37PM -0700, Alexander Duyck wrote:
> On Wed, 2019-07-24 at 18:08 -0400, Michael S. Tsirkin wrote:
> > On Wed, Jul 24, 2019 at 03:03:56PM -0700, Alexander Duyck wrote:
> > > On Wed, 2019-07-24 at 17:38 -0400, Michael S. Tsirkin wrote:
> > > > On Wed, Jul 24, 2019 at 10:12:10AM -0700, Alexander Duyck wrote:
> > > > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > > 
> > > > > Add support for what I am referring to as "bubble hinting". Basically the
> > > > > idea is to function very similar to how the balloon works in that we
> > > > > basically end up madvising the page as not being used. However we don't
> > > > > really need to bother with any deflate type logic since the page will be
> > > > > faulted back into the guest when it is read or written to.
> > > > > 
> > > > > This is meant to be a simplification of the existing balloon interface
> > > > > to use for providing hints to what memory needs to be freed. I am assuming
> > > > > this is safe to do as the deflate logic does not actually appear to do very
> > > > > much other than tracking what subpages have been released and which ones
> > > > > haven't.
> > > > > 
> > > > > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > 
> > > > BTW I wonder about migration here.  When we migrate we lose all hints
> > > > right?  Well destination could be smarter, detect that page is full of
> > > > 0s and just map a zero page. Then we don't need a hint as such - but I
> > > > don't think it's done like that ATM.
> > > 
> > > I was wondering about that a bit myself. If you migrate with a balloon
> > > active what currently happens with the pages in the balloon? Do you
> > > actually migrate them, or do you ignore them and just assume a zero page?
> > 
> > Ignore and assume zero page.
> > 
> > > I'm just reusing the ram_block_discard_range logic that was being used for
> > > the balloon inflation so I would assume the behavior would be the same.
> > > 
> > > > I also wonder about interaction with deflate.  ATM deflate will add
> > > > pages to the free list, then balloon will come right back and report
> > > > them as free.
> > > 
> > > I don't know how likely it is that somebody who is getting the free page
> > > reporting is likely to want to also use the balloon to take up memory.
> > 
> > Why not?
> 
> The two functions are essentially doing the same thing. The only real
> difference is enforcement. If the balloon takes the pages the guest cannot
> get them back. I suppose there might be some advantage if you are wanting
> for force shrink a guest but that would be about it.

Yea, that's a common use of the balloon ATM. Helps partition
the host so guests don't conflict. OTOH deflate on oom thing
probably will never be used with hinting.

> > > However hinting on a page that came out of deflate might make sense when
> > > you consider that the balloon operates on 4K pages and the hints are on 2M
> > > pages. You are likely going to lose track of it all anyway as you have to
> > > work to merge the 4K pages up to the higher order page.
> > 
> > Right - we need to fix inflate/deflate anyway.
> > When we do, we can do whatever :)
> 
> One thing we could probably look at for the future would be to more
> closely merge the balloon and this reporting logic. Ideally the balloon
> would grab pages that were already hinted in order to enforce a certain
> size limit on the guest, and then when it gave the pages back they would
> retain their hinted status if possible.
> 
> The only problem is that right now both of those require that
> hinting/reporting be active for the zone being accessed since we otherwise
> don't have pointers to the pages at the head of the "hinted" list.

I guess I was talking about reworking host/guest ABI, you were
talking about the internals. So both need to change :)

