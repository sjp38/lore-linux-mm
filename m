Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1A6BC76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:24:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94A67229F4
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:24:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94A67229F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33D556B0006; Wed, 24 Jul 2019 15:24:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 314256B0007; Wed, 24 Jul 2019 15:24:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 229078E0002; Wed, 24 Jul 2019 15:24:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id F2EAA6B0006
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:24:44 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id n190so40292968qkd.5
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 12:24:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=6wfpg22kkBGQSGagL3FHOCSJzZUomxdfgUX443/VLoE=;
        b=DfSz0mZv2fLV5O1A0S/Qz/NI31oc35v+jbAc4bkQDUBr9/phJK+bZjWFDWUHVSzNqy
         TUJi7lB7vPNRexw32uTD7NK2VXuDYJT7dP9MYpeuULfB/KZlFdu67XLJweEhwkw2LGIv
         VgPxAVBqdahfJs5gCBD1/2HYTHj61DHSgDCMlbEsElOLSco7YAiNlGeNnbWe6HBoE4tf
         l7XJLVB4IQfiifEJUhrAmAEflozGrCi1jhnv3TfSzejclcSArXfrcoK0+g8cJyrYJm8N
         j0kSO3Lo5+iedUmkGKc8dkIECaFBHaqVv58raouxj/QH1qpUmtISYUtOtlhlDb+6xRdB
         nBOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUZ+PDyWv4QefD+/9K7fRDKGJ+inVbBzk/neA8pOjYda+Wvm0hQ
	LHCNt7xN6LifUFSsdprevKv6GCHy+z4620rtrfrO0uCHzeoVUkZP6eo7RdpknH9zzc68WMYONQq
	Eip8fAIbA8PWdwsz5jR4AdpRO5Z0rN1IFzr6WvopvPy9DlV3y8ZdZjDQ82s+Oz9F9wQ==
X-Received: by 2002:a0c:b115:: with SMTP id q21mr60797183qvc.68.1563996284730;
        Wed, 24 Jul 2019 12:24:44 -0700 (PDT)
X-Received: by 2002:a0c:b115:: with SMTP id q21mr60797146qvc.68.1563996283861;
        Wed, 24 Jul 2019 12:24:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563996283; cv=none;
        d=google.com; s=arc-20160816;
        b=L/TeJGKsKlyHciv0/ChvVpRf+MMbBAxFzmNA/v3GChh9J0KJxk3y+6Tzp73cw5HOPr
         3ctQ/Q9bR0wtU192wPoHbnujlxjQXGmQd/P3WUfCZ0Njj9alVpilfvUSy2BF1XUASdv4
         Td1sYn65oykTolIIrsR4h+RtdwixbWbY7iuNaW1MzHMxFggpOiGOLdaK7MM+1N4meK+f
         0jwyXDjfqiXsJyyogb11jCKnkKgrO9bme5lRSWcSUdvf0kpm7scJifLf3SdfsX5U08ec
         hYJ2D66LvKfBkAJpbClY8YRXZj8rO+Hy9cmO2xMzGR6j7XsoRsjNp+HFKsa5idawgo5N
         hiMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=6wfpg22kkBGQSGagL3FHOCSJzZUomxdfgUX443/VLoE=;
        b=0GzUgJxUAj5wrhwXgfC4te+9ipxQ4MwRqZuE746bNzgmcZ8fjwMIupvVkbVE1yzEM3
         pl0VBurcnwPLRu0MmAszfxwRV7jrQH+Z/G3Gabj5sxIQ5H9PPmRkW6DYoe6OicHkXcRh
         /qXL+5s72XAD4kCSZW7UrMno1zvkSRs0SbxcIAzsIynW4rdCDti6qXjazayFm+A9VWSg
         NcipEocC7vlHob9agDzBUucckTnyDLHmw49cJc+85S5F2fUlHxV7pI+fFomD5kgP2sEP
         ZVd+jHodbM/FTOvjjY98QRPPSjZEj1Atgm/GW4lRv7GIwVIR4704U0BA3oFbLCg/g2w6
         Tnzg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j6sor27481758qke.111.2019.07.24.12.24.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 12:24:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqy77kkB2RpSxBnWenjZ0UwyhE7LKJGBKOCJhGTtIhJgVV+u7LlioVLo64z1RecpigW2GqU0Mw==
X-Received: by 2002:a37:ac19:: with SMTP id e25mr56019402qkm.155.1563996283591;
        Wed, 24 Jul 2019 12:24:43 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id j6sm3007749qtl.85.2019.07.24.12.24.38
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 12:24:42 -0700 (PDT)
Date: Wed, 24 Jul 2019 15:24:35 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, kvm@vger.kernel.org,
	david@redhat.com, dave.hansen@intel.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, yang.zhang.wz@gmail.com,
	pagupta@redhat.com, riel@surriel.com, konrad.wilk@oracle.com,
	lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com,
	pbonzini@redhat.com, dan.j.williams@intel.com,
	alexander.h.duyck@linux.intel.com
