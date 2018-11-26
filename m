Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id E74496B40A9
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 01:45:08 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id t184so9705468oih.22
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 22:45:08 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o62si8495314oif.67.2018.11.25.22.45.07
        for <linux-mm@kvack.org>;
        Sun, 25 Nov 2018 22:45:07 -0800 (PST)
Subject: Re: [PATCH] mm: Replace all open encodings for NUMA_NO_NODE
References: <1542966856-12619-1-git-send-email-anshuman.khandual@arm.com>
 <20181124140554.GG3175@vkoul-mobl.Dlink>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <5228bcdb-b140-a86a-6c9c-488f1a723353@arm.com>
Date: Mon, 26 Nov 2018 12:15:04 +0530
MIME-Version: 1.0
In-Reply-To: <20181124140554.GG3175@vkoul-mobl.Dlink>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinod Koul <vkoul@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-media@vger.kernel.org, iommu@lists.linux-foundation.org, linux-rdma@vger.kernel.org, dmaengine@vger.kernel.org, linux-block@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-alpha@vger.kernel.org, akpm@linux-foundation.org, jiangqi903@gmail.com, hverkuil@xs4all.nl



On 11/24/2018 07:35 PM, Vinod Koul wrote:
> On 23-11-18, 15:24, Anshuman Khandual wrote:
> 
>> --- a/drivers/dma/dmaengine.c
>> +++ b/drivers/dma/dmaengine.c
>> @@ -386,7 +386,8 @@ EXPORT_SYMBOL(dma_issue_pending_all);
>>  static bool dma_chan_is_local(struct dma_chan *chan, int cpu)
>>  {
>>  	int node = dev_to_node(chan->device->dev);
>> -	return node == -1 || cpumask_test_cpu(cpu, cpumask_of_node(node));
>> +	return node == NUMA_NO_NODE ||
>> +		cpumask_test_cpu(cpu, cpumask_of_node(node));
>>  }
> 
> I do not see dev_to_node being updated first, that returns -1 so I would
> prefer to check for -1 unless it return NUMA_NO_NODE

Sure will update dev_to_node() to return NUMA_NO_NODE as well.
