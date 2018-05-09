Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B0A866B032E
	for <linux-mm@kvack.org>; Wed,  9 May 2018 00:59:39 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k16-v6so23041610wrh.6
        for <linux-mm@kvack.org>; Tue, 08 May 2018 21:59:39 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 48-v6si23968176wru.268.2018.05.08.21.59.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 21:59:38 -0700 (PDT)
Date: Wed, 9 May 2018 07:03:06 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: centralize SWIOTLB config symbol and misc other cleanups V3
Message-ID: <20180509050306.GA18336@lst.de>
References: <20180425051539.1989-1-hch@lst.de> <20180502124617.GA22001@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180502124617.GA22001@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Christoph Hellwig <hch@lst.de>, linux-mips@linux-mips.org, sstabellini@kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-pci@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Wed, May 02, 2018 at 05:46:17AM -0700, Christoph Hellwig wrote:
> Any more comments?  Especially from the x86, mips and powerpc arch
> maintainers?  I'd like to merge this in a few days as various other
> patches depend on it.

I've pulled it in to make forward progress.  Any additional comments
will have to be sent in the form of incremental patches.
