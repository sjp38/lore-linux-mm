Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD4F6B027C
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 09:18:50 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id e69so2224048pgc.15
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 06:18:50 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id z67si1327219pgb.424.2017.11.29.06.18.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 06:18:49 -0800 (PST)
Message-ID: <5A1EC23A.5090900@intel.com>
Date: Wed, 29 Nov 2017 22:20:42 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v17 2/6] radix tree test suite: add tests for xbitmap
References: <1509696786-1597-1-git-send-email-wei.w.wang@intel.com> <1509696786-1597-3-git-send-email-wei.w.wang@intel.com> <20171106170000.GA1195@bombadil.infradead.org>
In-Reply-To: <20171106170000.GA1195@bombadil.infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On 11/07/2017 01:00 AM, Matthew Wilcox wrote:
> On Fri, Nov 03, 2017 at 04:13:02PM +0800, Wei Wang wrote:
>> From: Matthew Wilcox <mawilcox@microsoft.com>
>>
>> Add the following tests for xbitmap:
>> 1) single bit test: single bit set/clear/find;
>> 2) bit range test: set/clear a range of bits and find a 0 or 1 bit in
>> the range.
>>
>> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
>> Cc: Matthew Wilcox <mawilcox@microsoft.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Michael S. Tsirkin <mst@redhat.com>
>> ---
>>   tools/include/linux/bitmap.h            |  34 ++++
>>   tools/include/linux/kernel.h            |   2 +
>>   tools/testing/radix-tree/Makefile       |   7 +-
>>   tools/testing/radix-tree/linux/kernel.h |   2 -
>>   tools/testing/radix-tree/main.c         |   5 +
>>   tools/testing/radix-tree/test.h         |   1 +
>>   tools/testing/radix-tree/xbitmap.c      | 278 ++++++++++++++++++++++++++++++++
> Umm.  No.  You've duplicated xbitmap.c into the test framework, so now it can
> slowly get out of sync with the one in lib/.  That's not OK.
>
> Put it back the way it was, with the patch I gave you as patch 1/n
> (relocating xbitmap.c from tools/testing/radix-tree to lib/).
> Then add your enhancements as patch 2/n.  All you should need to
> change in your 1/n from
> http://git.infradead.org/users/willy/linux-dax.git/commit/727e401bee5ad7d37e0077291d90cc17475c6392
> is a bit of Makefile tooling.  Leave the test suite embedded in the file;
> that way people might remember to update the test suite when adding
> new functionality.
>

Thanks for you suggestions. Please have a check the v18 patches:
The original implementation is put in patch 4, and the proposed changes 
are separated into patch 5 (we can merge them to patch 4 later if they 
look good to you), and the new APIs are in patch 6.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
