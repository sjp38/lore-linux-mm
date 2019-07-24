Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1EABFC76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 22:27:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4D4B21850
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 22:27:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4D4B21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A9FE8E0011; Wed, 24 Jul 2019 18:27:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65A428E0002; Wed, 24 Jul 2019 18:27:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 548DE8E0011; Wed, 24 Jul 2019 18:27:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B9028E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 18:27:39 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x18so29449945pfj.4
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:27:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=5EHb0DmPHlH6TD4NdiPQtwNlAcPsCzOoRyix/eQ2Fuw=;
        b=ek0vbdMYDfBRvuakTF5+/7Vre9eLUyw91R7LIs4vUjHdHqZObchv12J/YADI0KkbTc
         pl30S4VBqJ7Sy7pU4GOOSk8PIzAmT2x7CIyaJOwn1zInevVplUyRFgiPPrNUtYdJjkkz
         arTOoUNJ27XDnUxrH2W64SQ4cm9cO+QacJ3IEre5bfcXM8K52CClPQvZnh4hzRVw1laZ
         CE/ViAttqGotFY9OQIKOGsmGbrBcs/EOtVzkSQ5tDCf51fAYywkvMxEq1YpIfZWkOcW4
         vhbTsdzd0JdYVo0+FMSZQeUJvWXY7t8nCRWYlKyyFjcAtEXKbEyPDkSSr1g6PD6yOlru
         nkgg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWZ9QHgMU9RQdVWibLplQtEBLU7Js1t6NTIjzUhLs6/yI+E8gXX
	jsg+QNHij+I79XKBLwvAyWbXvRrljpMxyI8pWVFfIN2ccM195BLmtbH/a3tE5LgdhDwQngPgQdr
	Cf0H68sKTjbe2mKpuuho5FnFKP/G67i9/QPRNJUzfyHZixPFnqNnzLV2UFBBl7Bd4BA==
X-Received: by 2002:a17:90a:360b:: with SMTP id s11mr88635341pjb.51.1564007258596;
        Wed, 24 Jul 2019 15:27:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8NOOz/Mf2VpscE8ksT0jWSe5XoItxnpJI/ouicz4s//u/4NUsg/z9kSfHISzaVACa81he
X-Received: by 2002:a17:90a:360b:: with SMTP id s11mr88635307pjb.51.1564007257813;
        Wed, 24 Jul 2019 15:27:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564007257; cv=none;
        d=google.com; s=arc-20160816;
        b=kHs08KrMr2gKDnY3eFj0D+DNOdqKEQYWU1mpwoVy9iTRq75ADVqrB6TykEAsqKjsQE
         3JO4TTmMUX8iWvn41BzRcBhBYAvCYQbmXThc/nhTtaOsTZWCqm3LVwlNLL41Dqx8Xfnj
         86/Y6gWWN8Ex8CH7MvzKi6209jCTIqXz/H+Lrrc1T3H9ykJ2mITESaxAyASR1pi30CLm
         uO/VEGGfZ9KCbwVuqYvWe0XcSmXbAa05sQVTlnuSDnx0WVUpAifAAIAUrIimzDMbEVzn
         01ieP7dHUVUXn4x213nSihY6zK4icWSGAlimd21mw2OqNwRmkYIsJVqJTHL4OQoRewrQ
         V5nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=5EHb0DmPHlH6TD4NdiPQtwNlAcPsCzOoRyix/eQ2Fuw=;
        b=KMbeVVuCR2Dg2yNyT57tNHBnMFOORZVLZxZ5p2SYsn7mxg6CmuiDAxDveEeN9+VeQi
         zg6rZBrKGbO65ldDTFATOp3PngtgUq96RL4uCumSjD0kVwZOndzwAtqIgBsibLRvtnlF
         fg+W+/1PDeQvts6FVZ0OpFd8xU8Mv9zfXprSEaYhJo0PNWm6wkN8zp92ex2euPeHs7mU
         3Pz16eVt9LhlZVRd2OQNx2nvLSBP3INV/f9HZJBFBuqt4T+64rdx5vl1BcisbSAGNOVQ
         WB8tlUE0AnMwopsjlOJzoI2piGgNYHyexLkIqwFMrJ8JABo2jo+5i6aKamIAawJ2l2Bd
         6/iQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 1si16486412pgu.504.2019.07.24.15.27.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 15:27:37 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jul 2019 15:27:37 -0700
