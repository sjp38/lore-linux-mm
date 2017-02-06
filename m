Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 410356B0253
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 12:30:24 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id j82so84218086oih.6
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 09:30:24 -0800 (PST)
Received: from mail-oi0-x235.google.com (mail-oi0-x235.google.com. [2607:f8b0:4003:c06::235])
        by mx.google.com with ESMTPS id n187si530440oih.239.2017.02.06.09.30.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 09:30:23 -0800 (PST)
Received: by mail-oi0-x235.google.com with SMTP id u143so50713182oif.3
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 09:30:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170206172731.GA17515@infradead.org>
References: <148615748258.43180.1690152053774975329.stgit@djiang5-desk3.ch.intel.com>
 <20170206143648.GA461@infradead.org> <CAPcyv4jHYR2-_SgD7a6ab5vWigYsDoSb7FZdTchP8Xg+BF-2yg@mail.gmail.com>
 <20170206172731.GA17515@infradead.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 6 Feb 2017 09:30:22 -0800
Message-ID: <CAPcyv4hiwWebCT=qPccKqaQKAHydMYsg9+=pYh=SPkNzakLc1A@mail.gmail.com>
Subject: Re: [PATCH] mm: replace FAULT_FLAG_SIZE with parameter to huge_fault
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-ext4 <linux-ext4@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Feb 6, 2017 at 9:27 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Mon, Feb 06, 2017 at 08:24:48AM -0800, Dan Williams wrote:
>> > Also can be use this opportunity
>> > to fold ->huge_fault into ->fault?
>>
>> Hmm, yes, just need a scheme to not attempt huge_faults on pte-only handlers.
>
> Do we need anything more than checking vma->vm_flags for VM_HUGETLB?

s/VM_HUGETLB/VM_HUGEPAGE/

...but yes as long as we specify that a VM_HUGEPAGE handler must
minimally handle pud and pmd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
