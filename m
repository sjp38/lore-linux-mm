Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 792086B004D
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 03:53:49 -0500 (EST)
Date: Thu, 18 Feb 2010 08:53:36 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Kernel panic due to page migration accessing memory holes
Message-ID: <20100218085336.GB848@n2100.arm.linux.org.uk>
References: <4B7C8DC2.3060004@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B7C8DC2.3060004@codeaurora.org>
Sender: owner-linux-mm@kvack.org
To: Michael Bohan <mbohan@codeaurora.org>
Cc: linux-mm@kvack.org, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 17, 2010 at 04:45:54PM -0800, Michael Bohan wrote:
> I have encountered a kernel panic on the ARM/msm platform in the mm  
> migration code on 2.6.29.  My memory configuration has two discontiguous  
> banks per our ATAG definition.   These banks end up on addresses that  
> are 1 MB aligned.  I am using FLATMEM (not SPARSEMEM), but my  
> understanding is that SPARSEMEM should not be necessary to support this  
> configuration.  Please correct me if I'm wrong.

Make sure you have ARCH_HAS_HOLES_MEMORYMODEL enabled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
