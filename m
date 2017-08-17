Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 717426B0387
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 18:06:09 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id y145so127096580ywa.9
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 15:06:09 -0700 (PDT)
Received: from mail-yw0-x22d.google.com (mail-yw0-x22d.google.com. [2607:f8b0:4002:c05::22d])
        by mx.google.com with ESMTPS id u3si1162970yba.179.2017.08.17.15.06.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 15:06:08 -0700 (PDT)
Received: by mail-yw0-x22d.google.com with SMTP id p68so49293210ywg.0
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 15:06:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170817220240.GE2872@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com> <20170817143916.63fca76e4c1fd841e0afd4cf@linux-foundation.org>
 <20170817215549.GD2872@redhat.com> <CAPcyv4j0_y9BrV-Bn57yScVJ8Nicfz2e0sSmRNG_hNPoE_LSKg@mail.gmail.com>
 <20170817220240.GE2872@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 17 Aug 2017 15:06:07 -0700
Message-ID: <CAPcyv4h6CEVe1xj6xAX6RaP__Z_YT4RMRwTJg3oaQgiDh1i0UA@mail.gmail.com>
Subject: Re: [HMM-v25 00/19] HMM (Heterogeneous Memory Management) v25
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>

On Thu, Aug 17, 2017 at 3:02 PM, Jerome Glisse <jglisse@redhat.com> wrote:
> On Thu, Aug 17, 2017 at 02:59:20PM -0700, Dan Williams wrote:
>> On Thu, Aug 17, 2017 at 2:55 PM, Jerome Glisse <jglisse@redhat.com> wrote:
>> > On Thu, Aug 17, 2017 at 02:39:16PM -0700, Andrew Morton wrote:
>> >> On Wed, 16 Aug 2017 20:05:29 -0400 J__r__me Glisse <jglisse@redhat.com> wrote:
>> >>
>> >> > Heterogeneous Memory Management (HMM) (description and justification)
>> >>
>> >> The patchset adds 55 kbytes to x86_64's mm/*.o and there doesn't appear
>> >> to be any way of avoiding this overhead, or of avoiding whatever
>> >> runtime overheads are added.
>> >
>> > HMM have already been integrated in couple of Red Hat kernel and AFAIK there
>> > is no runtime performance issue reported. Thought the RHEL version does not
>> > use static key as Dan asked.
>> >
>> >>
>> >> It also adds 18k to arm's mm/*.o and arm doesn't support HMM at all.
>> >>
>> >> So that's all quite a lot of bloat for systems which get no benefit from
>> >> the patchset.  What can we do to improve this situation (a lot)?
>> >
>> > I will look into why object file grow so much on arm. My guess is that the
>> > new migrate code is the bulk of that. I can hide the new page migration code
>> > behind a kernel configuration flag.
>>
>> Shouldn't we completely disable all of it unless there is a driver in
>> the kernel that selects it?
>
> At one point people asked to be able to use the new migrate helper without
> HMM and hence why it is not behind any HMM kconfig.
>
> IIRC even ARM folks were interested pretty much all SOC have several DMA
> engine that site idle and i think people where toying with the idea of using
> this new helper to make use of them. But i can add a different kconfig to
> hide this code and if people want to use it they will have to select it.

If they were interested then I would expect their use case would be
included in this patchset so the infrastructure and at least one
consumer can land together.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
