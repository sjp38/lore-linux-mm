Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f44.google.com (mail-vk0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id 69AA86B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 20:49:56 -0400 (EDT)
Received: by vkif69 with SMTP id f69so3817973vki.3
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 17:49:56 -0700 (PDT)
Received: from mail-vk0-f41.google.com (mail-vk0-f41.google.com. [209.85.213.41])
        by mx.google.com with ESMTPS id ba10si4006381vdd.18.2015.08.19.17.49.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Aug 2015 17:49:55 -0700 (PDT)
Received: by vkd66 with SMTP id 66so10272506vkd.0
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 17:49:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150818190634.GB7424@gmail.com>
References: <20150813035005.36913.77364.stgit@otcpl-skl-sds-2.jf.intel.com>
	<20150814213714.GA3265@gmail.com>
	<CAPcyv4ib244VMSdhHDWHRnmCvYdteUEzT+ehTzitSY42m2Tt=w@mail.gmail.com>
	<20150814220605.GB3265@gmail.com>
	<CAPcyv4gEPum_qq7PH0oNx3ntiWTP_1fp4EU+CAj8tm1Oeg-E9w@mail.gmail.com>
	<CAPcyv4i-5RWTLK8FQFCBuFKwY0_HShbW7PVTHudSk4sF35xosA@mail.gmail.com>
	<20150817214554.GA5976@gmail.com>
	<CAPcyv4jPezPAy9gMMtenBH1U526N3cwQY02823jfqWPyuRMouw@mail.gmail.com>
	<20150818165532.GA7424@gmail.com>
	<CAPcyv4hpKHH924B-Udvii5L8xFr04snEA+CLwSMk8mpzsPihkw@mail.gmail.com>
	<20150818190634.GB7424@gmail.com>
Date: Wed, 19 Aug 2015 17:49:54 -0700
Message-ID: <CAPcyv4gLVLWcyS5FWHgm37d7PDwzA03VStomgt37cevfDv7ojQ@mail.gmail.com>
Subject: Re: [RFC PATCH 1/7] x86, mm: ZONE_DEVICE for "device memory"
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Boaz Harrosh <boaz@plexistor.com>, Rik van Riel <riel@redhat.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Hansen <dave.hansen@linux.intel.com>, david <david@fromorbit.com>, Ingo Molnar <mingo@kernel.org>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On Tue, Aug 18, 2015 at 12:06 PM, Jerome Glisse <j.glisse@gmail.com> wrote:
> On Tue, Aug 18, 2015 at 10:23:38AM -0700, Dan Williams wrote:
> Thought maybe you don't need a new ZONE_DEV and all you need is valid
> struct page for this device memory, and you don't want this page to be
> useable by the general memory allocator. There is surely other ways to
> achieve that like marking all as reserved when you hotplug them.
>

Yes, there are other ways that can achieve the same thing, but I do
like the ability to do reverse page to zone lookups for debug if
anything.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
