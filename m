Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D29CE6B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 14:15:25 -0400 (EDT)
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
From: Daniel Walker <dwalker@codeaurora.org>
In-Reply-To: <adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com>
References: <cover.1279639238.git.m.nazarewicz@samsung.com>
	 <d6d104950c1391eaf3614d56615617cee5722fb4.1279639238.git.m.nazarewicz@samsung.com>
	 <adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 20 Jul 2010 11:15:24 -0700
Message-ID: <1279649724.26765.23.camel@c-dwalke-linux.qualcomm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <m.nazarewicz@samsung.com>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Pawel Osciak <p.osciak@samsung.com>, Xiaolin Zhang <xiaolin.zhang@intel.com>, Hiremath Vaibhav <hvaibhav@ti.com>, Robert Fekete <robert.fekete@stericsson.com>, Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2010-07-20 at 17:51 +0200, Michal Nazarewicz wrote:
> +** Use cases
> +
> +    Lets analyse some imaginary system that uses the CMA to see how
> +    the framework can be used and configured.
> +
> +
> +    We have a platform with a hardware video decoder and a camera
> each
> +    needing 20 MiB of memory in worst case.  Our system is written in
> +    such a way though that the two devices are never used at the same
> +    time and memory for them may be shared.  In such a system the
> +    following two command line arguments would be used:
> +
> +        cma=r=20M cma_map=video,camera=r 

This seems inelegant to me.. It seems like these should be connected
with the drivers themselves vs. doing it on the command like for
everything. You could have the video driver declare it needs 20megs, and
the the camera does the same but both indicate it's shared ..

If you have this disconnected from the drivers it will just cause
confusion, since few will know what these parameters should be for a
given driver set. It needs to be embedded in the kernel.

Daniel

-- 
Sent by an consultant of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
