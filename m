Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2C46C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:31:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B15D4218EA
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:31:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B15D4218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 421AD6B0003; Wed, 24 Jul 2019 15:31:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AB7B8E0002; Wed, 24 Jul 2019 15:31:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 272476B0007; Wed, 24 Jul 2019 15:31:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 049C06B0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:31:13 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id h47so42380960qtc.20
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 12:31:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=+IlR64J5qqrd6EuvuKY5P82x6aYreNnzJ1G6l1ZuUNY=;
        b=t0eWlchQVJUo+VDHggjvoDbwLqjfuomQpTi8vKanhwctEiZEACwuRtZYIDVIFQme7n
         qLkqu/Hif4MlMCNe6dXExdiGWkk7CpufTvupCukKR/NKN8UpVIxAWhhE7zyzYBU1YF47
         4RkGrCKpopcq+yyTelm2Fss7eT8MZx7OTkl6H5tufhVtXwtVLJ4VMTi7Cmsa1C0SwZwB
         CMjm0rvxtoUNB7qukWWe7UGLkgNYNNo+FOODgiDep7txnUo9xF/CIw7S89x+DXfaB0QN
         pXLB35GWkF+1pLJoQq7ctw6QEtdkMP7+ToaSBLMu/DHxpHwmOMG6bSIwSAZ+KLN4Hvb5
         FvtQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV/cw1EaJfFOpGCdMJhb9diMuXsQoPf/Y+l7Uip84DC+i0M0ovT
	zBQU9P4t701A65VpzgdUvMMfq0Se8Dp9PbgENjYht8lBpcWae8FEcrO8aFujS2tlpcdzLnLUEb3
	K60kIdPvY3ogEnIR5caWdTkoLjeupZDEUANF/nu7XM61dkpR9WVqkak3ruxwn/zAlsQ==
X-Received: by 2002:a37:4a8a:: with SMTP id x132mr56650083qka.42.1563996672757;
        Wed, 24 Jul 2019 12:31:12 -0700 (PDT)
X-Received: by 2002:a37:4a8a:: with SMTP id x132mr56650041qka.42.1563996672041;
        Wed, 24 Jul 2019 12:31:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563996672; cv=none;
        d=google.com; s=arc-20160816;
        b=E/VUbpiR+/5vT/pqhDlyT2I9QFOzaktRh8Q9MpmyPemI/NpQfPIXGk8IvT8VU6UvKI
         +JLxv3Y4HHCLu9naUcyZ97Gl5OqTUhlkuKkx/+4R48XXHHp/OPwhawcDZMpPnNWwUedk
         +kHwxfCdtm2vfDJhq1s++0mupHZvSFAlJdTo3U0hDSbr5y6JGg6I9fXU8ogpyfb6tFka
         eN/KPT7PLqJrdCHx5k3FW3FIkTmOdwy45vubWziyouJc6LM3AE1aAjbhTrleN6k+6vkP
         QrPeDcvwT/ZWKVf/8tmY8nkTAXPtUEZDXArBFakajl5+gj321odgDy54Fkw0jFs+HQhF
         52ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=+IlR64J5qqrd6EuvuKY5P82x6aYreNnzJ1G6l1ZuUNY=;
        b=F0OQUdnNRKpBKu9raWujlgSqELyWQtD3cE5ZNG8QpzN2Z+uh0s24ILz/LewQqNPvUN
         qQjCVP/MJ2rvZECX2Wr3AggQwWBvp9UCgFgrQj+24L1jmBw+3wdXme7Lo6bfGbESg+Is
         bZ1LITedW6V7p8jtaHsv4Oa4jP6mOubd/UdqXZe1rUgPVVROZAJ+VL9AIAVcxGCQxalJ
         E5Ox3V0xDkmqmGCM4x2VWAdmIsHcFiLSZuW2vSq/eaE/XyD3vzaNs/8gGlx3K9Z5QJu/
         OejR+/lBPSAOqDxtHMGm1q2tNqx8n8xn4Q3rq/ynBaoyjnjlpkHZgPFnKNCOeVjB22nM
         qjNg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x19sor26858748qkf.195.2019.07.24.12.31.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 12:31:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqx97nMdzW1EyclSEUzycK5uM7O9QoX/1frKAt0SC9iUExEORIMrePlvDOE1VhOIUnMcQHlxBA==
X-Received: by 2002:a37:a358:: with SMTP id m85mr32733397qke.190.1563996671660;
        Wed, 24 Jul 2019 12:31:11 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id e8sm20345589qkn.95.2019.07.24.12.31.06
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 12:31:10 -0700 (PDT)
Date: Wed, 24 Jul 2019 15:31:03 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>, kvm@vger.kernel.org,
	dave.hansen@intel.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, akpm@linux-foundation.org,
	yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
	konrad.wilk@oracle.com, lcapitulino@redhat.com,
	wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
	dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Subject: Re: [PATCH v2 0/5] mm / virtio: Provide support for page hinting
