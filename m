Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id B42EF6B786E
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 07:11:18 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id p14-v6so12549053oip.0
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 04:11:18 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b188-v6si3087921oif.246.2018.09.06.04.11.17
        for <linux-mm@kvack.org>;
        Thu, 06 Sep 2018 04:11:17 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: Re: [PATCH v2 04/40] iommu/sva: Add a mm_exit callback for device
 drivers
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
 <20180511190641.23008-5-jean-philippe.brucker@arm.com>
 <d1dc28c4-7742-9c41-3f91-3fbcb8b13c1c@redhat.com>
Message-ID: <27b964dc-68c4-3bb3-288c-166c25864e45@arm.com>
Date: Thu, 6 Sep 2018 12:10:58 +0100
MIME-Version: 1.0
In-Reply-To: <d1dc28c4-7742-9c41-3f91-3fbcb8b13c1c@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Auger Eric <eric.auger@redhat.com>, linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: xieyisheng1@huawei.com, liubo95@huawei.com, xuzaibo@huawei.com, thunder.leizhen@huawei.com, will.deacon@arm.com, okaya@codeaurora.org, yi.l.liu@intel.com, ashok.raj@intel.com, tn@semihalf.com, joro@8bytes.org, bharatku@xilinx.com, liudongdong3@huawei.com, rfranz@cavium.com, kevin.tian@intel.com, jacob.jun.pan@linux.intel.com, jcrouse@codeaurora.org, rgummal@xilinx.com, jonathan.cameron@huawei.com, shunyong.yang@hxt-semitech.com, robin.murphy@arm.com, ilias.apalodimas@linaro.org, alex.williamson@redhat.com, robdclark@gmail.com, dwmw2@infradead.org, christian.koenig@amd.com, nwatters@codeaurora.org, baolu.lu@linux.intel.com

On 05/09/2018 14:23, Auger Eric wrote:
>> + * If the driver intends to share process address spaces, it should pass a valid
>> + * @mm_exit handler. Otherwise @mm_exit can be NULL.
> I don't get case where mm_exit is allowed to be NULL.

Right, this comment is a bit premature. Next version adds a "private
PASID" patch to allocate private address spaces per PASID (modifiable
with map/unmap). That mode doesn't require mm_exit, and I can move the
comment there

Thanks,
Jean
