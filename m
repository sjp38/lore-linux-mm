Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id A73A66B0003
	for <linux-mm@kvack.org>; Sun, 15 Apr 2018 17:53:00 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id a1-v6so1955932lfa.16
        for <linux-mm@kvack.org>; Sun, 15 Apr 2018 14:53:00 -0700 (PDT)
Received: from asavdk3.altibox.net (asavdk3.altibox.net. [109.247.116.14])
        by mx.google.com with ESMTPS id c83-v6si1267997lfh.387.2018.04.15.14.52.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Apr 2018 14:52:58 -0700 (PDT)
Date: Sun, 15 Apr 2018 23:52:54 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH 02/12] iommu-helper: unexport iommu_area_alloc
Message-ID: <20180415215254.GA32231@ravnborg.org>
References: <20180415145947.1248-1-hch@lst.de>
 <20180415145947.1248-3-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180415145947.1248-3-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org, x86@kernel.org, linux-block@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-ide@vger.kernel.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Sun, Apr 15, 2018 at 04:59:37PM +0200, Christoph Hellwig wrote:
> This function is only used by built-in code.
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by:....

	Sam
