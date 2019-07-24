Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6E68C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 21:32:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 979392147A
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 21:32:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 979392147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 267B38E000C; Wed, 24 Jul 2019 17:32:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F0548E0002; Wed, 24 Jul 2019 17:32:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E0A98E000C; Wed, 24 Jul 2019 17:32:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id DBFB48E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 17:32:17 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id c207so40463769qkb.11
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 14:32:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=ai5coBa0SEbsnkfCobaB/l8UgFxaRhE6zMbrvqUmDKQ=;
        b=U5TvrfiNnYT1utTBfodsN4MiLsYp9NlT3RafQIpbbIIaa2b3XyBZI0/d3aZC8VZob5
         UDJRXX/bE8Et9q5jfaupwZM5XaaWkHBwn3f+puKWou1mVAXidAqCw9v8wUpbJ1rv+c3D
         aob7e22AR+Z0Po23ObkMdoXQlYJyZp3Asw6RIxre3iosuUdDzfikM3MdV33qLLhIqZFT
         Ij48cAlo9l+vEpIHra2OMEhaCFzeAVroOu82o2larq1iRrcg/+k3vnmnL5PHNd/NZsXT
         V7HHQ2QQ1DUDxcA7m52SPNyXnxCdSEz4tpHBjlnu/9JBRuXpFgpqvyZMXFoO+nEEclMw
         trug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWG3rmrDnTPN3vBOH0c1BzFyb9popyVHCdVQ9/qtv3nh9HBcxnR
	Jbhpc200iRZ/G9vcQGHfJ4+oc+omSXIdFD5bljeT0tllPPjtXzAe052ol/dn1CxMuRQKNz9E/dv
	VGxuVSSpmMRf6fNErHbbXP3HApvRxiMzkkexZI8288R58tfJaNuX+QYsAqWbdvqt6+g==
X-Received: by 2002:ac8:7cd:: with SMTP id m13mr59021718qth.341.1564003937611;
        Wed, 24 Jul 2019 14:32:17 -0700 (PDT)
X-Received: by 2002:ac8:7cd:: with SMTP id m13mr59021682qth.341.1564003936854;
        Wed, 24 Jul 2019 14:32:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564003936; cv=none;
        d=google.com; s=arc-20160816;
        b=hE74pB5tamx7w4KXkqaTpsAr7i4PAQl20ttjxOCL+jLMW6JDrKBKJSG3dlxuvIAdok
         yzE2QSv95YsyAssYTzj/v3Q7/Nn4ktDVqim0JcGtVWSQhQWoW3v1P994r3/lBKYc2hjm
         caefezRmZbl9cUUX7y16zvshWDzeZheL0hSuTt6oQkcQZn+J7SOLLGeE3Aukd4FTqnNj
         45JVa7w7hcjxGO6Dn5KA1GlYzMgm545ePNtRfYXkpE5C1mBQzeyw7TMbeAIHTIpqqvqr
         ZPjxpwQDRJeLJffJzEXXvn8YDHWbuXn4FABMPc51S1YvC8kmitbxDT05kTzkpKhAcINz
         rG8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=ai5coBa0SEbsnkfCobaB/l8UgFxaRhE6zMbrvqUmDKQ=;
        b=gNg1eJO0M/6018lLFvKbLwlY8PYKZjEcuXdykVMr1xOvFUhtiGsBYOXHsgCe0AuDar
         7aYpVaH5SJcFD3Sqzp3T3bBPniaaoIyM8HVVTcm3jNXZzob79sT0EQfK6yU5ZWNnpvau
         yhpmKfihgn1MrkNyB7ITUHk+3flLnoQ4d4W8CY8gOhbYb4jw3a0ee1RIyEUVoNbVebT3
         VgYACtayF6i9wqvFNlpFkJja6/w1JocWi0JLSIXo65/+qrvLMrB0ukPPkjzW5LCwWbwa
         nlLwppwa63H6Qt7AtmgUmbEWS58Xia55XZRvZoIUyxuua2uyuomf1YbqGecGJv00zhET
         +ARw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q52sor63119810qte.3.2019.07.24.14.32.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 14:32:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyH0YRHgL6uAQpFcl1HZau/89CK88ahnBR6ktX2vEame2RO+xp6GtK5MlfC7dIethbqH316WQ==
X-Received: by 2002:ac8:2aaa:: with SMTP id b39mr60096621qta.24.1564003936443;
        Wed, 24 Jul 2019 14:32:16 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id b13sm29314624qtk.55.2019.07.24.14.32.10
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 14:32:15 -0700 (PDT)
Date: Wed, 24 Jul 2019 17:32:07 -0400
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
Message-ID: <20190724154840-mutt-send-email-mst@kernel.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <0c520470-4654-cdf2-cf4d-d7c351d25e8b@redhat.com>
 <f7578309-dd36-bda0-6a30-34a6df21faca@redhat.com>
 <20190724153003-mutt-send-email-mst@kernel.org>
 <b3279b70-7a64-a456-cbfa-2a5ec3e9468e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b3279b70-7a64-a456-cbfa-2a5ec3e9468e@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 09:47:24PM +0200, David Hildenbrand wrote:
