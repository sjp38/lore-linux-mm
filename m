Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A77426B0003
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 21:45:02 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id r20-v6so67711pgv.20
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 18:45:02 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id l185-v6si29187pfl.134.2018.07.25.18.45.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 18:45:00 -0700 (PDT)
Date: Wed, 25 Jul 2018 20:44:57 -0500
From: Richard Kuo <rkuo@codeaurora.org>
Subject: Re: [PATCH v2] hexagon: switch to NO_BOOTMEM
Message-ID: <20180726014457.GH12771@codeaurora.org>
References: <1532496594-26353-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1532496594-26353-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-hexagon@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 25, 2018 at 08:29:54AM +0300, Mike Rapoport wrote:
> This patch adds registration of the system memory with memblock, eliminates
> bootmem initialization and converts early memory reservations from bootmem
> to memblock.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
> v2: fix calculation of the reserved memory size
> 
>  arch/hexagon/Kconfig   |  3 +++
>  arch/hexagon/mm/init.c | 20 ++++++++------------
>  2 files changed, 11 insertions(+), 12 deletions(-)
> 

Looks good, I can take this through my tree.


Acked-by: Richard Kuo <rkuo@codeaurora.org>

-- 
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum, 
a Linux Foundation Collaborative Project
