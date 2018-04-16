Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8AF7C6B0007
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:58:49 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id c4-v6so3381966oic.15
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 06:58:49 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTPS id m2-v6si4512869otd.326.2018.04.16.06.58.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 06:58:48 -0700 (PDT)
Date: Mon, 16 Apr 2018 09:58:33 -0400 (EDT)
Message-Id: <20180416.095833.969403163564136309.davem@davemloft.net>
Subject: Re: [PATCH 01/12] iommu-common: move to arch/sparc
From: David Miller <davem@davemloft.net>
In-Reply-To: <f0305a92-b206-1567-3c25-67fbd194047d@linux.vnet.ibm.com>
References: <20180415145947.1248-1-hch@lst.de>
	<20180415145947.1248-2-hch@lst.de>
	<f0305a92-b206-1567-3c25-67fbd194047d@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: khandual@linux.vnet.ibm.com
Cc: hch@lst.de, konrad.wilk@oracle.com, iommu@lists.linux-foundation.org, x86@kernel.org, linux-block@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-ide@vger.kernel.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 16 Apr 2018 14:26:07 +0530

> On 04/15/2018 08:29 PM, Christoph Hellwig wrote:
>> This code is only used by sparc, and all new iommu drivers should use the
>> drivers/iommu/ framework.  Also remove the unused exports.
>> 
>> Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> Right, these functions are used only from SPARC architecture. Simple
> git grep confirms it as well. Hence it makes sense to move them into
> arch code instead.

Well, we put these into a common location and used type friendly for
powerpc because we hoped powerpc would convert over to using this
common piece of code as well.

But nobody did the powerpc work.

If you look at the powerpc iommu support, it's the same code basically
for entry allocation.