X-IronPort-AV: E=Sophos;i="5.64,304,1559545200"; 
   d="scan'208";a="163991221"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga008-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jul 2019 15:27:37 -0700
Message-ID: <6bbead1f2d7b3aa77a8e78ffc6bbbb6d0d68c12e.camel@linux.intel.com>
Subject: Re: [PATCH v2 QEMU] virtio-balloon: Provide a interface for "bubble
 hinting"
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, nitesh@redhat.com, 
 kvm@vger.kernel.org, david@redhat.com, dave.hansen@intel.com, 
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org,  yang.zhang.wz@gmail.com, pagupta@redhat.com,
 riel@surriel.com,  konrad.wilk@oracle.com, lcapitulino@redhat.com,
 wei.w.wang@intel.com,  aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com
Date: Wed, 24 Jul 2019 15:27:37 -0700
In-Reply-To: <20190724180552-mutt-send-email-mst@kernel.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
	 <20190724171050.7888.62199.stgit@localhost.localdomain>
	 <20190724173403-mutt-send-email-mst@kernel.org>
	 <ada4e7d932ebd436d00c46e8de699212e72fd989.camel@linux.intel.com>
	 <20190724180552-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-07-24 at 18:08 -0400, Michael S. Tsirkin wrote:
> On Wed, Jul 24, 2019 at 03:03:56PM -0700, Alexander Duyck wrote:
> > On Wed, 2019-07-24 at 17:38 -0400, Michael S. Tsirkin wrote:
> > > On Wed, Jul 24, 2019 at 10:12:10AM -0700, Alexander Duyck wrote:
> > > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > 
> > > > Add support for what I am referring to as "bubble hinting". Basically the
> > > > idea is to function very similar to how the balloon works in that we
> > > > basically end up madvising the page as not being used. However we don't
> > > > really need to bother with any deflate type logic since the page will be
> > > > faulted back into the guest when it is read or written to.
> > > > 
> > > > This is meant to be a simplification of the existing balloon interface
> > > > to use for providing hints to what memory needs to be freed. I am assuming
> > > > this is safe to do as the deflate logic does not actually appear to do very
> > > > much other than tracking what subpages have been released and which ones
> > > > haven't.
> > > > 
> > > > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > 
> > > BTW I wonder about migration here.  When we migrate we lose all hints
> > > right?  Well destination could be smarter, detect that page is full of
> > > 0s and just map a zero page. Then we don't need a hint as such - but I
> > > don't think it's done like that ATM.
> > 
> > I was wondering about that a bit myself. If you migrate with a balloon
> > active what currently happens with the pages in the balloon? Do you
> > actually migrate them, or do you ignore them and just assume a zero page?
> 
> Ignore and assume zero page.
> 
> > I'm just reusing the ram_block_discard_range logic that was being used for
> > the balloon inflation so I would assume the behavior would be the same.
> > 
> > > I also wonder about interaction with deflate.  ATM deflate will add
> > > pages to the free list, then balloon will come right back and report
> > > them as free.
> > 
> > I don't know how likely it is that somebody who is getting the free page
> > reporting is likely to want to also use the balloon to take up memory.
> 
> Why not?

The two functions are essentially doing the same thing. The only real
difference is enforcement. If the balloon takes the pages the guest cannot
get them back. I suppose there might be some advantage if you are wanting
for force shrink a guest but that would be about it.

> > However hinting on a page that came out of deflate might make sense when
> > you consider that the balloon operates on 4K pages and the hints are on 2M
> > pages. You are likely going to lose track of it all anyway as you have to
> > work to merge the 4K pages up to the higher order page.
> 
> Right - we need to fix inflate/deflate anyway.
> When we do, we can do whatever :)

One thing we could probably look at for the future would be to more
closely merge the balloon and this reporting logic. Ideally the balloon
would grab pages that were already hinted in order to enforce a certain
size limit on the guest, and then when it gave the pages back they would
retain their hinted status if possible.

The only problem is that right now both of those require that
hinting/reporting be active for the zone being accessed since we otherwise
don't have pointers to the pages at the head of the "hinted" list.

