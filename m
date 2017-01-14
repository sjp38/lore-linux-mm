Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8087F6B0033
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 11:29:32 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id d140so21596447wmd.4
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 08:29:32 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l2si15278480wrc.6.2017.01.14.08.29.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jan 2017 08:29:31 -0800 (PST)
Date: Sat, 14 Jan 2017 11:29:15 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 3/4] arch, mm: remove arch specific show_mem
Message-ID: <20170114162915.GF26139@cmpxchg.org>
References: <20170112131659.23058-1-mhocko@kernel.org>
 <20170112131659.23058-4-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170112131659.23058-4-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@mellanox.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org

On Thu, Jan 12, 2017 at 02:16:58PM +0100, Michal Hocko wrote:
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

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
