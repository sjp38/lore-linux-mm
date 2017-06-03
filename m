Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1109F6B0292
	for <linux-mm@kvack.org>; Sat,  3 Jun 2017 05:18:50 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g53so29306442qta.3
        for <linux-mm@kvack.org>; Sat, 03 Jun 2017 02:18:50 -0700 (PDT)
Received: from mail-qk0-x22c.google.com (mail-qk0-x22c.google.com. [2607:f8b0:400d:c09::22c])
        by mx.google.com with ESMTPS id 16si25705393qtv.302.2017.06.03.02.18.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Jun 2017 02:18:49 -0700 (PDT)
Received: by mail-qk0-x22c.google.com with SMTP id p66so58392700qkf.3
        for <linux-mm@kvack.org>; Sat, 03 Jun 2017 02:18:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170601223808.GC2780@redhat.com>
References: <20170522165206.6284-1-jglisse@redhat.com> <CAKTCnzn2rTnqq62JY3GfAd7SCv1PChTrHSB6ikJzdjNzXC9cGA@mail.gmail.com>
 <20170524175349.GB24024@redhat.com> <CAKTCnznUJcHt9cd3ZOn-f2-HVHrCM_L+BPC5mgBVhsB7o0=JUw@mail.gmail.com>
 <20170601223808.GC2780@redhat.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Sat, 3 Jun 2017 19:18:48 +1000
Message-ID: <CAKTCnzntOCVh5kJ4VeGYHkwchhYGAP3Z9RqQqXCqZOssVNt6PQ@mail.gmail.com>
Subject: Re: [HMM 00/15] HMM (Heterogeneous Memory Management) v22
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>

On Fri, Jun 2, 2017 at 8:38 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> On Thu, Jun 01, 2017 at 12:04:02PM +1000, Balbir Singh wrote:
>> On Thu, May 25, 2017 at 3:53 AM, Jerome Glisse <jglisse@redhat.com> wrot=
e:
>> > On Wed, May 24, 2017 at 11:55:12AM +1000, Balbir Singh wrote:
>> >> On Tue, May 23, 2017 at 2:51 AM, J=C3=A9r=C3=B4me Glisse <jglisse@red=
hat.com> wrote:
>> >> > Patchset is on top of mmotm mmotm-2017-05-18, git branch:
>> >> >
>> >> > https://cgit.freedesktop.org/~glisse/linux/log/?h=3Dhmm-v22
>> >> >
>> >> > Change since v21 is adding back special refcounting in put_page() t=
o
>> >> > catch when a ZONE_DEVICE page is free (refcount going from 2 to 1
>> >> > unlike regular page where a refcount of 0 means the page is free).
>> >> > See patch 8 of this serie for this refcounting. I did not use stati=
c
>> >> > keys because it kind of scares me to do that for an inline function=
.
>> >> > If people strongly feel about this i can try to make static key wor=
ks
>> >> > here. Kirill will most likely want to review this.
>> >> >
>> >> >
>> >> > Everything else is the same. Below is the long description of what =
HMM
>> >> > is about and why. At the end of this email i describe briefly each =
patch
>> >> > and suggest reviewers for each of them.
>> >> >
>> >> >
>> >> > Heterogeneous Memory Management (HMM) (description and justificatio=
n)
>> >> >
>> >>
>> >> Thanks for the patches! These patches are very helpful. There are a
>> >> few additional things we would need on top of this (once HMM the base
>> >> is merged)
>> >>
>> >> 1. Support for other architectures, we'd like to make sure we can get
>> >> this working for powerpc for example. As a first step we have
>> >> ZONE_DEVICE enablement patches, but I think we need some additional
>> >> patches for iomem space searching and memory hotplug, IIRC
>> >> 2. HMM-CDM and physical address based migration bits. In a recent RFC
>> >> we decided to try and use the HMM CDM route as a route to implementin=
g
>> >> coherent device memory as a starting point. It would be nice to have
>> >> those patches on top of these once these make it to mm -
>> >> https://lwn.net/Articles/720380/
>> >>
>> >
>> > I intend to post the updated HMM CDM patchset early next week. I am
>> > tie in couple internal backport but i should be able to resume work
>> > on that this week.
>> >
>>
>> Thanks, I am looking at the HMM CDM branch and trying to forward port
>> and see what the results look like on top of HMM-v23. Do we have a timel=
ine
>> for the v23 merge?
>>
>
> So i am moving to new office and it has taken me more time than i thought
> to pack stuff. Attach is first step of CDM on top of lastest HMM. I hope
> to have more time tomorrow or next week to finish rebasing patches and to
> run some test with stolen ram as CDM memory.
>


No worries, thanks for the update. I forward ported some of the stuff from
HMM-CDM myself for testing on top of v23, with some assumptions and names
like MEMORY_PRIVATE_COHERENT (a new type) and arch_add_memory for
hotplug. I also modified Reza's driver (test) to see how far I can get
with HMM-CDM.

I look forward to the HMM-CDM patchset that you post.

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
