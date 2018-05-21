Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id B534E6B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 10:43:23 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id n25-v6so12350254otf.13
        for <linux-mm@kvack.org>; Mon, 21 May 2018 07:43:23 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y3-v6si5231086otd.128.2018.05.21.07.43.22
        for <linux-mm@kvack.org>;
        Mon, 21 May 2018 07:43:22 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: Re: [PATCH v2 02/40] iommu/sva: Bind process address spaces to
 devices
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-3-jean-philippe.brucker@arm.com>
 <20180517141058.00001c76@huawei.com>
Message-ID: <19001b20-93de-6bf5-c72a-783e5d20b1bc@arm.com>
Date: Mon, 21 May 2018 15:43:11 +0100
MIME-Version: 1.0
In-Reply-To: <20180517141058.00001c76@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Cc: kvm@vger.kernel.org, linux-pci@vger.kernel.org, xuzaibo@huawei.com, will.deacon@arm.com, okaya@codeaurora.org, linux-mm@kvack.org, ashok.raj@intel.com, bharatku@xilinx.com, linux-acpi@vger.kernel.org, rfranz@cavium.com, devicetree@vger.kernel.org, rgummal@xilinx.com, linux-arm-kernel@lists.infradead.org, dwmw2@infradead.org, ilias.apalodimas@linaro.org, iommu@lists.linux-foundation.org, christian.koenig@amd.com

On 17/05/18 14:10, Jonathan Cameron wrote:
> On Fri, 11 May 2018 20:06:03 +0100
> Jean-Philippe Brucker <jean-philippe.brucker@arm.com> wrote:
> 
>> Add bind() and unbind() operations to the IOMMU API. Bind() returns a
>> PASID that drivers can program in hardware, to let their devices access an
>> mm. This patch only adds skeletons for the device driver API, most of the
>> implementation is still missing.
>>
>> IOMMU groups with more than one device aren't supported for SVA at the
>> moment. There may be P2P traffic between devices within a group, which
>> cannot be seen by an IOMMU (note that supporting PASID doesn't add any
>> form of isolation with regard to P2P). Supporting groups would require
>> calling bind() for all bound processes every time a device is added to a
>> group, to perform sanity checks (e.g. ensure that new devices support
>> PASIDs at least as big as those already allocated in the group).
> 
> Is it worth adding an explicit comment on this reasoning (or a minimal subset
> of it) at the check for the number of devices in the group?
> It's well laid out here, but might not be so obvious if someone is reading
> the code in the future.

Sure, I'll add something

Thanks,
Jean
