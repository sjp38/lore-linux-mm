Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id C01DD6B027D
	for <linux-mm@kvack.org>; Mon, 28 Dec 2015 22:24:40 -0500 (EST)
Received: by mail-yk0-f180.google.com with SMTP id v14so26533413ykd.3
        for <linux-mm@kvack.org>; Mon, 28 Dec 2015 19:24:40 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id k123si43712604ywg.143.2015.12.28.19.24.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Dec 2015 19:24:39 -0800 (PST)
Message-ID: <5681FCAE.4060208@oracle.com>
Date: Tue, 29 Dec 2015 11:23:26 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [-mm PATCH v4 00/18] get_user_pages() for dax pte and pmd mappings
References: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com> <CAA_GA1f44ADq7dw7LUM=rEex8m0vMXvGeOdW1YKkisbv51iuKw@mail.gmail.com> <CAPcyv4j5QRAy-pM=TcCVrY8tH8H7iOL36KojZOeHKuLdBOcwDg@mail.gmail.com>
In-Reply-To: <CAPcyv4j5QRAy-pM=TcCVrY8tH8H7iOL36KojZOeHKuLdBOcwDg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Bob Liu <lliubbo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@sr71.net>, David Airlie <airlied@linux.ie>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Linux-MM <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Christoph Hellwig <hch@lst.de>, Andrea Arcangeli <aarcange@redhat.com>, kbuild test robot <lkp@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Christoffer Dall <christoffer.dall@linaro.org>, Paolo Bonzini <pbonzini@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>


On 12/28/2015 02:55 AM, Dan Williams wrote:
> On Sun, Dec 27, 2015 at 12:33 AM, Bob Liu <lliubbo@gmail.com> wrote:
>> Hey Dan,
>>
> [..]
>> What about space for page tables?
>> Page tables(mapping all memory in PMEM to virtual address space) may
>> also consume significantly DRAM space if  huge page is not enabled or
>> split.
>> Should we also consider to allocate pte page tables from PMEM in future?
> 
> On x86_64 these ranges are covered by gigabyte pages by default (see
> init_memory_mapping()).  I don't see much incremental benefit from
> allocating pte's from pmem.
> 

Oh, that's the direct mapping. I mean ptes consumed in:
__dax_fault > dax_insert_mapping > insert_pfn > __get_locked_pte

In some bad situations e.g mmap a lot of large ext4 files exist in pmem but
hugepage can't be used because of fragmentation, then the consumption of pte
page tables may can't be ignored?
Anyway, this is not a blocker of these patches.
Thanks,
Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
