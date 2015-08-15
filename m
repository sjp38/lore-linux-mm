Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 43E636B0253
	for <linux-mm@kvack.org>; Sat, 15 Aug 2015 12:04:03 -0400 (EDT)
Received: by igfj19 with SMTP id j19so31205618igf.0
        for <linux-mm@kvack.org>; Sat, 15 Aug 2015 09:04:03 -0700 (PDT)
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com. [209.85.213.179])
        by mx.google.com with ESMTPS id b19si3851527igr.21.2015.08.15.09.04.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Aug 2015 09:04:02 -0700 (PDT)
Received: by igbjg10 with SMTP id jg10so30109126igb.0
        for <linux-mm@kvack.org>; Sat, 15 Aug 2015 09:04:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150815155846.GA26248@lst.de>
References: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com>
	<20150813035028.36913.25267.stgit@otcpl-skl-sds-2.jf.intel.com>
	<20150815090635.GF21033@lst.de>
	<CAPcyv4hMaRDOttcnvjq-aBXqgaPuB1d1XVi-dJFryC9pJ8PhMw@mail.gmail.com>
	<20150815155846.GA26248@lst.de>
Date: Sat, 15 Aug 2015 09:04:02 -0700
Message-ID: <CAPcyv4iN0BmipDfrsoCg2N2KnhX0+Hz2-ghr1i0H4US+bFe+Dw@mail.gmail.com>
Subject: Re: [RFC PATCH 5/7] libnvdimm, e820: make CONFIG_X86_PMEM_LEGACY a
 tristate option
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Boaz Harrosh <boaz@plexistor.com>, Rik van Riel <riel@redhat.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, david <david@fromorbit.com>, Ingo Molnar <mingo@kernel.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>

On Sat, Aug 15, 2015 at 8:58 AM, Christoph Hellwig <hch@lst.de> wrote:
> On Sat, Aug 15, 2015 at 08:28:35AM -0700, Dan Williams wrote:
>> I'm not grokking the argument against allowing this functionality to
>> be modular.
>
> You're adding a another layer of platform_devices just to make a tivially
> small piece of code modular so that you can hook into it.  I don't think
> that's a good reason, and neither is the after thought of preventing
> potentially future buggy firmware.

What other layer? /sys/devices/platform/e820_pmem is that exact same
device we had before this patch.  We just have a proper driver for it
now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
