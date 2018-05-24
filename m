Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF156B0266
	for <linux-mm@kvack.org>; Thu, 24 May 2018 11:04:53 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id c6-v6so1093757otk.9
        for <linux-mm@kvack.org>; Thu, 24 May 2018 08:04:53 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y32-v6si7149187ota.409.2018.05.24.08.04.51
        for <linux-mm@kvack.org>;
        Thu, 24 May 2018 08:04:52 -0700 (PDT)
Subject: Re: [PATCH v2 03/40] iommu/sva: Manage process address spaces
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-4-jean-philippe.brucker@arm.com>
 <20180516163117.622693ea@jacob-builder>
 <de478769-9f7a-d40b-a55e-e2c63ad883e8@arm.com>
 <20180522094334.71f0e36b@jacob-builder>
 <f73b4a0e-669e-8483-88d7-1b2c8a2b9934@arm.com>
 <20180524115039.GA10260@apalos>
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Message-ID: <19e82a74-429a-3f86-119e-32b12082d0ff@arm.com>
Date: Thu, 24 May 2018 16:04:39 +0100
MIME-Version: 1.0
In-Reply-To: <20180524115039.GA10260@apalos>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ilias Apalodimas <ilias.apalodimas@linaro.org>
Cc: "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "xuzaibo@huawei.com" <xuzaibo@huawei.com>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, Will Deacon <Will.Deacon@arm.com>, "okaya@codeaurora.org" <okaya@codeaurora.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "yi.l.liu@intel.com" <yi.l.liu@intel.com>, "ashok.raj@intel.com" <ashok.raj@intel.com>, "tn@semihalf.com" <tn@semihalf.com>, "joro@8bytes.org" <joro@8bytes.org>, "robdclark@gmail.com" <robdclark@gmail.com>, "bharatku@xilinx.com" <bharatku@xilinx.com>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "liudongdong3@huawei.com" <liudongdong3@huawei.com>, "rfranz@cavium.com" <rfranz@cavium.com>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "kevin.tian@intel.com" <kevin.tian@intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "rgummal@xilinx.com" <rgummal@xilinx.com>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "shunyong.yang@hxt-semitech.com" <shunyong.yang@hxt-semitech.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "liubo95@huawei.com" <liubo95@huawei.com>, "jcrouse@codeaurora.org" <jcrouse@codeaurora.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, Robin Murphy <Robin.Murphy@arm.com>, "christian.koenig@amd.com" <christian.koenig@amd.com>, "nwatters@codeaurora.org" <nwatters@codeaurora.org>, "baolu.lu@linux.intel.com" <baolu.lu@linux.intel.com>

On 24/05/18 12:50, Ilias Apalodimas wrote:
>> Interesting, I hadn't thought about this use-case before. At first I
>> thought you were talking about mdev devices assigned to VMs, but I think
>> you're referring to mdevs assigned to userspace drivers instead? Out of
>> curiosity, is it only theoretical or does someone actually need this?
> 
> There has been some non upstreamed efforts to have mdev and produce userspace
> drivers. Huawei is using it on what they call "wrapdrive" for crypto devices and
> we did a proof of concept for ethernet interfaces. At the time we choose not to
> involve the IOMMU for the reason you mentioned, but having it there would be
> good.

I'm guessing there were good reasons to do it that way but I wonder, is
it not simpler to just have the kernel driver create a /dev/foo, with a
standard ioctl/mmap/poll interface? Here VFIO adds a layer of
indirection, and since the mediating driver has to implement these
operations already, what is gained?

Thanks,
Jean
