Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id AA60F6B6765
	for <linux-mm@kvack.org>; Mon,  3 Sep 2018 06:34:50 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id l191-v6so60578oig.23
        for <linux-mm@kvack.org>; Mon, 03 Sep 2018 03:34:50 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d187-v6si13420985oib.105.2018.09.03.03.34.49
        for <linux-mm@kvack.org>;
        Mon, 03 Sep 2018 03:34:49 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: Re: [PATCH v2 13/40] vfio: Add support for Shared Virtual Addressing
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-14-jean-philippe.brucker@arm.com>
 <5B83B11E.7010807@huawei.com> <1d5b6529-4e5a-723c-3f1b-dd5a9adb490c@arm.com>
 <5B89F818.7060300@huawei.com>
Message-ID: <3a961aff-e830-64bb-b6a9-14e08de1abf5@arm.com>
Date: Mon, 3 Sep 2018 11:34:29 +0100
MIME-Version: 1.0
In-Reply-To: <5B89F818.7060300@huawei.com>
Content-Type: text/plain; charset=iso-2022-jp
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xu Zaibo <xuzaibo@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "joro@8bytes.org" <joro@8bytes.org>, Will Deacon <Will.Deacon@arm.com>, Robin Murphy <Robin.Murphy@arm.com>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "tn@semihalf.com" <tn@semihalf.com>, "liubo95@huawei.com" <liubo95@huawei.com>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "ilias.apalodimas@linaro.org" <ilias.apalodimas@linaro.org>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, "liudongdong3@huawei.com" <liudongdong3@huawei.com>, "shunyong.yang@hxt-semitech.com" <shunyong.yang@hxt-semitech.com>, "nwatters@codeaurora.org" <nwatters@codeaurora.org>, "okaya@codeaurora.org" <okaya@codeaurora.org>, "jcrouse@codeaurora.org" <jcrouse@codeaurora.org>, "rfranz@cavium.com" <rfranz@cavium.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "jacob.jun.pan@linux.intel.com" <jacob.jun.pan@linux.intel.com>, "yi.l.liu@intel.com" <yi.l.liu@intel.com>, "ashok.raj@intel.com" <ashok.raj@intel.com>, "kevin.tian@intel.com" <kevin.tian@intel.com>, "baolu.lu@linux.intel.com" <baolu.lu@linux.intel.com>, "robdclark@gmail.com" <robdclark@gmail.com>, "christian.koenig@amd.com" <christian.koenig@amd.com>, "bharatku@xilinx.com" <bharatku@xilinx.com>, "rgummal@xilinx.com" <rgummal@xilinx.com>, =?UTF-8?B?57Gz57Gz?= <kenneth-lee-2012@foxmail.com>, wangzhou1 <wangzhou1@hisilicon.com>, "liguozhu@hisilicon.com" <liguozhu@hisilicon.com>, fanghao11 <fanghao11@huawei.com>

On 01/09/18 03:23, Xu Zaibo wrote:
> As one application takes a whole function while using VFIO-PCI, why do 
> the application and the
> function need to enable PASID capability? (Since just one I/O page table 
> is enough for them.)

At the moment the series doesn't provide support for SVA without PASID
(on the I/O page fault path, 08/40). In addition the BIND ioctl could be
used by the owner application to bind other processes (slaves) and
perform sub-assignment. But that feature is incomplete because we don't
send stop_pasid notification to the owner when a slave dies.

Thanks,
Jean