Message-ID: <20190724153003-mutt-send-email-mst@kernel.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <0c520470-4654-cdf2-cf4d-d7c351d25e8b@redhat.com>
 <f7578309-dd36-bda0-6a30-34a6df21faca@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f7578309-dd36-bda0-6a30-34a6df21faca@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 08:41:33PM +0200, David Hildenbrand wrote:
> On 24.07.19 20:40, Nitesh Narayan Lal wrote:
> > 
> > On 7/24/19 12:54 PM, Alexander Duyck wrote:
> >> This series provides an asynchronous means of hinting to a hypervisor
> >> that a guest page is no longer in use and can have the data associated
> >> with it dropped. To do this I have implemented functionality that allows
> >> for what I am referring to as page hinting
> >>
> >> The functionality for this is fairly simple. When enabled it will allocate
> >> statistics to track the number of hinted pages in a given free area. When
> >> the number of free pages exceeds this value plus a high water value,
> >> currently 32,
> > Shouldn't we configure this to a lower number such as 16?
> >>  it will begin performing page hinting which consists of
> >> pulling pages off of free list and placing them into a scatter list. The
> >> scatterlist is then given to the page hinting device and it will perform
> >> the required action to make the pages "hinted", in the case of
> >> virtio-balloon this results in the pages being madvised as MADV_DONTNEED
> >> and as such they are forced out of the guest. After this they are placed
> >> back on the free list, and an additional bit is added if they are not
> >> merged indicating that they are a hinted buddy page instead of a standard
> >> buddy page. The cycle then repeats with additional non-hinted pages being
> >> pulled until the free areas all consist of hinted pages.
> >>
> >> I am leaving a number of things hard-coded such as limiting the lowest
> >> order processed to PAGEBLOCK_ORDER,
> > Have you considered making this option configurable at the compile time?
> >>  and have left it up to the guest to
> >> determine what the limit is on how many pages it wants to allocate to
> >> process the hints.
> > It might make sense to set the number of pages to be hinted at a time from the
> > hypervisor.
> >>
> >> My primary testing has just been to verify the memory is being freed after
> >> allocation by running memhog 79g on a 80g guest and watching the total
> >> free memory via /proc/meminfo on the host. With this I have verified most
> >> of the memory is freed after each iteration. As far as performance I have
> >> been mainly focusing on the will-it-scale/page_fault1 test running with
> >> 16 vcpus. With that I have seen at most a 2% difference between the base
> >> kernel without these patches and the patches with virtio-balloon disabled.
> >> With the patches and virtio-balloon enabled with hinting the results
> >> largely depend on the host kernel. On a 3.10 RHEL kernel I saw up to a 2%
> >> drop in performance as I approached 16 threads,
> > I think this is acceptable.
> >>  however on the the lastest
> >> linux-next kernel I saw roughly a 4% to 5% improvement in performance for
> >> all tests with 8 or more threads. 
> > Do you mean that with your patches the will-it-scale/page_fault1 numbers were
> > better by 4-5% over an unmodified kernel?
> >> I believe the difference seen is due to
> >> the overhead for faulting pages back into the guest and zeroing of memory.
> > It may also make sense to test these patches with netperf to observe how much
> > performance drop it is introducing.
> >> Patch 4 is a bit on the large side at about 600 lines of change, however
> >> I really didn't see a good way to break it up since each piece feeds into
> >> the next. So I couldn't add the statistics by themselves as it didn't
> >> really make sense to add them without something that will either read or
> >> increment/decrement them, or add the Hinted state without something that
> >> would set/unset it. As such I just ended up adding the entire thing as
> >> one patch. It makes it a bit bigger but avoids the issues in the previous
> >> set where I was referencing things before they had been added.
> >>
> >> Changes from the RFC:
> >> https://lore.kernel.org/lkml/20190530215223.13974.22445.stgit@localhost.localdomain/
> >> Moved aeration requested flag out of aerator and into zone->flags.
> >> Moved bounary out of free_area and into local variables for aeration.
> >> Moved aeration cycle out of interrupt and into workqueue.
> >> Left nr_free as total pages instead of splitting it between raw and aerated.
> >> Combined size and physical address values in virtio ring into one 64b value.
> >>
> >> Changes from v1:
> >> https://lore.kernel.org/lkml/20190619222922.1231.27432.stgit@localhost.localdomain/
> >> Dropped "waste page treatment" in favor of "page hinting"
> > We may still have to try and find a better name for virtio-balloon side changes.
> > As "FREE_PAGE_HINT" and "PAGE_HINTING" are still confusing.
> 
> We should have named that free page reporting, but that train already
> has left.

I think VIRTIO_BALLOON_F_FREE_PAGE_HINT is different and arguably
actually does provide hints.

> -- 
> 
> Thanks,
> 
> David / dhildenb

