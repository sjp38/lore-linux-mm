Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 329E86B0038
	for <linux-mm@kvack.org>; Fri, 14 Aug 2015 18:33:45 -0400 (EDT)
Received: by iodt126 with SMTP id t126so99748822iod.2
        for <linux-mm@kvack.org>; Fri, 14 Aug 2015 15:33:44 -0700 (PDT)
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com. [209.85.213.179])
        by mx.google.com with ESMTPS id o6si1194160ige.92.2015.08.14.15.33.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Aug 2015 15:33:44 -0700 (PDT)
Received: by igfj19 with SMTP id j19so21608661igf.1
        for <linux-mm@kvack.org>; Fri, 14 Aug 2015 15:33:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150814220605.GB3265@gmail.com>
References: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com>
	<20150813035005.36913.77364.stgit@otcpl-skl-sds-2.jf.intel.com>
	<20150814213714.GA3265@gmail.com>
	<CAPcyv4ib244VMSdhHDWHRnmCvYdteUEzT+ehTzitSY42m2Tt=w@mail.gmail.com>
	<20150814220605.GB3265@gmail.com>
Date: Fri, 14 Aug 2015 15:33:13 -0700
Message-ID: <CAPcyv4gEPum_qq7PH0oNx3ntiWTP_1fp4EU+CAj8tm1Oeg-E9w@mail.gmail.com>
Subject: Re: [RFC PATCH 1/7] x86, mm: ZONE_DEVICE for "device memory"
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Boaz Harrosh <boaz@plexistor.com>, Rik van Riel <riel@redhat.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Hansen <dave.hansen@linux.intel.com>, david <david@fromorbit.com>, Ingo Molnar <mingo@kernel.org>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On Fri, Aug 14, 2015 at 3:06 PM, Jerome Glisse <j.glisse@gmail.com> wrote:
> On Fri, Aug 14, 2015 at 02:52:15PM -0700, Dan Williams wrote:
>> On Fri, Aug 14, 2015 at 2:37 PM, Jerome Glisse <j.glisse@gmail.com> wrote:
>> > On Wed, Aug 12, 2015 at 11:50:05PM -0400, Dan Williams wrote:
[..]
>> > What is the rational for not updating max_pfn, max_low_pfn, ... ?
>> >
>>
>> The idea is that this memory is not meant to be available to the page
>> allocator and should not count as new memory capacity.  We're only
>> hotplugging it to get struct page coverage.
>
> But this sounds bogus to me to rely on max_pfn to stay smaller than
> first_dev_pfn.  For instance you might plug a device that register
> dev memory and then some regular memory might be hotplug, effectively
> updating max_pfn to a value bigger than first_dev_pfn.
>

True.

> Also i do not think that the buddy allocator use max_pfn or max_low_pfn
> to consider page/zone for allocation or not.

Yes, I took it out with no effects.  I'll investigate further whether
we should be touching those variables or not for this new usage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
