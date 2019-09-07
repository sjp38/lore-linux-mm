Return-Path: <SRS0=dqyo=XC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEB42C00307
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 03:15:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DABF21670
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 03:15:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KEmSCTrF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DABF21670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E49CF6B0005; Fri,  6 Sep 2019 23:15:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF90B6B0006; Fri,  6 Sep 2019 23:15:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE8E96B0007; Fri,  6 Sep 2019 23:15:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0172.hostedemail.com [216.40.44.172])
	by kanga.kvack.org (Postfix) with ESMTP id AC7726B0005
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 23:15:32 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 4D2C3180AD7C3
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 03:15:32 +0000 (UTC)
X-FDA: 75906659304.03.girls54_133450ed26e3e
X-HE-Tag: girls54_133450ed26e3e
X-Filterd-Recvd-Size: 5500
Received: from mail-io1-f65.google.com (mail-io1-f65.google.com [209.85.166.65])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 03:15:31 +0000 (UTC)
Received: by mail-io1-f65.google.com with SMTP id x4so17256654iog.13
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 20:15:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0SbxJSZH3xErImLG80umcUNoBk+9xCCDmjHpdYfWSdI=;
        b=KEmSCTrFRi5v4BfEGIMfu73TLPv6udM3bR6gfWTZy/5zzC65y2+/mWvG8YBtmoq2b2
         ERoPBzhsKJlm5uBrYKabXRRYM2dJNsBLY3jqJukp6HFhXq2qxCM+BwiwdrXidPTNUrTY
         BQ/M1eUI/QsJqAjkHiTdxL+62a1i4ha/Wq/gs6a2vwAiTiOJq7eec9Cv+ttD9ElMyy83
         bW19dkXFsucLiuSSZMmL8G5CF/8GHuDYD9RYM/WI+DU5hpMth22geGxtrMPbAmP/oa1t
         cO8vc0IR+L1V1dBgIAqvD2OMtmyjm8q8zNsy6ROkqQovCiIfc82c6P45TZp279DIIvvy
         PN4w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=0SbxJSZH3xErImLG80umcUNoBk+9xCCDmjHpdYfWSdI=;
        b=BUpHEM0EjJsvXgVd5ZtUQ1+PPpncZP0zgtsktfe3B7X7URFOwv4XZDQJz8AEDdEop9
         Yfsoidg06P8skQXYaAvLS6M5NzBCJalnbOgDhEI4ehlS8rcQmvGDgXyrB55suk/7pYmM
         8wJ54vQzqrhjb1Ho2Ynv+5e6upcUdDO6NwYzqRa01+56rGFwBR3snlJ4wa/YaV41NZR+
         27yOZpWdeYNpKg+5oHFSeDeKtivBVILr3pxnQ4vze2wsc/wfbBBg9pXtF8JOE30Uk0mE
         SFyIb50rG2UgHVr2FtkqUMp6SykEoVfujmsAUP20oTivd3iEvU9DFmLS7i5pzGcjLvx8
         FF4w==
X-Gm-Message-State: APjAAAXLFuCrQXO3/XqX5ezVhk0JEuixIsyNg9nutaPyYFOCSo0ncNyt
	InBiqIBqWhp34Iacw1yjhEEusLmZzU2LHGJRFo8=
X-Google-Smtp-Source: APXvYqzMKQWDegw54LhTAG2I7IbZAeamrmRENinp3sOSixubhuWe2/Lb4c7+X+JTMG4bueI+YTKM2zJypOUVeylKJ4Y=
X-Received: by 2002:a5d:91ce:: with SMTP id k14mr2399826ior.95.1567826131164;
 Fri, 06 Sep 2019 20:15:31 -0700 (PDT)
MIME-Version: 1.0
References: <20190906145213.32552.30160.stgit@localhost.localdomain> <20190906112155-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190906112155-mutt-send-email-mst@kernel.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 6 Sep 2019 20:15:20 -0700
Message-ID: <CAKgT0UcuZQPzcQ6cA5tKPG3+4yQP2jk+AHYcjoyrMXq0pBAiBw@mail.gmail.com>
Subject: Re: [PATCH v8 0/7] mm / virtio: Provide support for unused page reporting
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
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

On Fri, Sep 6, 2019 at 8:23 AM Michael S. Tsirkin <mst@redhat.com> wrote:
>
> On Fri, Sep 06, 2019 at 07:53:21AM -0700, Alexander Duyck wrote:
> > This series provides an asynchronous means of reporting to a hypervisor
> > that a guest page is no longer in use and can have the data associated
> > with it dropped. To do this I have implemented functionality that allows
> > for what I am referring to as unused page reporting
> >
> > The functionality for this is fairly simple. When enabled it will allocate
> > statistics to track the number of reported pages in a given free area.
> > When the number of free pages exceeds this value plus a high water value,
> > currently 32, it will begin performing page reporting which consists of
> > pulling pages off of free list and placing them into a scatter list. The
> > scatterlist is then given to the page reporting device and it will perform
> > the required action to make the pages "reported", in the case of
> > virtio-balloon this results in the pages being madvised as MADV_DONTNEED
> > and as such they are forced out of the guest. After this they are placed
> > back on the free list, and an additional bit is added if they are not
> > merged indicating that they are a reported buddy page instead of a
> > standard buddy page. The cycle then repeats with additional non-reported
> > pages being pulled until the free areas all consist of reported pages.
> >
> > I am leaving a number of things hard-coded such as limiting the lowest
> > order processed to PAGEBLOCK_ORDER, and have left it up to the guest to
> > determine what the limit is on how many pages it wants to allocate to
> > process the hints. The upper limit for this is based on the size of the
> > queue used to store the scattergather list.
>
> I queued this  so this gets tested on linux-next but the mm core changes
> need acks from appropriate people.

Looks like there was a couple issues on arm64 and ia64 architectures.
I believe I have those fixed up and will submit a v9 in the morning
after my test runs have completed.

Thanks.

- Alex

