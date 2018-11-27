Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 152226B4846
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:58:21 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id h10so23835941plk.12
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 05:58:21 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k64si3792431pge.7.2018.11.27.05.58.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 05:58:19 -0800 (PST)
Date: Tue, 27 Nov 2018 19:28:09 +0530
From: Vinod Koul <vkoul@kernel.org>
Subject: Re: [PATCH V2] mm: Replace all open encodings for NUMA_NO_NODE
Message-ID: <20181127135809.GB3175@vkoul-mobl.Dlink>
References: <1543235202-9075-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1543235202-9075-1-git-send-email-anshuman.khandual@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-media@vger.kernel.org, iommu@lists.linux-foundation.org, linux-rdma@vger.kernel.org, dmaengine@vger.kernel.org, linux-block@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-alpha@vger.kernel.org, akpm@linux-foundation.org, jiangqi903@gmail.com, hverkuil@xs4all.nl

On 26-11-18, 17:56, Anshuman Khandual wrote:
> At present there are multiple places where invalid node number is encoded
> as -1. Even though implicitly understood it is always better to have macros
> in there. Replace these open encodings for an invalid node number with the
> global macro NUMA_NO_NODE. This helps remove NUMA related assumptions like
> 'invalid node' from various places redirecting them to a common definition.
> 

>  drivers/dma/dmaengine.c                       |  4 +++-


Acked-by: Vinod Koul <vkoul@kernel.org>

-- 
~Vinod
