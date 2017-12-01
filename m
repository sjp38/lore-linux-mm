Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 51B276B025F
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 03:04:13 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id d4so4088054plr.8
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 00:04:13 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 32si4620160plg.75.2017.12.01.00.04.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Dec 2017 00:04:12 -0800 (PST)
Message-ID: <5A210D6D.3090402@intel.com>
Date: Fri, 01 Dec 2017 16:06:05 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v18 06/10] virtio_ring: add a new API, virtqueue_add_one_desc
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com> <1511963726-34070-7-git-send-email-wei.w.wang@intel.com> <20171130213231-mutt-send-email-mst@kernel.org>
In-Reply-To: <20171130213231-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

On 12/01/2017 03:38 AM, Michael S. Tsirkin wrote:
> On Wed, Nov 29, 2017 at 09:55:22PM +0800, Wei Wang wrote:
>> Current virtqueue_add API implementation is based on the scatterlist
>> struct, which uses kaddr. This is inadequate to all the use case of
>> vring. For example:
>> - Some usages don't use IOMMU, in this case the user can directly pass
>>    in a physical address in hand, instead of going through the sg
>>    implementation (e.g. the VIRTIO_BALLOON_F_SG feature)
>> - Sometimes, a guest physical page may not have a kaddr (e.g. high
>>    memory) but need to use vring (e.g. the VIRTIO_BALLOON_F_FREE_PAGE_VQ
>>    feature)
>>
>> The new API virtqueue_add_one_desc enables the caller to assign a vring
>> desc with a physical address and len. Also, factor out the common code
>> with virtqueue_add in vring_set_avail.
>>
>> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
>> Cc: Michael S. Tsirkin <mst@redhat.com>
> You previously managed without this patch, and it's preferable
> IMHO since this patchset is already too big.
>
> I don't really understand what is wrong with virtio_add_sgs + sg_set_page.
> I don't think is assumes a kaddr.
>

OK, I will use the previous method to send sgs.
Please have a check if there are other things need to be improved.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
