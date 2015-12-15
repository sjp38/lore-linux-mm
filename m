Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 46C836B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 20:59:02 -0500 (EST)
Received: by qkfb125 with SMTP id b125so166229005qkf.2
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 17:59:02 -0800 (PST)
Received: from mail-qk0-x230.google.com (mail-qk0-x230.google.com. [2607:f8b0:400d:c09::230])
        by mx.google.com with ESMTPS id u84si37640411qhu.124.2015.12.14.17.59.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 17:59:01 -0800 (PST)
Received: by qkck189 with SMTP id k189so131032258qkc.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 17:59:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4hQP0rh+LdWsc2KATxxQyq31PAT-HBfMkS7YNdhDt-=dw@mail.gmail.com>
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
	<CAPcyv4hQP0rh+LdWsc2KATxxQyq31PAT-HBfMkS7YNdhDt-=dw@mail.gmail.com>
Date: Mon, 14 Dec 2015 17:59:00 -0800
Message-ID: <CAPcyv4jLAgkk9xhJjk1HS0gBrZg2YfmVh91V0ZeYEzge2FiJhg@mail.gmail.com>
Subject: Re: [-mm PATCH v2 00/25] get_user_pages() for dax pte and pmd mappings
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave@sr71.net>, Toshi Kani <toshi.kani@hpe.com>, David Airlie <airlied@linux.ie>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Linux MM <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Christoph Hellwig <hch@lst.de>, Andrea Arcangeli <aarcange@redhat.com>, kbuild test robot <lkp@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Richard Weinberger <richard@nod.at>, X86 ML <x86@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jeff Dike <jdike@addtoit.com>, Jens Axboe <axboe@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Christoffer Dall <christoffer.dall@linaro.org>, Jan Kara <jack@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Dec 11, 2015 at 10:44 AM, Dan Williams <dan.j.williams@intel.com> wrote:
> On Wed, Dec 9, 2015 at 6:37 PM, Dan Williams <dan.j.williams@intel.com> wrote:
>> Changes since v1: [1]
>>
>> 1/ Rebase on latest -next (20151209).  Fixed up PHYSICAL_PAGE_MASK, but
>>    no other major collisions.
>>
>> 2/ Decreased the transfer size in "dax: increase granularity of
>>    dax_clear_blocks() operations" to get the max latency to reschedule
>>    under 1ms and average latency under 150us. (Andrew)
>>
>> 3/ Add cc's for x86 maintainers
>>
>> 4/ Add Tested-by: Logan Gunthorpe
>>
>> This update, as before, passes the ndctl [2] and nvml [3] test suites.
>>
>> [1]: https://lists.01.org/pipermail/linux-nvdimm/2015-December/003213.html
>> [2]: https://github.com/pmem/ndctl
>> [3]: https://github.com/pmem/nvml
>>
>> A git tree of this set is available here:
>>
>>   git://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm libnvdimm-pending
>>
>
> Andrew,
>
> I went ahead and rebased the tree on next-20151211, and refreshed 3
> patches with the following changes (sent as replies to avoid spamming
> folks with the other 22 patches that did not change):
>
> [-mm PATCH v3 04/25] dax: fix lifetime of in-kernel dax mappings with
> dax_map_atomic()
>
> Updated to the new definition of blk_queue_enter() from commit
> 6f3b0e8bcf3c "blk-mq: add a flags parameter to blk_mq_alloc_request"
>
>
> [-mm PATCH v3 09/25] mm, dax, pmem: introduce pfn_t
>
> Moved phys_to_pfn_t() out of line to enable some new unit tests.
>
>
> [-mm PATCH v3 10/25] mm: introduce find_dev_pagemap()
>
> Just a reflow to pick up the context differences from the changes in
> [-mm PATCH v3 09/25].
>
> These updates (plus next-20151211) continue to pass all my tests and
> have been pushed out to the 'libnvdimm-pending' branch.

The set continues to re-apply and re-test cleanly on top of next-20151214.

I have patches and documentation updates queued up for the 'ndctl'
utility to address Jeff's concern about the administrative interface.

Any other blocking concerns?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
