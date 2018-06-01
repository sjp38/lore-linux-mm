Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2BF6B0007
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 06:46:23 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t133-v6so2479685oih.2
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 03:46:23 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g4-v6si13592362oia.335.2018.06.01.03.46.21
        for <linux-mm@kvack.org>;
        Fri, 01 Jun 2018 03:46:22 -0700 (PDT)
Subject: Re: [PATCH v2 21/40] iommu/arm-smmu-v3: Add support for Substream IDs
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-22-jean-philippe.brucker@arm.com>
 <BLUPR0201MB1505AA55707BE2E13392FFAFA5630@BLUPR0201MB1505.namprd02.prod.outlook.com>
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Message-ID: <be58739e-ed03-396f-c7ac-19a3195aef87@arm.com>
Date: Fri, 1 Jun 2018 11:46:07 +0100
MIME-Version: 1.0
In-Reply-To: <BLUPR0201MB1505AA55707BE2E13392FFAFA5630@BLUPR0201MB1505.namprd02.prod.outlook.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bharat Kumar Gogada <bharatku@xilinx.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "joro@8bytes.org" <joro@8bytes.org>, Will Deacon <Will.Deacon@arm.com>, Robin Murphy <Robin.Murphy@arm.com>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "tn@semihalf.com" <tn@semihalf.com>, "liubo95@huawei.com" <liubo95@huawei.com>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "xuzaibo@huawei.com" <xuzaibo@huawei.com>, "ilias.apalodimas@linaro.org" <ilias.apalodimas@linaro.org>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, "liudongdong3@huawei.com" <liudongdong3@huawei.com>, "shunyong.yang@hxt-semitech.com" <shunyong.yang@hxt-semitech.com>, "nwatters@codeaurora.org" <nwatters@codeaurora.org>, "okaya@codeaurora.org" <okaya@codeaurora.org>, "jcrouse@codeaurora.org" <jcrouse@codeaurora.org>, "rfranz@cavium.com" <rfranz@cavium.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "jacob.jun.pan@linux.intel.com" <jacob.jun.pan@linux.intel.com>, "yi.l.liu@intel.com" <yi.l.liu@intel.com>, "ashok.raj@intel.com" <ashok.raj@intel.com>, "kevin.tian@intel.com" <kevin.tian@intel.com>, "baolu.lu@linux.intel.com" <baolu.lu@linux.intel.com>, "robdclark@gmail.com" <robdclark@gmail.com>, "christian.koenig@amd.com" <christian.koenig@amd.com>, Ravikiran Gummaluri <rgummal@xilinx.com>

On 31/05/18 12:01, Bharat Kumar Gogada wrote:
>>  static void arm_smmu_sync_cd(void *cookie, int ssid, bool leaf)  {
>> +	struct arm_smmu_cmdq_ent cmd = {
>> +		.opcode	= CMDQ_OP_CFGI_CD_ALL,
> 
> Hi Jean, here CMDQ_OP_CFGI_CD opcode 0x5. 

Woops, nice catch!

I pushed fixes for all comments so far to branch sva/current

Thanks,
Jean