> On 24.07.19 21:31, Michael S. Tsirkin wrote:
> > On Wed, Jul 24, 2019 at 08:41:33PM +0200, David Hildenbrand wrote:
> >> On 24.07.19 20:40, Nitesh Narayan Lal wrote:
> >>>
> >>> On 7/24/19 12:54 PM, Alexander Duyck wrote:
> >>>> This series provides an asynchronous means of hinting to a hypervisor
> >>>> that a guest page is no longer in use and can have the data associated
> >>>> with it dropped. To do this I have implemented functionality that allows
> >>>> for what I am referring to as page hinting
> >>>>
> >>>> The functionality for this is fairly simple. When enabled it will allocate
> >>>> statistics to track the number of hinted pages in a given free area. When
> >>>> the number of free pages exceeds this value plus a high water value,
> >>>> currently 32,
> >>> Shouldn't we configure this to a lower number such as 16?
> >>>>  it will begin performing page hinting which consists of
> >>>> pulling pages off of free list and placing them into a scatter list. The
> >>>> scatterlist is then given to the page hinting device and it will perform
> >>>> the required action to make the pages "hinted", in the case of
> >>>> virtio-balloon this results in the pages being madvised as MADV_DONTNEED
> >>>> and as such they are forced out of the guest. After this they are placed
> >>>> back on the free list, and an additional bit is added if they are not
> >>>> merged indicating that they are a hinted buddy page instead of a standard
> >>>> buddy page. The cycle then repeats with additional non-hinted pages being
> >>>> pulled until the free areas all consist of hinted pages.
> >>>>
> >>>> I am leaving a number of things hard-coded such as limiting the lowest
> >>>> order processed to PAGEBLOCK_ORDER,
> >>> Have you considered making this option configurable at the compile time?
> >>>>  and have left it up to the guest to
> >>>> determine what the limit is on how many pages it wants to allocate to
> >>>> process the hints.
> >>> It might make sense to set the number of pages to be hinted at a time from the
> >>> hypervisor.
> >>>>
> >>>> My primary testing has just been to verify the memory is being freed after
> >>>> allocation by running memhog 79g on a 80g guest and watching the total
> >>>> free memory via /proc/meminfo on the host. With this I have verified most
> >>>> of the memory is freed after each iteration. As far as performance I have
> >>>> been mainly focusing on the will-it-scale/page_fault1 test running with
> >>>> 16 vcpus. With that I have seen at most a 2% difference between the base
> >>>> kernel without these patches and the patches with virtio-balloon disabled.
> >>>> With the patches and virtio-balloon enabled with hinting the results
> >>>> largely depend on the host kernel. On a 3.10 RHEL kernel I saw up to a 2%
> >>>> drop in performance as I approached 16 threads,
> >>> I think this is acceptable.
> >>>>  however on the the lastest
> >>>> linux-next kernel I saw roughly a 4% to 5% improvement in performance for
> >>>> all tests with 8 or more threads. 
> >>> Do you mean that with your patches the will-it-scale/page_fault1 numbers were
> >>> better by 4-5% over an unmodified kernel?
> >>>> I believe the difference seen is due to
> >>>> the overhead for faulting pages back into the guest and zeroing of memory.
> >>> It may also make sense to test these patches with netperf to observe how much
> >>> performance drop it is introducing.
> >>>> Patch 4 is a bit on the large side at about 600 lines of change, however
> >>>> I really didn't see a good way to break it up since each piece feeds into
> >>>> the next. So I couldn't add the statistics by themselves as it didn't
> >>>> really make sense to add them without something that will either read or
> >>>> increment/decrement them, or add the Hinted state without something that
> >>>> would set/unset it. As such I just ended up adding the entire thing as
> >>>> one patch. It makes it a bit bigger but avoids the issues in the previous
> >>>> set where I was referencing things before they had been added.
> >>>>
> >>>> Changes from the RFC:
> >>>> https://lore.kernel.org/lkml/20190530215223.13974.22445.stgit@localhost.localdomain/
> >>>> Moved aeration requested flag out of aerator and into zone->flags.
> >>>> Moved bounary out of free_area and into local variables for aeration.
> >>>> Moved aeration cycle out of interrupt and into workqueue.
> >>>> Left nr_free as total pages instead of splitting it between raw and aerated.
> >>>> Combined size and physical address values in virtio ring into one 64b value.
> >>>>
> >>>> Changes from v1:
> >>>> https://lore.kernel.org/lkml/20190619222922.1231.27432.stgit@localhost.localdomain/
> >>>> Dropped "waste page treatment" in favor of "page hinting"
> >>> We may still have to try and find a better name for virtio-balloon side changes.
> >>> As "FREE_PAGE_HINT" and "PAGE_HINTING" are still confusing.
> >>
> >> We should have named that free page reporting, but that train already
> >> has left.
> > 
> > I think VIRTIO_BALLOON_F_FREE_PAGE_HINT is different and arguably
> > actually does provide hints.
> 
> I guess it depends on the point of view (e.g., getting all free pages
> feels more like a report). But I could also live with using the term
> reporting in this context.
> 
> We could go ahead and name it all "page reporting", would also work for me.

So there are actually three differences between the machanisms:
1. VIRTIO_BALLOON_F_FREE_PAGE_HINT sometimes reports pages which might no
   longer be on the free list (with subtle limitations which sometimes
   still allow hypervisor to discard the pages)
2. VIRTIO_BALLOON_F_FREE_PAGE_HINT starts reporting when requested by
   host
3. VIRTIO_BALLOON_F_FREE_PAGE_HINT is not incremental: each request
   by host reports all free memory

By comparison, the proposed patches:
- always report only actually free pages
- report at a random time
- report incrementally


> -- 
> 
> Thanks,
> 
> David / dhildenb

