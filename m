Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 691B06B002B
	for <linux-mm@kvack.org>; Wed, 30 Dec 2015 22:28:52 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id uo6so124925087pac.1
        for <linux-mm@kvack.org>; Wed, 30 Dec 2015 19:28:52 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id y74si63964119pfi.40.2015.12.30.19.28.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Dec 2015 19:28:51 -0800 (PST)
Message-ID: <5684A0CD.9040005@oracle.com>
Date: Thu, 31 Dec 2015 11:28:13 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 2/7] dax: support dirty DAX entries in radix tree
References: <1450899560-26708-1-git-send-email-ross.zwisler@linux.intel.com> <1450899560-26708-3-git-send-email-ross.zwisler@linux.intel.com> <56838FA3.5030909@oracle.com> <CAPcyv4jAO-jJ3VCOJRCc7zrQULED362SdZ88dDgN+zfQQEsfsA@mail.gmail.com>
In-Reply-To: <CAPcyv4jAO-jJ3VCOJRCc7zrQULED362SdZ88dDgN+zfQQEsfsA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>, XFS Developers <xfs@oss.sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>


On 12/31/2015 04:39 AM, Dan Williams wrote:
> On Wed, Dec 30, 2015 at 12:02 AM, Bob Liu <bob.liu@oracle.com> wrote:
>> Hi Ross,
>>
>> On 12/24/2015 03:39 AM, Ross Zwisler wrote:
>>> Add support for tracking dirty DAX entries in the struct address_space
>>> radix tree.  This tree is already used for dirty page writeback, and it
>>> already supports the use of exceptional (non struct page*) entries.
>>>
>>> In order to properly track dirty DAX pages we will insert new exceptional
>>> entries into the radix tree that represent dirty DAX PTE or PMD pages.
>>
>> I may get it wrong, but there is "struct page" for persistent memory after
>> "[PATCH v4 00/18]get_user_pages() for dax pte and pmd mappings".
>> So why not just add "struct page" to radix tree directly just like normal page cache?
>>
>> Then we don't need to deal with any exceptional entries and special writeback.
> 
> That "struct page" is optional and fsync/msync needs to operate in its absence.
> 

Any special reason or scenario that "struct page" should not be enabled?
I didn't see any disadvantages if always enable "struct page" by force when using DAX model for pmem.
The benefits would be things can be more simple and less potential bugs because of smaller patches.

Happy New Year!
Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
