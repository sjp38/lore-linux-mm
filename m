Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 995A76B02A3
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 18:02:37 -0400 (EDT)
Message-ID: <bb667e285fd8be82ea8cc9cc25cf335b.squirrel@www.codeaurora.org>
In-Reply-To: <20100719184002.GA21608@n2100.arm.linux.org.uk>
References: <20100713150311B.fujita.tomonori@lab.ntt.co.jp>
    <20100713121420.GB4263@codeaurora.org>
    <20100714104353B.fujita.tomonori@lab.ntt.co.jp>
    <20100714201149.GA14008@codeaurora.org>
    <20100714220536.GE18138@n2100.arm.linux.org.uk>
    <20100715012958.GB2239@codeaurora.org>
    <20100715085535.GC26212@n2100.arm.linux.org.uk>
    <AANLkTinVZeaZxt_lWKhjKa0dqhu3_j3BRNySO-2LvMdw@mail.gmail.com>
    <20100716075856.GC16124@n2100.arm.linux.org.uk>
    <4C449183.20000@codeaurora.org>
    <20100719184002.GA21608@n2100.arm.linux.org.uk>
Date: Tue, 20 Jul 2010 15:02:34 -0700 (PDT)
Subject: Re: [RFC 1/3 v3] mm: iommu: An API to unify IOMMU,
      CPU and device memory management
From: stepanm@codeaurora.org
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Michael Bohan <mbohan@codeaurora.org>, Tim HRM <zt.tmzt@gmail.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, ebiederm@xmission.com, linux-arch@vger.kernel.org, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

Russell-

If a driver wants to allow a device to access memory (and cache coherency
is off/not present for device addesses), the driver needs to remap that
memory as non-cacheable. Suppose there exists a chunk of
physically-contiguous memory (say, memory reserved for device use) that
happened to be already mapped into the kernel as normal memory (cacheable,
etc). One way to remap this memory is to use ioremap (and then never touch
the original virtual mapping, which would now have conflicting
attributes). I feel as if there should be a better way to remap memory for
device access, either by altering the attributes on the original mapping,
or removing the original mapping and creating a new one with attributes
set to non-cacheable. Is there a better way to do this than calling
ioremap() on that memory? Please advise.

Thanks
Steve


Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.


> On Mon, Jul 19, 2010 at 10:55:15AM -0700, Michael Bohan wrote:
>>
>> On 7/16/2010 12:58 AM, Russell King - ARM Linux wrote:
>>
>>> As the patch has been out for RFC since early April on the
>>> linux-arm-kernel
>>> mailing list (Subject: [RFC] Prohibit ioremap() on kernel managed RAM),
>>> and no comments have come back from Qualcomm folk.
>>
>> Would it be unreasonable to allow a map request to succeed if the
>> requested attributes matched that of the preexisting mapping?
>
> What would be the point of creating such a mapping?
> --
> To unsubscribe from this list: send the line "unsubscribe linux-arm-msm"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
