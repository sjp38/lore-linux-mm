Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AE5D06B0008
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 08:54:01 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id f19so11054416pfn.6
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 05:54:01 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id u14si11626503pgq.103.2018.04.17.05.53.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 17 Apr 2018 05:53:59 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 01/12] iommu-common: move to arch/sparc
In-Reply-To: <f5741528-427d-3537-5498-2080766df0fe@linux.vnet.ibm.com>
References: <20180415145947.1248-1-hch@lst.de> <20180415145947.1248-2-hch@lst.de> <f0305a92-b206-1567-3c25-67fbd194047d@linux.vnet.ibm.com> <20180416.095833.969403163564136309.davem@davemloft.net> <f5741528-427d-3537-5498-2080766df0fe@linux.vnet.ibm.com>
Date: Tue, 17 Apr 2018 22:53:53 +1000
Message-ID: <87wox60za6.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, David Miller <davem@davemloft.net>khandual@linux.vnet.ibm.com
Cc: hch@lst.de, konrad.wilk@oracle.com, iommu@lists.linux-foundation.org, x86@kernel.org, linux-block@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-ide@vger.kernel.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

Anshuman Khandual <khandual@linux.vnet.ibm.com> writes:
> On 04/16/2018 07:28 PM, David Miller wrote:
>> From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
>> Date: Mon, 16 Apr 2018 14:26:07 +0530
>> 
>>> On 04/15/2018 08:29 PM, Christoph Hellwig wrote:
>>>> This code is only used by sparc, and all new iommu drivers should use the
>>>> drivers/iommu/ framework.  Also remove the unused exports.
>>>>
>>>> Signed-off-by: Christoph Hellwig <hch@lst.de>
>>>
>>> Right, these functions are used only from SPARC architecture. Simple
>>> git grep confirms it as well. Hence it makes sense to move them into
>>> arch code instead.
>> 
>> Well, we put these into a common location and used type friendly for
>> powerpc because we hoped powerpc would convert over to using this
>> common piece of code as well.
>> 
>> But nobody did the powerpc work.
 
Sorry.

>> If you look at the powerpc iommu support, it's the same code basically
>> for entry allocation.
>
> I understand. But there are some differences in iommu_table structure,
> how both regular and large IOMMU pools are being initialized etc. So
> if the movement of code into SPARC help cleaning up these generic config
> options in general, I guess we should do that. But I will leave it upto
> others who have more experience in this area.
>
> +mpe

This is the first I've heard of it, I guess it's probably somewhere on
Ben's append-only TODO list.

Some of the code does look very similar, but not 100%. So someone would
need to do some work to reconcile the two and test the result. TBH I
doubt we're going to get around to it any time soon. Unless we have a
volunteer?

cheers
