Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4F3DF830A8
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 19:43:43 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id p188so171913868oih.2
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 16:43:43 -0700 (PDT)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id z7si1589938ota.7.2016.04.21.16.43.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Apr 2016 16:43:42 -0700 (PDT)
Subject: Re: [PATCH v3 0/2] Align mmap address for DAX pmd mappings
References: <1460652511-19636-1-git-send-email-toshi.kani@hpe.com>
 <20160415220531.c7b55adb5b26eb749fae3186@linux-foundation.org>
 <20160418202610.GA17889@quack2.suse.cz>
 <20160419182347.GA29068@linux.intel.com> <571844A1.5080703@hpe.com>
 <20160421070625.GB29068@linux.intel.com> <57193658.9020803@oracle.com>
From: Toshi Kani <toshi.kani@hpe.com>
Message-ID: <571965AB.9070707@hpe.com>
Date: Thu, 21 Apr 2016 19:43:39 -0400
MIME-Version: 1.0
In-Reply-To: <57193658.9020803@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Matthew Wilcox <willy@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "david@fromorbit.com" <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "adilger.kernel@dilger.ca" <adilger.kernel@dilger.ca>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>


On 4/21/2016 4:21 PM, Mike Kravetz wrote:
> On 04/21/2016 12:06 AM, Matthew Wilcox wrote:
>> On Wed, Apr 20, 2016 at 11:10:25PM -0400, Toshi Kani wrote:
>>> How about moving the function (as is) to mm/huge_memory.c, rename it to
>>> get_hugepage_unmapped_area(), which is defined to NULL in huge_mm.h
>>> when TRANSPARENT_HUGEPAGE is unset?
>> Great idea.  Perhaps it should look something like this?
>>
>> unsigned long thp_get_unmapped_area(struct file *filp, unsigned long addr,
>>                  unsigned long len, unsigned long pgoff, unsigned long flags)
>> {
> Might want to keep the future possibility of PUD_SIZE THP in mind?

Yes, this is why the func name does not say 'pmd'. It can be extended to 
support
PUD_SIZE in future.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
