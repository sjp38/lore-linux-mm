Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3053E6B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 22:04:05 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id i6so12363371qti.5
        for <linux-mm@kvack.org>; Wed, 31 May 2017 19:04:05 -0700 (PDT)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id o184si17632249qkb.178.2017.05.31.19.04.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 19:04:04 -0700 (PDT)
Received: by mail-qt0-x244.google.com with SMTP id r58so4144024qtb.2
        for <linux-mm@kvack.org>; Wed, 31 May 2017 19:04:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170524175349.GB24024@redhat.com>
References: <20170522165206.6284-1-jglisse@redhat.com> <CAKTCnzn2rTnqq62JY3GfAd7SCv1PChTrHSB6ikJzdjNzXC9cGA@mail.gmail.com>
 <20170524175349.GB24024@redhat.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Thu, 1 Jun 2017 12:04:02 +1000
Message-ID: <CAKTCnznUJcHt9cd3ZOn-f2-HVHrCM_L+BPC5mgBVhsB7o0=JUw@mail.gmail.com>
Subject: Re: [HMM 00/15] HMM (Heterogeneous Memory Management) v22
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>

On Thu, May 25, 2017 at 3:53 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> On Wed, May 24, 2017 at 11:55:12AM +1000, Balbir Singh wrote:
>> On Tue, May 23, 2017 at 2:51 AM, J=C3=A9r=C3=B4me Glisse <jglisse@redhat=
.com> wrote:
>> > Patchset is on top of mmotm mmotm-2017-05-18, git branch:
>> >
>> > https://cgit.freedesktop.org/~glisse/linux/log/?h=3Dhmm-v22
>> >
>> > Change since v21 is adding back special refcounting in put_page() to
>> > catch when a ZONE_DEVICE page is free (refcount going from 2 to 1
>> > unlike regular page where a refcount of 0 means the page is free).
>> > See patch 8 of this serie for this refcounting. I did not use static
>> > keys because it kind of scares me to do that for an inline function.
>> > If people strongly feel about this i can try to make static key works
>> > here. Kirill will most likely want to review this.
>> >
>> >
>> > Everything else is the same. Below is the long description of what HMM
>> > is about and why. At the end of this email i describe briefly each pat=
ch
>> > and suggest reviewers for each of them.
>> >
>> >
>> > Heterogeneous Memory Management (HMM) (description and justification)
>> >
>>
>> Thanks for the patches! These patches are very helpful. There are a
>> few additional things we would need on top of this (once HMM the base
>> is merged)
>>
>> 1. Support for other architectures, we'd like to make sure we can get
>> this working for powerpc for example. As a first step we have
>> ZONE_DEVICE enablement patches, but I think we need some additional
>> patches for iomem space searching and memory hotplug, IIRC
>> 2. HMM-CDM and physical address based migration bits. In a recent RFC
>> we decided to try and use the HMM CDM route as a route to implementing
>> coherent device memory as a starting point. It would be nice to have
>> those patches on top of these once these make it to mm -
>> https://lwn.net/Articles/720380/
>>
>
> I intend to post the updated HMM CDM patchset early next week. I am
> tie in couple internal backport but i should be able to resume work
> on that this week.
>

Thanks, I am looking at the HMM CDM branch and trying to forward port
and see what the results look like on top of HMM-v23. Do we have a timeline
for the v23 merge?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
