Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5319E6B5A2E
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 22:23:31 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i68-v6so7851051pfb.9
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 19:23:31 -0700 (PDT)
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id w10-v6si11635782pfk.162.2018.08.31.19.23.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Aug 2018 19:23:30 -0700 (PDT)
Subject: Re: [PATCH v2 13/40] vfio: Add support for Shared Virtual Addressing
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-14-jean-philippe.brucker@arm.com>
 <5B83B11E.7010807@huawei.com> <1d5b6529-4e5a-723c-3f1b-dd5a9adb490c@arm.com>
From: Xu Zaibo <xuzaibo@huawei.com>
Message-ID: <5B89F818.7060300@huawei.com>
Date: Sat, 1 Sep 2018 10:23:20 +0800
MIME-Version: 1.0
In-Reply-To: <1d5b6529-4e5a-723c-3f1b-dd5a9adb490c@arm.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com, =?UTF-8?B?57Gz57Gz?= <kenneth-lee-2012@foxmail.com>, wangzhou1 <wangzhou1@hisilicon.com>, liguozhu <liguozhu@hisilicon.com>, fanghao11 <fanghao11@huawei.com>

Hi Jean,

On 2018/8/31 21:34, Jean-Philippe Brucker wrote:
> On 27/08/18 09:06, Xu Zaibo wrote:
>>> +struct vfio_iommu_type1_bind_process {
>>> +    __u32    flags;
>>> +#define VFIO_IOMMU_BIND_PID        (1 << 0)
>>> +    __u32    pasid;
>> As I am doing some works on the SVA patch set. I just consider why the
>> user space need this pasid.
>> Maybe, is it much more reasonable to set the pasid into all devices
>> under the vfio container by
>> a call back function from 'vfio_devices'  while
>> 'VFIO_IOMMU_BIND_PROCESS' CMD is executed
>> in kernel land? I am not sure because there exists no suitable call back
>> in 'vfio_device' at present.
> When using vfio-pci, the kernel doesn't know how to program the PASID
> into the device because the only kernel driver for the device is the
> generic vfio-pci module. The PCI specification doesn't describe a way of
> setting up the PASID, it's vendor-specific. Only the userspace
> application owning the device (and calling VFIO_IOMMU_BIND) knows how to
> do it, so we return the allocated PASID.
>
> Note that unlike vfio-mdev where applications share slices of a
> function, with vfio-pci one application owns the whole function so it's
> safe to let userspace set the PASID in hardware. With vfio-mdev it's the
> kernel driver that should be in charge of setting the PASID as you
> described, and we wouldn't have a reason to return the PASID in the
> vfio_iommu_type1_bind_process structure.
Understood. But I still get the following confusion:

As one application takes a whole function while using VFIO-PCI, why do 
the application and the
function need to enable PASID capability? (Since just one I/O page table 
is enough for them.)

Maybe I misunderstood, hope you can help me clear it. Thank you very much.

Thanks,
Zaibo

.
