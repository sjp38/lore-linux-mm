Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A451DC49ED7
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 16:05:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 566BF206A1
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 16:05:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Fo10nVgC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 566BF206A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8F886B0006; Tue, 10 Sep 2019 12:05:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D408D6B0010; Tue, 10 Sep 2019 12:05:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7E186B0266; Tue, 10 Sep 2019 12:05:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0211.hostedemail.com [216.40.44.211])
	by kanga.kvack.org (Postfix) with ESMTP id A6E1D6B0006
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 12:05:56 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 5ACE6180AD815
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 16:05:56 +0000 (UTC)
X-FDA: 75919487112.12.tooth71_50e1bfd810343
X-HE-Tag: tooth71_50e1bfd810343
X-Filterd-Recvd-Size: 7370
Received: from mail-io1-f66.google.com (mail-io1-f66.google.com [209.85.166.66])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 16:05:55 +0000 (UTC)
Received: by mail-io1-f66.google.com with SMTP id n197so38747315iod.9
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:05:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=VOHRoq+5f0zDDmoxjc5LrcCUbX6pSA5aom1GvfEBdqM=;
        b=Fo10nVgCGjb967s2Gvy7rNbxLGvFQyPQai3LMMHk9zZedD+veZSBvOOmwQSJubz6ZP
         tuAujd3bbR/kbJcDxXxLq07MStOXSHX/1qIcFO49nAb5M62AjF0b3yFVjA+XNCCqoEEB
         WliSdoQPWIq+66wv7Qo/0/p4xMBLyrD1BdExRd2/35+zdhIjOeD0flz03I1Oe76aoV9A
         h+0xDFdQGW2HNoXAad189kM9G4aREr7hFK4BN7X8BoO7QW2AnAzdEzWlRlvTAn+IAgFx
         h/DxKukXVR4eBj0Ryq0xnwI+x6E+5VbdcoJjA04pKpMjf4S2U4shxqFiG3xCBT0kEmIU
         vdQg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=VOHRoq+5f0zDDmoxjc5LrcCUbX6pSA5aom1GvfEBdqM=;
        b=WuvydxDuKco++GZY+/Pr+DaWCT1UszQEIpcxv64GRbWV9nsmQGFkoH+lTgu9BhJFcl
         vSFAZu1gmNy178Vn84yziVr/tsgeOTzbVFJT8sk4HypFAYdyCcXLMq6Y72vOdLDZ0F4r
         VxeNoWTkpBRjZzuk/Q6dn1Qf1UwCjhPr3WIR7IpiG7TzufofcC/2XnC/tGk8wGy52MMl
         DLvqorlMNzfgepCG0kdD/0dYoblZ34z9avIcOh1phgSUEfeyG2MiOzFf4F3s9Cd8eHRT
         7s5FmihEcdQL6rRToOxJ+By6aUky1www5MDOxJ/UjJYKUb+rGRbYAn8KWYt/YbbyNrAZ
         jlSA==
X-Gm-Message-State: APjAAAVI3HZkBLR4TEtdB7u0++VzGF1U+f6cUNqqqKSkF+BNuwuSHmqT
	gtQIcYHD0bIyC1H1t7c4p//89+KweYOF8Gzw7fM=
X-Google-Smtp-Source: APXvYqwuv/pHVCWexKpkprqv1+Ti4casdnv0H37FsG/aFQFyd9UW76zxHfgdVDSoAnHjOav423k8D+xgBCR6S09zUQ4=
X-Received: by 2002:a6b:ac85:: with SMTP id v127mr4562969ioe.97.1568131554878;
 Tue, 10 Sep 2019 09:05:54 -0700 (PDT)
MIME-Version: 1.0
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
 <20190910124209.GY2063@dhcp22.suse.cz> <CAKgT0Udr6nYQFTRzxLbXk41SiJ-pcT_bmN1j1YR4deCwdTOaUQ@mail.gmail.com>
 <20190910144713.GF2063@dhcp22.suse.cz>
