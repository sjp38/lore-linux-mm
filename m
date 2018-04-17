Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3FBA86B0007
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 15:54:56 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id b10so5881300wrf.3
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 12:54:56 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 5si1549525wri.252.2018.04.17.12.54.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 12:54:54 -0700 (PDT)
Date: Tue, 17 Apr 2018 21:55:29 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 01/12] iommu-common: move to arch/sparc
Message-ID: <20180417195529.GA31335@lst.de>
References: <20180415145947.1248-1-hch@lst.de> <20180415145947.1248-2-hch@lst.de> <f0305a92-b206-1567-3c25-67fbd194047d@linux.vnet.ibm.com> <20180416.095833.969403163564136309.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180416.095833.969403163564136309.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: khandual@linux.vnet.ibm.com, hch@lst.de, konrad.wilk@oracle.com, iommu@lists.linux-foundation.org, x86@kernel.org, linux-block@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-ide@vger.kernel.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Mon, Apr 16, 2018 at 09:58:33AM -0400, David Miller wrote:
> From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> Date: Mon, 16 Apr 2018 14:26:07 +0530
> 
> > On 04/15/2018 08:29 PM, Christoph Hellwig wrote:
> >> This code is only used by sparc, and all new iommu drivers should use the
> >> drivers/iommu/ framework.  Also remove the unused exports.
> >> 
> >> Signed-off-by: Christoph Hellwig <hch@lst.de>
> > 
> > Right, these functions are used only from SPARC architecture. Simple
> > git grep confirms it as well. Hence it makes sense to move them into
> > arch code instead.
> 
> Well, we put these into a common location and used type friendly for
> powerpc because we hoped powerpc would convert over to using this
> common piece of code as well.
> 
> But nobody did the powerpc work.
> 
> If you look at the powerpc iommu support, it's the same code basically
> for entry allocation.

I could also introduce a new config symbol and keep it in common code,
but it has been there for a while without any new user.

Right now it just means we built the code for everyone who selects
CONFIG_IOMMU_HELPER, which is just about anyone these days.
