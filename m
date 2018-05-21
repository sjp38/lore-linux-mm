Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id D83996B0005
	for <linux-mm@kvack.org>; Mon, 21 May 2018 10:52:51 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id c6-v6so12374177otk.9
        for <linux-mm@kvack.org>; Mon, 21 May 2018 07:52:51 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f2-v6si4604589oia.204.2018.05.21.07.52.51
        for <linux-mm@kvack.org>;
        Mon, 21 May 2018 07:52:51 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: Re: [PATCH v2 35/40] iommu/arm-smmu-v3: Add support for PCI ATS
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-36-jean-philippe.brucker@arm.com>
 <922474e8-0aa5-e022-0502-f1e51b0d4859@codeaurora.org>
Message-ID: <08f53ea4-bd39-a567-9c79-f4381e5fb461@arm.com>
Date: Mon, 21 May 2018 15:52:39 +0100
MIME-Version: 1.0
In-Reply-To: <922474e8-0aa5-e022-0502-f1e51b0d4859@codeaurora.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sinan Kaya <okaya@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "joro@8bytes.org" <joro@8bytes.org>, Will Deacon <Will.Deacon@arm.com>, Robin Murphy <Robin.Murphy@arm.com>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "tn@semihalf.com" <tn@semihalf.com>, "liubo95@huawei.com" <liubo95@huawei.com>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "xuzaibo@huawei.com" <xuzaibo@huawei.com>, "ilias.apalodimas@linaro.org" <ilias.apalodimas@linaro.org>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, "liudongdong3@huawei.com" <liudongdong3@huawei.com>, "shunyong.yang@hxt-semitech.com" <shunyong.yang@hxt-semitech.com>, "nwatters@codeaurora.org" <nwatters@codeaurora.org>, "jcrouse@codeaurora.org" <jcrouse@codeaurora.org>, "rfranz@cavium.com" <rfranz@cavium.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "jacob.jun.pan@linux.intel.com" <jacob.jun.pan@linux.intel.com>, "yi.l.liu@intel.com" <yi.l.liu@intel.com>, "ashok.raj@intel.com" <ashok.raj@intel.com>, "kevin.tian@intel.com" <kevin.tian@intel.com>, "baolu.lu@linux.intel.com" <baolu.lu@linux.intel.com>, "robdclark@gmail.com" <robdclark@gmail.com>, "christian.koenig@amd.com" <christian.koenig@amd.com>, "bharatku@xilinx.com" <bharatku@xilinx.com>, "rgummal@xilinx.com" <rgummal@xilinx.com>

Hi Sinan,

On 19/05/18 18:25, Sinan Kaya wrote:
> Nothing specific about this patch but just a general observation. Last time I
> looked at the code, it seemed to require both ATS and PRI support from a given
> hardware.
> 
> I think you can assume that for ATS 1.1 specification but ATS 1.0 specification
> allows a system to have ATS+PASID without PRI. 

As far as I know, the latest ATS spec also states that "device that
supports ATS need not support PRI". I'm referring to the version
integrated into PCIe v4.0r1.0, which I think corresponds to ATS 1.1.

> QDF2400 is ATS 1.0 compatible as an example. 
> 
> Is this an assumption / my misinterpretation?

In this series you can enable ATS and PASID without PRI. The SMMU
enables ATS and PASID in add_device() if supported. Then PRI is only
enabled if users request IOMMU_SVA_FEAT_IOPF in sva_init_device(). If
the device driver pins all DMA memory, it can use PASID without PRI.

Thanks,
Jean
