Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EF7556B0003
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 08:24:02 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c26-v6so460942eda.7
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 05:24:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s9-v6si730930ejq.181.2018.10.01.05.24.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 05:24:01 -0700 (PDT)
Date: Mon, 1 Oct 2018 14:24:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Avoid swapping in interrupt context
Message-ID: <20181001122400.GF18290@dhcp22.suse.cz>
References: <1538387115-2363-1-git-send-email-amhetre@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1538387115-2363-1-git-send-email-amhetre@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ashish Mhetre <amhetre@nvidia.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, vdumpa@nvidia.com, Snikam@nvidia.com, Sri Krishna chowdary <schowdary@nvidia.com>

On Mon 01-10-18 15:15:15, Ashish Mhetre wrote:
> From: Sri Krishna chowdary <schowdary@nvidia.com>
> 
> Pages can be swapped out from interrupt context as well.

How? No allocation request from the interrupt context can use a
sleepable allocation context and that means that no reclaim is allowed
from the IRQ context.

> ZRAM uses zsmalloc allocator to make room for these pages.
> But zsmalloc is not made to be used from interrupt context.
> This can result in a kernel Oops.

Could you provide the Oops message?
-- 
Michal Hocko
SUSE Labs