Subject: Re: [PATCH v2 0/5] mm / virtio: Provide support for page hinting
Message-ID: <20190724151855-mutt-send-email-mst@kernel.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <0c520470-4654-cdf2-cf4d-d7c351d25e8b@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0c520470-4654-cdf2-cf4d-d7c351d25e8b@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 02:40:02PM -0400, Nitesh Narayan Lal wrote:
> 
> On 7/24/19 12:54 PM, Alexander Duyck wrote:
> > This series provides an asynchronous means of hinting to a hypervisor
> > that a guest page is no longer in use and can have the data associated
> > with it dropped. To do this I have implemented functionality that allows
> > for what I am referring to as page hinting
> >
> > The functionality for this is fairly simple. When enabled it will allocate
> > statistics to track the number of hinted pages in a given free area. When
> > the number of free pages exceeds this value plus a high water value,
> > currently 32,
> Shouldn't we configure this to a lower number such as 16?
> >  it will begin performing page hinting which consists of
> > pulling pages off of free list and placing them into a scatter list. The
> > scatterlist is then given to the page hinting device and it will perform
> > the required action to make the pages "hinted", in the case of
> > virtio-balloon this results in the pages being madvised as MADV_DONTNEED
> > and as such they are forced out of the guest. After this they are placed
> > back on the free list, and an additional bit is added if they are not
> > merged indicating that they are a hinted buddy page instead of a standard
> > buddy page. The cycle then repeats with additional non-hinted pages being
> > pulled until the free areas all consist of hinted pages.
> >
> > I am leaving a number of things hard-coded such as limiting the lowest
> > order processed to PAGEBLOCK_ORDER,
> Have you considered making this option configurable at the compile time?
> >  and have left it up to the guest to
> > determine what the limit is on how many pages it wants to allocate to
> > process the hints.
> It might make sense to set the number of pages to be hinted at a time from the
> hypervisor.
> >
> > My primary testing has just been to verify the memory is being freed after
> > allocation by running memhog 79g on a 80g guest and watching the total
> > free memory via /proc/meminfo on the host. With this I have verified most
> > of the memory is freed after each iteration. As far as performance I have
> > been mainly focusing on the will-it-scale/page_fault1 test running with
> > 16 vcpus. With that I have seen at most a 2% difference between the base
> > kernel without these patches and the patches with virtio-balloon disabled.
> > With the patches and virtio-balloon enabled with hinting the results
> > largely depend on the host kernel. On a 3.10 RHEL kernel I saw up to a 2%
> > drop in performance as I approached 16 threads,
> I think this is acceptable.
> >  however on the the lastest
> > linux-next kernel I saw roughly a 4% to 5% improvement in performance for
> > all tests with 8 or more threads. 
> Do you mean that with your patches the will-it-scale/page_fault1 numbers were
> better by 4-5% over an unmodified kernel?
> > I believe the difference seen is due to
> > the overhead for faulting pages back into the guest and zeroing of memory.
> It may also make sense to test these patches with netperf to observe how much
> performance drop it is introducing.
> > Patch 4 is a bit on the large side at about 600 lines of change, however
> > I really didn't see a good way to break it up since each piece feeds into
> > the next. So I couldn't add the statistics by themselves as it didn't
> > really make sense to add them without something that will either read or
> > increment/decrement them, or add the Hinted state without something that
> > would set/unset it. As such I just ended up adding the entire thing as
> > one patch. It makes it a bit bigger but avoids the issues in the previous
> > set where I was referencing things before they had been added.
> >
> > Changes from the RFC:
> > https://lore.kernel.org/lkml/20190530215223.13974.22445.stgit@localhost.localdomain/
> > Moved aeration requested flag out of aerator and into zone->flags.
> > Moved bounary out of free_area and into local variables for aeration.
> > Moved aeration cycle out of interrupt and into workqueue.
> > Left nr_free as total pages instead of splitting it between raw and aerated.
> > Combined size and physical address values in virtio ring into one 64b value.
> >
> > Changes from v1:
> > https://lore.kernel.org/lkml/20190619222922.1231.27432.stgit@localhost.localdomain/
> > Dropped "waste page treatment" in favor of "page hinting"
> We may still have to try and find a better name for virtio-balloon side changes.
> As "FREE_PAGE_HINT" and "PAGE_HINTING" are still confusing.

Right. In fact I'm not sure why should these be called hints at all.
VIRTIO_BALLOON_F_FREE_PAGE_HINT is a hint because pages might no
longer be free by the time they are reported.

I think of this one as a free page reporting capability.
I don't really mind how are internal kernel functions called,
but I think for virtio uapi things that's a better name.




> > Renamed files and functions from "aeration" to "page_hinting"
> > Moved from page->lru list to scatterlist
> > Replaced wait on refcnt in shutdown with RCU and cancel_delayed_work_sync
> > Virtio now uses scatterlist directly instead of intermedate array
> > Moved stats out of free_area, now in seperate area and pointed to from zone
> > Merged patch 5 into patch 4 to improve reviewability
> > Updated various code comments throughout
> >
> > ---
> >
> > Alexander Duyck (5):
> >       mm: Adjust shuffle code to allow for future coalescing
> >       mm: Move set/get_pcppage_migratetype to mmzone.h
> >       mm: Use zone and order instead of free area in free_list manipulators
> >       mm: Introduce Hinted pages
> >       virtio-balloon: Add support for providing page hints to host
> >
> >
> >  drivers/virtio/Kconfig              |    1 
> >  drivers/virtio/virtio_balloon.c     |   47 ++++++
> >  include/linux/mmzone.h              |  116 ++++++++------
> >  include/linux/page-flags.h          |    8 +
> >  include/linux/page_hinting.h        |  139 ++++++++++++++++
> >  include/uapi/linux/virtio_balloon.h |    1 
> >  mm/Kconfig                          |    5 +
> >  mm/Makefile                         |    1 
> >  mm/internal.h                       |   18 ++
> >  mm/memory_hotplug.c                 |    1 
> >  mm/page_alloc.c                     |  238 ++++++++++++++++++++--------
> >  mm/page_hinting.c                   |  298 +++++++++++++++++++++++++++++++++++
> >  mm/shuffle.c                        |   24 ---
> >  mm/shuffle.h                        |   32 ++++
> >  14 files changed, 796 insertions(+), 133 deletions(-)
> >  create mode 100644 include/linux/page_hinting.h
> >  create mode 100644 mm/page_hinting.c
> >
> > --
> -- 
> Thanks
> Nitesh

