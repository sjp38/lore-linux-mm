Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 269C36B0003
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 01:51:12 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id 132so2077646qkl.7
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 22:51:12 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v68si4827814qkc.392.2018.04.16.22.51.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 22:51:11 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3H5nh06077320
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 01:51:10 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hd4m8p1g4-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 01:51:09 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 17 Apr 2018 06:51:07 +0100
Subject: Re: [PATCH 01/12] iommu-common: move to arch/sparc
References: <20180415145947.1248-1-hch@lst.de>
 <20180415145947.1248-2-hch@lst.de>
 <f0305a92-b206-1567-3c25-67fbd194047d@linux.vnet.ibm.com>
 <20180416.095833.969403163564136309.davem@davemloft.net>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 17 Apr 2018 11:20:58 +0530
MIME-Version: 1.0
In-Reply-To: <20180416.095833.969403163564136309.davem@davemloft.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <f5741528-427d-3537-5498-2080766df0fe@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, khandual@linux.vnet.ibm.com
Cc: hch@lst.de, konrad.wilk@oracle.com, iommu@lists.linux-foundation.org, x86@kernel.org, linux-block@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-ide@vger.kernel.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Michael Ellerman <mpe@ellerman.id.au>

On 04/16/2018 07:28 PM, David Miller wrote:
> From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> Date: Mon, 16 Apr 2018 14:26:07 +0530
> 
>> On 04/15/2018 08:29 PM, Christoph Hellwig wrote:
>>> This code is only used by sparc, and all new iommu drivers should use the
>>> drivers/iommu/ framework.  Also remove the unused exports.
>>>
>>> Signed-off-by: Christoph Hellwig <hch@lst.de>
>>
>> Right, these functions are used only from SPARC architecture. Simple
>> git grep confirms it as well. Hence it makes sense to move them into
>> arch code instead.
> 
> Well, we put these into a common location and used type friendly for
> powerpc because we hoped powerpc would convert over to using this
> common piece of code as well.
> 
> But nobody did the powerpc work.
> 
> If you look at the powerpc iommu support, it's the same code basically
> for entry allocation.

I understand. But there are some differences in iommu_table structure,
how both regular and large IOMMU pools are being initialized etc. So
if the movement of code into SPARC help cleaning up these generic config
options in general, I guess we should do that. But I will leave it upto
others who have more experience in this area.

+mpe
