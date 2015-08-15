Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 504206B0253
	for <linux-mm@kvack.org>; Sat, 15 Aug 2015 11:28:36 -0400 (EDT)
Received: by igui7 with SMTP id i7so29654088igu.0
        for <linux-mm@kvack.org>; Sat, 15 Aug 2015 08:28:36 -0700 (PDT)
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com. [209.85.213.176])
        by mx.google.com with ESMTPS id q143si6225234ioe.201.2015.08.15.08.28.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Aug 2015 08:28:35 -0700 (PDT)
Received: by igui7 with SMTP id i7so29653975igu.0
        for <linux-mm@kvack.org>; Sat, 15 Aug 2015 08:28:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150815090635.GF21033@lst.de>
References: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com>
	<20150813035028.36913.25267.stgit@otcpl-skl-sds-2.jf.intel.com>
	<20150815090635.GF21033@lst.de>
Date: Sat, 15 Aug 2015 08:28:35 -0700
Message-ID: <CAPcyv4hMaRDOttcnvjq-aBXqgaPuB1d1XVi-dJFryC9pJ8PhMw@mail.gmail.com>
Subject: Re: [RFC PATCH 5/7] libnvdimm, e820: make CONFIG_X86_PMEM_LEGACY a
 tristate option
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Boaz Harrosh <boaz@plexistor.com>, Rik van Riel <riel@redhat.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, david <david@fromorbit.com>, Ingo Molnar <mingo@kernel.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>

On Sat, Aug 15, 2015 at 2:06 AM, Christoph Hellwig <hch@lst.de> wrote:
> On Wed, Aug 12, 2015 at 11:50:29PM -0400, Dan Williams wrote:
>> Purely for ease of testing, with this in place we can run the unit test
>> alongside any tests that depend on the memmap=ss!nn kernel parameter.
>> The unit test mocking implementation requires that libnvdimm be a module
>> and not built-in.
>>
>> A nice side effect is the implementation is a bit more generic as it no
>> longer depends on <asm/e820.h>.
>
> I really don't like this artifical split, and I also don't like how
> your weird "unit tests" force even more ugliness on the kernel.  Almost
> reminds of the python projects spending more effort on getting their
> class mockable than actually producing results..

Well, the minute you see a 'struct DeviceFactory' appear in the kernel
source you can delete all the unit tests and come take away my
keyboard.  Until then can we please push probing platform resources to
a device driver ->probe() method where it belongs?  Also given the
type-7 type-12 confusion I'm just waiting for some firmware to
describe persistent memory with type-12 at the e820 level and expect
an ACPI-NFIT to be able to sub-divide it.  In that case you'd want to
blacklist either 'nd_e820.ko' or 'nfit.ko'  to resolve the conflict.
I'm not grokking the argument against allowing this functionality to
be modular.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
