Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3B0CA6B0253
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 15:23:35 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id v25so5597347pfg.14
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 12:23:35 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id o3si3628832pld.695.2017.12.14.12.23.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 12:23:33 -0800 (PST)
Date: Thu, 14 Dec 2017 19:08:54 -0800
From: "Raj, Ashok" <ashok.raj@intel.com>
Subject: Re: [PATCH 1/2] mm: Add kernel MMU notifier to manage IOTLB/DEVTLB
Message-ID: <20171215030854.GA69597@otc-nc-03>
References: <1513213366-22594-1-git-send-email-baolu.lu@linux.intel.com>
 <1513213366-22594-2-git-send-email-baolu.lu@linux.intel.com>
 <a98903c2-e67c-a0cc-3ad1-60b9aa4e4c93@huawei.com>
 <5A31F232.90901@linux.intel.com>
 <e7462b54-9d3a-abfd-8df2-2db3780de78d@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e7462b54-9d3a-abfd-8df2-2db3780de78d@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <liubo95@huawei.com>
Cc: Lu Baolu <baolu.lu@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Alex Williamson <alex.williamson@redhat.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.com>, Dave Jiang <dave.jiang@intel.com>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, iommu@lists.linux-foundation.org, Vegard Nossum <vegard.nossum@oracle.com>, Andy Lutomirski <luto@kernel.org>, Huang Ying <ying.huang@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Ashok Raj <ashok.raj@intel.com>

Hi Bob

On Thu, Dec 14, 2017 at 02:07:38PM +0800, Bob Liu wrote:
> On 2017/12/14 11:38, Lu Baolu wrote:

> >>>> We already have an existing MMU notifiers for userspace updates,
> >>>> however we lack the same thing for kernel page table updates. To
> >> Sorry, I didn't get which situation need this notification.
> >> Could you please describe the full scenario?
> > 
> > Okay.
> > 
> > 1. When an SVM capable driver calls intel_svm_bind_mm() with
> >     SVM_FLAG_SUPERVISOR_MODE set in the @flags, the kernel
> >     memory page mappings will be shared between CPUs and
> >     the DMA remapping agent (a.k.a. IOMMU). The page table
> >     entries will also be cached in both IOTLB (located in IOMMU)
> >     and the DEVTLB (located in device).
> > 
> 
> But who/what kind of real device has the requirement to access a kernel VA?
> Looks like SVM_FLAG_SUPERVISOR_MODE is used by nobody?

That's right, there is no inkernel user at the moment, but we certainly see
them coming.

Maybe not the best example :-), but I'm told Lustre and some of the 
modern NIC's also can benefit from SVM in kernel use.

Not a hypothetical use case certainly!


Cheers,
Ashok

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
