Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0F2F76B0315
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 18:38:13 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id l4so21049237qkh.3
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 15:38:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e125si20767422qkc.177.2017.06.01.15.38.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 15:38:12 -0700 (PDT)
Date: Thu, 1 Jun 2017 18:38:08 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 00/15] HMM (Heterogeneous Memory Management) v22
Message-ID: <20170601223808.GC2780@redhat.com>
References: <20170522165206.6284-1-jglisse@redhat.com>
 <CAKTCnzn2rTnqq62JY3GfAd7SCv1PChTrHSB6ikJzdjNzXC9cGA@mail.gmail.com>
 <20170524175349.GB24024@redhat.com>
 <CAKTCnznUJcHt9cd3ZOn-f2-HVHrCM_L+BPC5mgBVhsB7o0=JUw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="EVF5PPMfhYS0aIcm"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAKTCnznUJcHt9cd3ZOn-f2-HVHrCM_L+BPC5mgBVhsB7o0=JUw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>


--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Thu, Jun 01, 2017 at 12:04:02PM +1000, Balbir Singh wrote:
> On Thu, May 25, 2017 at 3:53 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> > On Wed, May 24, 2017 at 11:55:12AM +1000, Balbir Singh wrote:
> >> On Tue, May 23, 2017 at 2:51 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> >> > Patchset is on top of mmotm mmotm-2017-05-18, git branch:
> >> >
> >> > https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-v22
> >> >
> >> > Change since v21 is adding back special refcounting in put_page() to
> >> > catch when a ZONE_DEVICE page is free (refcount going from 2 to 1
> >> > unlike regular page where a refcount of 0 means the page is free).
> >> > See patch 8 of this serie for this refcounting. I did not use static
> >> > keys because it kind of scares me to do that for an inline function.
> >> > If people strongly feel about this i can try to make static key works
> >> > here. Kirill will most likely want to review this.
> >> >
> >> >
> >> > Everything else is the same. Below is the long description of what HMM
> >> > is about and why. At the end of this email i describe briefly each patch
> >> > and suggest reviewers for each of them.
> >> >
> >> >
> >> > Heterogeneous Memory Management (HMM) (description and justification)
> >> >
> >>
> >> Thanks for the patches! These patches are very helpful. There are a
> >> few additional things we would need on top of this (once HMM the base
> >> is merged)
> >>
> >> 1. Support for other architectures, we'd like to make sure we can get
> >> this working for powerpc for example. As a first step we have
> >> ZONE_DEVICE enablement patches, but I think we need some additional
> >> patches for iomem space searching and memory hotplug, IIRC
> >> 2. HMM-CDM and physical address based migration bits. In a recent RFC
> >> we decided to try and use the HMM CDM route as a route to implementing
> >> coherent device memory as a starting point. It would be nice to have
> >> those patches on top of these once these make it to mm -
> >> https://lwn.net/Articles/720380/
> >>
> >
> > I intend to post the updated HMM CDM patchset early next week. I am
> > tie in couple internal backport but i should be able to resume work
> > on that this week.
> >
> 
> Thanks, I am looking at the HMM CDM branch and trying to forward port
> and see what the results look like on top of HMM-v23. Do we have a timeline
> for the v23 merge?
> 

So i am moving to new office and it has taken me more time than i thought
to pack stuff. Attach is first step of CDM on top of lastest HMM. I hope
to have more time tomorrow or next week to finish rebasing patches and to
run some test with stolen ram as CDM memory.

Jerome

--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="0001-mm-device-public-memory-device-memory-cache-coherent.patch"
Content-Transfer-Encoding: 8bit


--EVF5PPMfhYS0aIcm--
