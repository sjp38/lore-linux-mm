Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id EB6216B000A
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 17:23:43 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id w1-v6so1225899plq.8
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 14:23:43 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id u30-v6si9624395pfl.87.2018.07.23.14.23.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 14:23:42 -0700 (PDT)
Date: Mon, 23 Jul 2018 16:23:39 -0500
From: Richard Kuo <rkuo@codeaurora.org>
Subject: Re: [PATCH] hexagon: switch to NO_BOOTMEM
Message-ID: <20180723212339.GA12771@codeaurora.org>
References: <1531726998-10971-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1531726998-10971-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-hexagon@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


On Mon, Jul 16, 2018 at 10:43:18AM +0300, Mike Rapoport wrote:
> This patch adds registration of the system memory with memblock, eliminates
> bootmem initialization and converts early memory reservations from bootmem
> to memblock.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Sorry for the delay, and thanks for this patch.

I think the first memblock_reserve should use ARCH_PFN_OFFSET instead of
PHYS_OFFSET.

If you can amend that I'd be happy to take it through my tree or it can go
through any other.


Thanks,
Richard Kuo


-- 
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum, 
a Linux Foundation Collaborative Project
