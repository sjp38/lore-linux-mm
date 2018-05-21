Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id C02F86B0007
	for <linux-mm@kvack.org>; Mon, 21 May 2018 10:50:01 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id a14-v6so12356404otf.1
        for <linux-mm@kvack.org>; Mon, 21 May 2018 07:50:01 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w23-v6si4653710oif.222.2018.05.21.07.50.00
        for <linux-mm@kvack.org>;
        Mon, 21 May 2018 07:50:00 -0700 (PDT)
Subject: Re: [PATCH v2 17/40] iommu/arm-smmu-v3: Link domains and devices
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-18-jean-philippe.brucker@arm.com>
 <20180517170748.00004927@huawei.com>
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Message-ID: <652e5b8c-fa51-0fec-01fe-0fccc999ecf6@arm.com>
Date: Mon, 21 May 2018 15:49:51 +0100
MIME-Version: 1.0
In-Reply-To: <20180517170748.00004927@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Cc: kvm@vger.kernel.org, linux-pci@vger.kernel.org, xuzaibo@huawei.com, will.deacon@arm.com, okaya@codeaurora.org, linux-mm@kvack.org, ashok.raj@intel.com, bharatku@xilinx.com, linux-acpi@vger.kernel.org, rfranz@cavium.com, devicetree@vger.kernel.org, rgummal@xilinx.com, linux-arm-kernel@lists.infradead.org, dwmw2@infradead.org, ilias.apalodimas@linaro.org, iommu@lists.linux-foundation.org, christian.koenig@amd.com

On 17/05/18 17:07, Jonathan Cameron wrote:
>> +++ b/drivers/iommu/arm-smmu-v3.c
>> @@ -595,6 +595,11 @@ struct arm_smmu_device {
>>  struct arm_smmu_master_data {
>>  	struct arm_smmu_device		*smmu;
>>  	struct arm_smmu_strtab_ent	ste;
>> +
>> +	struct arm_smmu_domain		*domain;
>> +	struct list_head		list; /* domain->devices */
> 
> More meaningful name perhaps to avoid the need for the comment?

Sure

Thanks,
Jean
