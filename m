Date: Tue, 12 Feb 2008 01:00:06 -0800 (PST)
Message-Id: <20080212.010006.255202479.davem@davemloft.net>
Subject: Re: [PATCH]intel-iommu batched iotlb flushes
From: David Miller <davem@davemloft.net>
In-Reply-To: <20080212085256.GF5750@rhun.haifa.ibm.com>
References: <20080211224105.GB24412@linux.intel.com>
	<20080212085256.GF5750@rhun.haifa.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Muli Ben-Yehuda <muli@il.ibm.com>
Date: Tue, 12 Feb 2008 10:52:56 +0200
Return-Path: <owner-linux-mm@kvack.org>
To: muli@il.ibm.com
Cc: mgross@linux.intel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> The streaming DMA-API was designed to conserve IOMMU mappings for
> machines where IOMMU mappings are a scarce resource, and is a poor
> fit for a modern IOMMU such as VT-d with a 64-bit IO address space
> (or even an IOMMU with a 32-bit address space such as Calgary) where
> there are plenty of IOMMU mappings available.

For the 64-bit case what you are suggesting eventually amounts
to mapping all available RAM in the IOMMU.

Although an extreme version of your suggestion, it would be the
most efficient as it would require zero IOMMU flush operations.

But we'd lose things like protection and other benefits.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
