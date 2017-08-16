Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D8C616B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 05:30:33 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 16so56313229pgg.8
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 02:30:33 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id t25si253344pfi.492.2017.08.16.02.30.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 02:30:32 -0700 (PDT)
Message-ID: <59941160.9050403@intel.com>
Date: Wed, 16 Aug 2017 17:33:20 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [virtio-dev] [PATCH v13 0/5] Virtio-balloon Enhancement
References: <1501742299-4369-1-git-send-email-wei.w.wang@intel.com> <20170816055704.GB21088@shay3t003839711.china.huawei.com>
In-Reply-To: <20170816055704.GB21088@shay3t003839711.china.huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Adam Tao <taozhe1@huawei.com>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, mawilcox@microsoft.com, akpm@linux-foundation.org, virtio-dev@lists.oasis-open.org, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On 08/16/2017 01:57 PM, Adam Tao wrote:
> On Thu, Aug 03, 2017 at 02:38:14PM +0800, Wei Wang wrote:
>> This patch series enhances the existing virtio-balloon with the following
>> new features:
>> 1) fast ballooning: transfer ballooned pages between the guest and host in
>> chunks using sgs, instead of one by one; and
>> 2) free_page_vq: a new virtqueue to report guest free pages to the host.
>>
> Hi wei,
> The reason we add the new vq for the migration feature is based on
> what(original design based on inflate and deflate vq)?
> I am wondering if we add new feature in the future do we still need to add new type
> of vq?
> Do we need to add one command queue for the common purpose(including
> different type of requests except the in/deflate ones)?
> Thanks
> Adam

Hi Adam,

The the free_page_vq is added to report free pages to the hypervisor.
Neither inflate nor deflate vq was for this purpose.

Based on the current implementation, a vq dedicated to one usage (i.e. 
report
free pages) is better, since mixing with other usages, e.g. a command vq to
handle multiple commands at the same time, would have some issues (e.g. one
being delayed by another due to some resource control), and it also 
results in
more complex interfaces between the driver and device.

For future usages which are still unknown at present, I think we can discuss
them case by case in the future.

Best,
Wei


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
