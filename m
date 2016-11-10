Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id F319B6B02BF
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 13:40:17 -0500 (EST)
Received: by mail-pa0-f69.google.com with SMTP id kr7so24200269pab.5
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 10:40:17 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id vz10si5257909pab.271.2016.11.10.10.40.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 10:40:17 -0800 (PST)
Date: Thu, 10 Nov 2016 12:40:14 -0600
From: Richard Kuo <rkuo@codeaurora.org>
Subject: Re: [mm PATCH v3 07/23] arch/hexagon: Add option to skip DMA sync as
 a part of mapping
Message-ID: <20161110184014.GA30680@codeaurora.org>
References: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
 <20161110113452.76501.45864.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161110113452.76501.45864.stgit@ahduyck-blue-test.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-hexagon@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Nov 10, 2016 at 06:34:52AM -0500, Alexander Duyck wrote:
> This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
> avoid invoking cache line invalidation if the driver will just handle it
> later via a sync_for_cpu or sync_for_device call.
> 
> Cc: Richard Kuo <rkuo@codeaurora.org>
> Cc: linux-hexagon@vger.kernel.org
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>  arch/hexagon/kernel/dma.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 

For Hexagon:

Acked-by: Richard Kuo <rkuo@codeaurora.org>



-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum, 
a Linux Foundation Collaborative Project

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
