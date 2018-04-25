Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id B69546B000C
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 10:58:25 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id r104-v6so10288469ota.19
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 07:58:25 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTPS id 5-v6si99363oip.45.2018.04.25.07.58.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Apr 2018 07:58:24 -0700 (PDT)
Date: Wed, 25 Apr 2018 10:58:20 -0400 (EDT)
Message-Id: <20180425.105820.1294383479112934639.davem@davemloft.net>
Subject: Re: [PATCH 01/13] iommu-common: move to arch/sparc
From: David Miller <davem@davemloft.net>
In-Reply-To: <20180425051539.1989-2-hch@lst.de>
References: <20180425051539.1989-1-hch@lst.de>
	<20180425051539.1989-2-hch@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hch@lst.de
Cc: konrad.wilk@oracle.com, iommu@lists.linux-foundation.org, sstabellini@kernel.org, x86@kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

From: Christoph Hellwig <hch@lst.de>
Date: Wed, 25 Apr 2018 07:15:27 +0200

> This code is only used by sparc, and all new iommu drivers should use the
> drivers/iommu/ framework.  Also remove the unused exports.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

Acked-by: David S. Miller <davem@davemloft.net>
