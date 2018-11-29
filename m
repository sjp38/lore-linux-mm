Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id A98406B539F
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 12:02:08 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id 132so2121593wms.3
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 09:02:08 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id d206si2256953wmf.57.2018.11.29.09.02.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 09:02:07 -0800 (PST)
Date: Thu, 29 Nov 2018 18:02:06 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20181129170206.GA27951@lst.de>
References: <20181114082314.8965-1-hch@lst.de> <20181127074253.GB30186@lst.de> <87zhttfonk.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87zhttfonk.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Christoph Hellwig <hch@lst.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Wed, Nov 28, 2018 at 10:05:19PM +1100, Michael Ellerman wrote:
> Is the plan that you take these via the dma-mapping tree or that they go
> via powerpc?

In principle either way is fine with me.  If it goes through the powerpc
tree we might run into a few minor conflicts with the dma-mapping tree
depending on how some of the current discussions go.