In-Reply-To: <20190910144713.GF2063@dhcp22.suse.cz>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 10 Sep 2019 09:05:43 -0700
Message-ID: <CAKgT0UdB4qp3vFGrYEs=FwSXKpBEQ7zo7DV55nJRO2C-KCEOrw@mail.gmail.com>
Subject: Re: [PATCH v9 0/8] stg mail -e --version=v9 \
To: Michal Hocko <mhocko@kernel.org>
Cc: virtio-dev@lists.oasis-open.org, kvm list <kvm@vger.kernel.org>, 
	"Michael S. Tsirkin" <mst@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, 
	linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, will@kernel.org, 
	linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>, 
	Yang Zhang <yang.zhang.wz@gmail.com>, Pankaj Gupta <pagupta@redhat.com>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitesh Narayan Lal <nitesh@redhat.com>, 
	Rik van Riel <riel@surriel.com>, lcapitulino@redhat.com, 
	"Wang, Wei W" <wei.w.wang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, 
	Paolo Bonzini <pbonzini@redhat.com>, Dan Williams <dan.j.williams@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 10, 2019 at 7:47 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 10-09-19 07:42:43, Alexander Duyck wrote:
> > On Tue, Sep 10, 2019 at 5:42 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > I wanted to review "mm: Introduce Reported pages" just realize that I
> > > have no clue on what is going on so returned to the cover and it didn't
> > > really help much. I am completely unfamiliar with virtio so please bear
> > > with me.
> > >
> > > On Sat 07-09-19 10:25:03, Alexander Duyck wrote:
> > > [...]
> > > > This series provides an asynchronous means of reporting to a hypervisor
> > > > that a guest page is no longer in use and can have the data associated
> > > > with it dropped. To do this I have implemented functionality that allows
> > > > for what I am referring to as unused page reporting
> > > >
> > > > The functionality for this is fairly simple. When enabled it will allocate
> > > > statistics to track the number of reported pages in a given free area.
> > > > When the number of free pages exceeds this value plus a high water value,
> > > > currently 32, it will begin performing page reporting which consists of
> > > > pulling pages off of free list and placing them into a scatter list. The
> > > > scatterlist is then given to the page reporting device and it will perform
> > > > the required action to make the pages "reported", in the case of
> > > > virtio-balloon this results in the pages being madvised as MADV_DONTNEED
> > > > and as such they are forced out of the guest. After this they are placed
> > > > back on the free list,
> > >
> > > And here I am reallly lost because "forced out of the guest" makes me
> > > feel that those pages are no longer usable by the guest. So how come you
> > > can add them back to the free list. I suspect understanding this part
> > > will allow me to understand why we have to mark those pages and prevent
> > > merging.
> >
> > Basically as the paragraph above mentions "forced out of the guest"
> > really is just the hypervisor calling MADV_DONTNEED on the page in
> > question. So the behavior is the same as any userspace application
> > that calls MADV_DONTNEED where the contents are no longer accessible
> > from userspace and attempting to access them will result in a fault
> > and the page being populated with a zero fill on-demand page, or a
> > copy of the file contents if the memory is file backed.
>
> As I've said I have no idea about virt so this doesn't really tell me
> much. Does that mean that if somebody allocates such a page and tries to
> access it then virt will handle a fault and bring it back?

Actually I am probably describing too much as the MADV_DONTNEED is the
hypervisor behavior in response to the virtio-balloon notification. A
more thorough explanation of it can be found by just running "man
madvise", probably best just to leave it at that since I am probably
confusing things by describing hypervisor behavior in a kernel patch
set.

For the most part all the page reporting really does is provide a way
to incrementally identify unused regions of memory in the buddy
allocator. That in turn is used by virtio-balloon in a polling thread
to report to the hypervisor what pages are not in use so that it can
make a decision on what to do with the pages now that it knows they
are unused.

All this is providing is just a report and it is optional if the
hypervisor will act on it or not. If the hypervisor takes some sort of
action on the page, then the expectation is that the hypervisor will
use some sort of mechanism such as a page fault to discover when the
page is used again.

