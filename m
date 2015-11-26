Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 009EF6B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 20:55:44 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so74130526pac.3
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 17:55:44 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id to8si4931990pab.76.2015.11.25.17.55.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 25 Nov 2015 17:55:44 -0800 (PST)
Date: Thu, 26 Nov 2015 10:56:12 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm/vmstat: retrieve more accurate vmstat value
Message-ID: <20151126015612.GB13138@js1304-P5Q-DELUXE>
References: <1448346123-2699-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20151125120021.GA27342@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151125120021.GA27342@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org

On Wed, Nov 25, 2015 at 01:00:22PM +0100, Michal Hocko wrote:
> On Tue 24-11-15 15:22:03, Joonsoo Kim wrote:
> > When I tested compaction in low memory condition, I found that
> > my benchmark is stuck in congestion_wait() at shrink_inactive_list().
> > This stuck last for 1 sec and after then it can escape. More investigation
> > shows that it is due to stale vmstat value. vmstat is updated every 1 sec
> > so it is stuck for 1 sec.
> 
> Wouldn't it be sufficient to use zone_page_state_snapshot in
> too_many_isolated?

Yes, it would work in this case. But, I prefer this patch because
all zone_page_state() users get this benefit.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
