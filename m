Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id CEEAD6B0003
	for <linux-mm@kvack.org>; Fri, 25 May 2018 22:25:02 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id m15-v6so5343237qti.16
        for <linux-mm@kvack.org>; Fri, 25 May 2018 19:25:02 -0700 (PDT)
Received: from smtpbguseast2.qq.com (smtpbguseast2.qq.com. [54.204.34.130])
        by mx.google.com with ESMTPS id 24-v6si6570296qtu.74.2018.05.25.19.25.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 May 2018 19:25:01 -0700 (PDT)
Message-ID: <5b08c57d.1c69fb81.714d5.f65bSMTPIN_ADDED_BROKEN@mx.google.com>
Date: Sat, 26 May 2018 10:24:45 +0800
From: Kenneth Lee <Kenneth-Lee-2012@foxmail.com>
Subject: Re: [PATCH v2 03/40] iommu/sva: Manage process address spaces
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-4-jean-philippe.brucker@arm.com>
 <20180516163117.622693ea@jacob-builder>
 <de478769-9f7a-d40b-a55e-e2c63ad883e8@arm.com>
 <20180522094334.71f0e36b@jacob-builder>
 <f73b4a0e-669e-8483-88d7-1b2c8a2b9934@arm.com>
 <20180524115039.GA10260@apalos>
 <19e82a74-429a-3f86-119e-32b12082d0ff@arm.com>
 <20180525063311.GA11605@apalos>
 <20180525093959.000040a7@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180525093959.000040a7@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Cc: Ilias Apalodimas <ilias.apalodimas@linaro.org>, Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "xuzaibo@huawei.com" <xuzaibo@huawei.com>, Will Deacon <Will.Deacon@arm.com>, "okaya@codeaurora.org" <okaya@codeaurora.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "yi.l.liu@intel.com" <yi.l.liu@intel.com>, "ashok.raj@intel.com" <ashok.raj@intel.com>, "tn@semihalf.com" <tn@semihalf.com>, "joro@8bytes.org" <joro@8bytes.org>, "robdclark@gmail.com" <robdclark@gmail.com>, "bharatku@xilinx.com" <bharatku@xilinx.com>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "liudongdong3@huawei.com" <liudongdong3@huawei.com>, "rfranz@cavium.com" <rfranz@cavium.com>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "kevin.tian@intel.com" <kevin.tian@intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "rgummal@xilinx.com" <rgummal@xilinx.com>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "shunyong.yang@hxt-semitech.com" <shunyong.yang@hxt-semitech.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "liubo95@huawei.com" <liubo95@huawei.com>, "jcrouse@codeaurora.org" <jcrouse@codeaurora.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, Robin Murphy <Robin.Murphy@arm.com>, "christian.koenig@amd.com" <christian.koenig@amd.com>, "nwatters@codeaurora.org" <nwatters@codeaurora.org>, "baolu.lu@linux.intel.com" <baolu.lu@linux.intel.com>, liguozhu@hisilicon.com

On Fri, May 25, 2018 at 09:39:59AM +0100, Jonathan Cameron wrote:
> Date: Fri, 25 May 2018 09:39:59 +0100
> From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
> To: Ilias Apalodimas <ilias.apalodimas@linaro.org>
> CC: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>,
>  "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "kvm@vger.kernel.org"
>  <kvm@vger.kernel.org>, "linux-pci@vger.kernel.org"
>  <linux-pci@vger.kernel.org>, "xuzaibo@huawei.com" <xuzaibo@huawei.com>,
>  Will Deacon <Will.Deacon@arm.com>, "okaya@codeaurora.org"
>  <okaya@codeaurora.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
>  "yi.l.liu@intel.com" <yi.l.liu@intel.com>, "ashok.raj@intel.com"
>  <ashok.raj@intel.com>, "tn@semihalf.com" <tn@semihalf.com>,
>  "joro@8bytes.org" <joro@8bytes.org>, "robdclark@gmail.com"
>  <robdclark@gmail.com>, "bharatku@xilinx.com" <bharatku@xilinx.com>,
>  "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
>  "liudongdong3@huawei.com" <liudongdong3@huawei.com>, "rfranz@cavium.com"
>  <rfranz@cavium.com>, "devicetree@vger.kernel.org"
>  <devicetree@vger.kernel.org>, "kevin.tian@intel.com"
>  <kevin.tian@intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>,
>  "alex.williamson@redhat.com" <alex.williamson@redhat.com>,
>  "rgummal@xilinx.com" <rgummal@xilinx.com>, "thunder.leizhen@huawei.com"
>  <thunder.leizhen@huawei.com>, "linux-arm-kernel@lists.infradead.org"
>  <linux-arm-kernel@lists.infradead.org>, "shunyong.yang@hxt-semitech.com"
>  <shunyong.yang@hxt-semitech.com>, "dwmw2@infradead.org"
>  <dwmw2@infradead.org>, "liubo95@huawei.com" <liubo95@huawei.com>,
>  "jcrouse@codeaurora.org" <jcrouse@codeaurora.org>,
>  "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>,
>  Robin Murphy <Robin.Murphy@arm.com>, "christian.koenig@amd.com"
>  <christian.koenig@amd.com>, "nwatters@codeaurora.org"
>  <nwatters@codeaurora.org>, "baolu.lu@linux.intel.com"
>  <baolu.lu@linux.intel.com>, liguozhu@hisilicon.com,
>  kenneth-lee-2012@foxmail.com
> Subject: Re: [PATCH v2 03/40] iommu/sva: Manage process address spaces
> Message-ID: <20180525093959.000040a7@huawei.com>
> 
> +CC Kenneth Lee
> 
> On Fri, 25 May 2018 09:33:11 +0300
> Ilias Apalodimas <ilias.apalodimas@linaro.org> wrote:
> 
> > On Thu, May 24, 2018 at 04:04:39PM +0100, Jean-Philippe Brucker wrote:
> > > On 24/05/18 12:50, Ilias Apalodimas wrote:  
> > > >> Interesting, I hadn't thought about this use-case before. At first I
> > > >> thought you were talking about mdev devices assigned to VMs, but I think
> > > >> you're referring to mdevs assigned to userspace drivers instead? Out of
> > > >> curiosity, is it only theoretical or does someone actually need this?  
> > > > 
> > > > There has been some non upstreamed efforts to have mdev and produce userspace
> > > > drivers. Huawei is using it on what they call "wrapdrive" for crypto devices and
> > > > we did a proof of concept for ethernet interfaces. At the time we choose not to
> > > > involve the IOMMU for the reason you mentioned, but having it there would be
> > > > good.  
> > > 
> > > I'm guessing there were good reasons to do it that way but I wonder, is
> > > it not simpler to just have the kernel driver create a /dev/foo, with a
> > > standard ioctl/mmap/poll interface? Here VFIO adds a layer of
> > > indirection, and since the mediating driver has to implement these
> > > operations already, what is gained?  
> > The best reason i can come up with is "common code". You already have one API
> > doing that for you so we replicate it in a /dev file?
> > The mdev approach still needs extentions to support what we tried to do (i.e
> > mdev bus might need yo have access on iommu_ops), but as far as i undestand it's
> > a possible case.

Hi, Jean, Please allow me to share my understanding here:
https://zhuanlan.zhihu.com/p/35489035

The reason we do not use the /dev/foo scheme is that the devices to be
shared are programmable accelerators. We cannot fix up the kernel driver for them.
> > > 
> > > Thanks,
> > > Jean  
> 
> 

-- 
			-Kenneth Lee (Hisilicon)
