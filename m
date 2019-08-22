Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B139EC3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 16:24:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 654A723400
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 16:24:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ej6/01HU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 654A723400
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3AEF6B033E; Thu, 22 Aug 2019 12:24:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EECCA6B033F; Thu, 22 Aug 2019 12:24:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD9D96B0340; Thu, 22 Aug 2019 12:24:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0229.hostedemail.com [216.40.44.229])
	by kanga.kvack.org (Postfix) with ESMTP id B68C36B033E
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 12:24:50 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 5B08A68B7
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 16:24:50 +0000 (UTC)
X-FDA: 75850587540.06.gate18_d1515523f72e
X-HE-Tag: gate18_d1515523f72e
X-Filterd-Recvd-Size: 6792
Received: from mail-io1-f67.google.com (mail-io1-f67.google.com [209.85.166.67])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 16:24:49 +0000 (UTC)
Received: by mail-io1-f67.google.com with SMTP id z3so13112898iog.0
        for <linux-mm@kvack.org>; Thu, 22 Aug 2019 09:24:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=O/Rn5qcoy7BQBKOAN8lQSNVqcodC1sml/1HztLPmPY8=;
        b=Ej6/01HUyOove1llDfiVALHzwkEJs2MC17YrBQtF58o9MWpuPRVLfgv2ovJcPGpzk5
         +EVLsiGinkPtC/1jan6MHfnvOxef1kQkVho8kCP9rKHWn/1yJxJtn1/QjcUAgOK/yYae
         4aPn97HI3+G0OJGh9eV3qzmnNewkLku5to/FRSj2mdayX0uU3CDScXgZqys7F3P1GxEx
         oDBve+y3N9OTUVeEBqCpq1PeptowFI//nGCyWZLaGzrN1aWDkKS18wsb2HBm6sy8UlQf
         8tUOsCMr2lwbupWe9lwdwgZ5B3HamP/0/EGRGvARkRR5Zv0IKwtuNHQrIq3e+qP/kKKT
         EZHA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=O/Rn5qcoy7BQBKOAN8lQSNVqcodC1sml/1HztLPmPY8=;
        b=ABtHTm3KIFfUbKFO231IhNA5NyxApESpqqFwMSLuVO3FJwdL+3YycXx+CYTWBhWRgy
         fW+myR4mFdnHyrtusuVkh4QdP9rvG17+s+f6vAtermyA4a47qRWxumQ5U5WGUHmujPiH
         K9lSu/e1wQP17GjSzdSNFWN9UU4rvj8vAsqlbYAwwE1EjoMa4yNSBbhMhaICjwuQ+1aJ
         c7EuVNqgdZOdJFJw5qbPU5v9spESnrpy4woUcX+78m4lLe1VUGOMuUUP/N5PC3EtfSEb
         iTaFHIs+BB0FaqX1tAEBWicAUJ1f4kYLkXKG5u0JHJ4wg/Yl+vYJ5fxSvZR+OvXMmrUU
         1WYw==
X-Gm-Message-State: APjAAAWTJSf4TCF47wqBEXQjTqWlFdd0ijrVCBqbkM8Xop3VgmWqhEQ7
	OoDQkXCooB8tT/NAkFwMkZB7/WjK2/ebg4dHZAA=
X-Google-Smtp-Source: APXvYqyxn9px69p1obzCaGficBATfeUEzqjvnLugjNBV7+KMpVmv/zqC7jztjI0xxXxeLkWOC1qslt97HyHsKgXPSjw=
X-Received: by 2002:a5e:8c11:: with SMTP id n17mr676146ioj.64.1566491088983;
 Thu, 22 Aug 2019 09:24:48 -0700 (PDT)
MIME-Version: 1.0
References: <20190821145806.20926.22448.stgit@localhost.localdomain>
 <20190821145950.20926.83684.stgit@localhost.localdomain> <91355107-ed73-fce5-7051-3a746b526163@redhat.com>
In-Reply-To: <91355107-ed73-fce5-7051-3a746b526163@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 22 Aug 2019 09:24:37 -0700
Message-ID: <CAKgT0UeFyxH9pEsQ+CcZo3c4-GZdqsw6ucPG2KOkefvDvFF94g@mail.gmail.com>
Subject: Re: [virtio-dev] [PATCH v6 4/6] mm: Introduce Reported pages
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, "Michael S. Tsirkin" <mst@redhat.com>, 
	David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, virtio-dev@lists.oasis-open.org, 
	Oscar Salvador <osalvador@suse.de>, Yang Zhang <yang.zhang.wz@gmail.com>, 
	Pankaj Gupta <pagupta@redhat.com>, Rik van Riel <riel@surriel.com>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com, 
	"Wang, Wei W" <wei.w.wang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, 
	Paolo Bonzini <pbonzini@redhat.com>, Dan Williams <dan.j.williams@intel.com>, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 9:19 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>
>
> On 8/21/19 10:59 AM, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> >
> > In order to pave the way for free page reporting in virtualized
> > environments we will need a way to get pages out of the free lists and
> > identify those pages after they have been returned. To accomplish this,
> > this patch adds the concept of a Reported Buddy, which is essentially
> > meant to just be the Uptodate flag used in conjunction with the Buddy
> > page type.
> >
> > It adds a set of pointers we shall call "boundary" which represents the
> > upper boundary between the unreported and reported pages. The general idea
> > is that in order for a page to cross from one side of the boundary to the
> > other it will need to go through the reporting process. Ultimately a
> > free_list has been fully processed when the boundary has been moved from
> > the tail all they way up to occupying the first entry in the list.
> >
> > Doing this we should be able to make certain that we keep the reported
> > pages as one contiguous block in each free list. This will allow us to
> > efficiently manipulate the free lists whenever we need to go in and start
> > sending reports to the hypervisor that there are new pages that have been
> > freed and are no longer in use.
> >
> > An added advantage to this approach is that we should be reducing the
> > overall memory footprint of the guest as it will be more likely to recycle
> > warm pages versus trying to allocate the reported pages that were likely
> > evicted from the guest memory.
> >
> > Since we will only be reporting one zone at a time we keep the boundary
> > limited to being defined for just the zone we are currently reporting pages
> > from. Doing this we can keep the number of additional pointers needed quite
> > small. To flag that the boundaries are in place we use a single bit
> > in the zone to indicate that reporting and the boundaries are active.
> >
> > The determination of when to start reporting is based on the tracking of
> > the number of free pages in a given area versus the number of reported
> > pages in that area. We keep track of the number of reported pages per
> > free_area in a separate zone specific area. We do this to avoid modifying
> > the free_area structure as this can lead to false sharing for the highest
> > order with the zone lock which leads to a noticeable performance
> > degradation.
> [...]
> > +
> > +/* request page reporting on this zone */
> > +void __page_reporting_request(struct zone *zone)
> > +{
> > +     struct page_reporting_dev_info *phdev;
> > +
> > +     rcu_read_lock();
> > +
> > +     /*
> > +      * We use RCU to protect the ph_dev_info pointer. In almost all
> > +      * cases this should be present, however in the unlikely case of
> > +      * a shutdown this will be NULL and we should exit.
> > +      */
> > +     phdev = rcu_dereference(ph_dev_info);
> > +     if (unlikely(!phdev))
> > +             return;
> > +
>
> Just a minor comment here.
> Although this is unlikely to trigger still I think you should release the
> rcu_read_lock before returning.

Thanks for catching that. I will have that fixed for next version.

- Alex

