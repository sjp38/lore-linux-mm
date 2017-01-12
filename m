Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EC1526B0253
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 12:53:52 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c73so64958328pfb.7
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 09:53:52 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0062.outbound.protection.outlook.com. [104.47.0.62])
        by mx.google.com with ESMTPS id x3si9363371pfi.274.2017.01.12.09.53.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 09:53:52 -0800 (PST)
Subject: Re: [RFC PATCH 3/4] arch, mm: remove arch specific show_mem
References: <20170112131659.23058-1-mhocko@kernel.org>
 <20170112131659.23058-4-mhocko@kernel.org>
From: Chris Metcalf <cmetcalf@mellanox.com>
Message-ID: <283030f8-bcfa-2948-4461-26d09f4a5bb0@mellanox.com>
Date: Thu, 12 Jan 2017 12:53:37 -0500
MIME-Version: 1.0
In-Reply-To: <20170112131659.23058-4-mhocko@kernel.org>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "James E.J.
 Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, "David S.
 Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org

On 1/12/2017 8:16 AM, Michal Hocko wrote:
> From: Michal Hocko<mhocko@suse.com>
>
> We have a generic implementation for quite some time already. If there
> is any arch specific information to be printed then we should add a
> callback called from the generic code rather than duplicate the whole
> show_mem. The current code has resulted in the code duplication and
> the output divergence which is both confusing and adds maintainance
> costs. Let's just get rid of this mess.
>
> Cc: Tony Luck<tony.luck@intel.com>
> Cc: Fenghua Yu<fenghua.yu@intel.com>
> Cc: "James E.J. Bottomley"<jejb@parisc-linux.org>
> Cc: Helge Deller<deller@gmx.de>
> Cc: "David S. Miller"<davem@davemloft.net>
> Cc: Chris Metcalf<cmetcalf@mellanox.com>
> Cc: Guan Xuetao<gxt@mprc.pku.edu.cn>
> Cc:linux-ia64@vger.kernel.org
> Cc:linux-parisc@vger.kernel.org
> Signed-off-by: Michal Hocko<mhocko@suse.com>
> ---
>   arch/ia64/mm/init.c      | 48 -----------------------------------------------
>   arch/parisc/mm/init.c    | 49 ------------------------------------------------
>   arch/sparc/mm/init_32.c  | 11 -----------
>   arch/tile/mm/pgtable.c   | 45 --------------------------------------------
>   arch/unicore32/mm/init.c | 44 -------------------------------------------
>   5 files changed, 197 deletions(-)

Acked-by: Chris Metcalf <cmetcalf@mellanox.com> [for tile]

-- 
Chris Metcalf, Mellanox Technologies
http://www.mellanox.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
