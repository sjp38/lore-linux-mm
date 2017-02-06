Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7D06B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 08:36:28 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id h10so79218613ith.2
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 05:36:28 -0800 (PST)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0050.outbound.protection.outlook.com. [104.47.41.50])
        by mx.google.com with ESMTPS id f13si9164814iod.99.2017.02.06.05.36.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 06 Feb 2017 05:36:27 -0800 (PST)
Date: Mon, 6 Feb 2017 14:36:11 +0100
From: Robert Richter <robert.richter@cavium.com>
Subject: Re: [PATCH 2/2] arm64: mm: enable CONFIG_HOLES_IN_ZONE for NUMA
Message-ID: <20170206133611.GL16822@rric.localdomain>
References: <1481706707-6211-1-git-send-email-ard.biesheuvel@linaro.org>
 <1481706707-6211-3-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1481706707-6211-3-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, will.deacon@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, catalin.marinas@arm.com, akpm@linux-foundation.org, hanjun.guo@linaro.org, xieyisheng1@huawei.com, james.morse@arm.com

On 14.12.16 09:11:47, Ard Biesheuvel wrote:
> The NUMA code may get confused by the presence of NOMAP regions within
> zones, resulting in spurious BUG() checks where the node id deviates
> from the containing zone's node id.
> 
> Since the kernel has no business reasoning about node ids of pages it
> does not own in the first place, enable CONFIG_HOLES_IN_ZONE to ensure
> that such pages are disregarded.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

I would rather see a solution other than making pfn_valid checks more
fine grained, but this patch also fixes the issue. So:

Acked-by: Robert Richter <rrichter@cavium.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
