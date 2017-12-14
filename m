Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4F8F96B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 01:43:33 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id i14so3361989pgf.13
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 22:43:33 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id g131si2456899pgc.477.2017.12.13.22.43.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 22:43:31 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH 1/2] mm: Add kernel MMU notifier to manage IOTLB/DEVTLB
References: <1513213366-22594-1-git-send-email-baolu.lu@linux.intel.com>
	<1513213366-22594-2-git-send-email-baolu.lu@linux.intel.com>
	<a98903c2-e67c-a0cc-3ad1-60b9aa4e4c93@huawei.com>
	<5A31F232.90901@linux.intel.com>
	<4466eac3-c4f5-47e4-e568-912a560240c1@intel.com>
Date: Thu, 14 Dec 2017 14:43:27 +0800
In-Reply-To: <4466eac3-c4f5-47e4-e568-912a560240c1@intel.com> (Dave Hansen's
	message of "Wed, 13 Dec 2017 22:28:37 -0800")
Message-ID: <87efnxn71s.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Lu Baolu <baolu.lu@linux.intel.com>, Bob Liu <liubo95@huawei.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Alex Williamson <alex.williamson@redhat.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.com>, Dave Jiang <dave.jiang@intel.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Vegard Nossum <vegard.nossum@oracle.com>, Andy Lutomirski <luto@kernel.org>, Matthew Wilcox <willy@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Kees Cook <keescook@chromium.org>, "xieyisheng (A)" <xieyisheng1@huawei.com>

Hi, Dave,

Dave Hansen <dave.hansen@intel.com> writes:

> On 12/13/2017 07:38 PM, Lu Baolu wrote:
>> 2. When vmalloc/vfree interfaces are called, the page mappings
>>     for kernel memory might get changed. And current code calls
>>     flush_tlb_kernel_range() to flush CPU TLBs only. The IOTLB or
>>     DevTLB will be stale compared to that on the cpu for kernel
>>     mappings.
>
> What's the plan to deal with all of the ways other than vmalloc() that
> the kernel changes the page tables?

The kernel MMU notifier is called in flush_tlb_kernel_range().  So IOMMU
will be notified for TLB flushing caused by all ways that the kernel
changes the page tables including vmalloc, kmap, etc.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
