Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1C48F6B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 21:56:35 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id q20so49380828ioi.0
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 18:56:35 -0800 (PST)
Received: from mprc.pku.edu.cn (mprc.pku.edu.cn. [162.105.203.9])
        by mx.google.com with ESMTPS id b141si9909074ioa.77.2017.01.12.18.56.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 18:56:32 -0800 (PST)
Message-ID: <15923.175.43.247.167.1484275786.squirrel@mprc.pku.edu.cn>
In-Reply-To: <20170112131659.23058-4-mhocko@kernel.org>
References: <20170112131659.23058-1-mhocko@kernel.org>
    <20170112131659.23058-4-mhocko@kernel.org>
Date: Fri, 13 Jan 2017 10:49:46 +0800 (CST)
Subject: Re: [RFC PATCH 3/4] arch, mm: remove arch specific show_mem
From: "Xuetao Guan" <gxt@mprc.pku.edu.cn>
Reply-To: gxt@mprc.pku.edu.cn
MIME-Version: 1.0
Content-Type: text/plain;charset=gb2312
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@mellanox.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org

> From: Michal Hocko <mhocko@suse.com>
>
> We have a generic implementation for quite some time already. If there
> is any arch specific information to be printed then we should add a
> callback called from the generic code rather than duplicate the whole
> show_mem. The current code has resulted in the code duplication and
> the output divergence which is both confusing and adds maintainance
> costs. Let's just get rid of this mess.
>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
> Cc: Helge Deller <deller@gmx.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Chris Metcalf <cmetcalf@mellanox.com>
> Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
> Cc: linux-ia64@vger.kernel.org
> Cc: linux-parisc@vger.kernel.org
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  arch/ia64/mm/init.c      | 48
> -----------------------------------------------
>  arch/parisc/mm/init.c    | 49
> ------------------------------------------------
>  arch/sparc/mm/init_32.c  | 11 -----------
>  arch/tile/mm/pgtable.c   | 45
> --------------------------------------------
>  arch/unicore32/mm/init.c | 44 -------------------------------------------
>  5 files changed, 197 deletions(-)

For UniCore32:
Acked-by: Guan Xuetao <gxt@mprc.pku.edu.cn>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
