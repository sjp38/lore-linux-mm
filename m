Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id BEB6E6B78CE
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 08:45:56 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id l191-v6so12466728oig.23
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 05:45:56 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c188-v6si3411569oia.340.2018.09.06.05.45.55
        for <linux-mm@kvack.org>;
        Thu, 06 Sep 2018 05:45:55 -0700 (PDT)
Subject: Re: [PATCH v2 01/40] iommu: Introduce Shared Virtual Addressing API
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-2-jean-philippe.brucker@arm.com>
 <bf42affd-e9d0-e4fc-6d28-f3c3f7795348@redhat.com>
 <03d31ba5-1eda-ea86-8c0c-91d14c86fe83@arm.com>
 <ed39159c-087e-7e56-7d29-d1de9fa1677f@amd.com>
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Message-ID: <f0b317d5-e2e9-5478-952c-05e8b97bd68b@arm.com>
Date: Thu, 6 Sep 2018 13:45:36 +0100
MIME-Version: 1.0
In-Reply-To: <ed39159c-087e-7e56-7d29-d1de9fa1677f@amd.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, Auger Eric <eric.auger@redhat.com>, linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: xieyisheng1@huawei.com, liubo95@huawei.com, xuzaibo@huawei.com, thunder.leizhen@huawei.com, will.deacon@arm.com, okaya@codeaurora.org, yi.l.liu@intel.com, ashok.raj@intel.com, tn@semihalf.com, joro@8bytes.org, bharatku@xilinx.com, liudongdong3@huawei.com, rfranz@cavium.com, kevin.tian@intel.com, jacob.jun.pan@linux.intel.com, jcrouse@codeaurora.org, rgummal@xilinx.com, jonathan.cameron@huawei.com, shunyong.yang@hxt-semitech.com, robin.murphy@arm.com, ilias.apalodimas@linaro.org, alex.williamson@redhat.com, robdclark@gmail.com, dwmw2@infradead.org, nwatters@codeaurora.org, baolu.lu@linux.intel.com

On 06/09/2018 12:12, Christian KA?nig wrote:
> Am 06.09.2018 um 13:09 schrieb Jean-Philippe Brucker:
>> Hi Eric,
>>
>> Thanks for reviewing
>>
>> On 05/09/2018 12:29, Auger Eric wrote:
>>>> +int iommu_sva_device_init(struct device *dev, unsigned long features,
>>>> +A A A A A A A A A A A A A  unsigned int max_pasid)
>>> what about min_pasid?
>> No one asked for it... The max_pasid parameter is here for drivers that
>> have vendor-specific PASID size limits, such as AMD KFD (see
>> kfd_iommu_device_init and
>> https://patchwork.kernel.org/patch/9989307/#21389571). But in most cases
>> the PASID size will only depend on the PCI PASID capability and the
>> IOMMU limits, both known by the IOMMU driver, so device drivers won't
>> have to set max_pasid.
>>
>> IOMMU drivers need to set min_pasid in the sva_device_init callback
>> because it may be either 1 (e.g. Arm where PASID #0 is reserved) or 0
>> (Intel Vt-d rev2), but at the moment I can't see a reason for device
>> drivers to override min_pasid
> 
> Sorry to ruin your day, but if I'm not completely mistaken PASID zero is
> reserved in the AMD KFD as well.

Heh, fair enough. I'll add the min_pasid parameter

Thanks,
Jean
