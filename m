Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6BC6B025F
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 17:59:22 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id g75so128064919ywb.0
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 14:59:22 -0700 (PDT)
Received: from mail-yw0-x232.google.com (mail-yw0-x232.google.com. [2607:f8b0:4002:c05::232])
        by mx.google.com with ESMTPS id r143si855093ywg.348.2017.08.17.14.59.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 14:59:21 -0700 (PDT)
Received: by mail-yw0-x232.google.com with SMTP id u207so49194642ywc.3
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 14:59:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170817215549.GD2872@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com> <20170817143916.63fca76e4c1fd841e0afd4cf@linux-foundation.org>
 <20170817215549.GD2872@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 17 Aug 2017 14:59:20 -0700
Message-ID: <CAPcyv4j0_y9BrV-Bn57yScVJ8Nicfz2e0sSmRNG_hNPoE_LSKg@mail.gmail.com>
Subject: Re: [HMM-v25 00/19] HMM (Heterogeneous Memory Management) v25
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>

On Thu, Aug 17, 2017 at 2:55 PM, Jerome Glisse <jglisse@redhat.com> wrote:
> On Thu, Aug 17, 2017 at 02:39:16PM -0700, Andrew Morton wrote:
>> On Wed, 16 Aug 2017 20:05:29 -0400 J__r__me Glisse <jglisse@redhat.com> wrote:
>>
>> > Heterogeneous Memory Management (HMM) (description and justification)
>>
>> The patchset adds 55 kbytes to x86_64's mm/*.o and there doesn't appear
>> to be any way of avoiding this overhead, or of avoiding whatever
>> runtime overheads are added.
>
> HMM have already been integrated in couple of Red Hat kernel and AFAIK there
> is no runtime performance issue reported. Thought the RHEL version does not
> use static key as Dan asked.
>
>>
>> It also adds 18k to arm's mm/*.o and arm doesn't support HMM at all.
>>
>> So that's all quite a lot of bloat for systems which get no benefit from
>> the patchset.  What can we do to improve this situation (a lot)?
>
> I will look into why object file grow so much on arm. My guess is that the
> new migrate code is the bulk of that. I can hide the new page migration code
> behind a kernel configuration flag.

Shouldn't we completely disable all of it unless there is a driver in
the kernel that selects it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
