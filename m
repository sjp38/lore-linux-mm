Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AB3066B01AC
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 03:16:23 -0400 (EDT)
Message-ID: <4C2C40C2.50106@codeaurora.org>
Date: Thu, 01 Jul 2010 00:16:18 -0700
From: Zach Pfeffer <zpfeffer@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC 1/3] mm: iommu: An API to unify IOMMU, CPU and device memory
 management
References: <1277877350-2147-1-git-send-email-zpfeffer@codeaurora.org> <20100630164058.aa6aa3a2.randy.dunlap@oracle.com>
In-Reply-To: <20100630164058.aa6aa3a2.randy.dunlap@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@Oracle.COM>
Cc: mel@csn.ul.ie, andi@firstfloor.org, dwalker@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

Thank you for the corrections. I'm correcting them now. Some responses:

Randy Dunlap wrote:
>> +    struct vcm *vcm_create(size_t start_addr, size_t len);
> 
> Seems odd to use size_t for start_addr.

I used size_t because I wanted to allow the start_addr the same range
as len. Is there a better type to use? I see 'unsigned long' used
throughout the mm code. Perhaps that's better for both the start_addr
and len.


>> +A Reservation is created and destroyed with:
>> +
>> +    struct res *vcm_reserve(struct vcm *vcm, size_t len, uint32_t attr);
> 
> s/uint32_t/u32/ ?

Sure.


>> +    Associate and activate all three to their respective devices:
>> +
>> +        avcm_iommu = vcm_assoc(vcm_iommu, dev_iommu, attr0);
>> +        avcm_onetoone = vcm_assoc(vcm_onetoone, dev_onetoone, attr1);
>> +        avcm_vmm = vcm_assoc(vcm_vmm, dev_cpu, attr2);
> 
> error handling on vcm_assoc() failures?

I'll add the deassociate call to the example.


>> +        res_iommu = vcm_reserve(vcm_iommu, SZ_2MB + SZ_4K, attr);
>> +        res_onetoone = vcm_reserve(vcm_onetoone, SZ_2MB + SZ_4K, attr);
>> +        res_vmm = vcm_reserve(vcm_vmm, SZ_2MB + SZ_4K, attr);
> 
> error handling?

I'll add it here too.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
