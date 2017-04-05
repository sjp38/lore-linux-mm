Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B46B86B03B7
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 07:36:27 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id m33so1200051wrm.23
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 04:36:27 -0700 (PDT)
Received: from radon.swed.at (b.ns.miles-group.at. [95.130.255.144])
        by mx.google.com with ESMTPS id t24si28783023wra.71.2017.04.05.04.36.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Apr 2017 04:36:26 -0700 (PDT)
Subject: Re: [PATCH 4/4] mtd: nand: nandsim: convert to memalloc_noreclaim_*()
References: <20170405074700.29871-1-vbabka@suse.cz>
 <20170405074700.29871-5-vbabka@suse.cz>
 <20170405113157.GM6035@dhcp22.suse.cz>
From: Richard Weinberger <richard@nod.at>
Message-ID: <ee6649ed-b0e8-1c59-c193-d1688fdfe7f5@nod.at>
Date: Wed, 5 Apr 2017 13:36:22 +0200
MIME-Version: 1.0
In-Reply-To: <20170405113157.GM6035@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-block@vger.kernel.org, nbd-general@lists.sourceforge.net, open-iscsi@googlegroups.com, linux-scsi@vger.kernel.org, netdev@vger.kernel.org, Boris Brezillon <boris.brezillon@free-electrons.com>, Adrian Hunter <adrian.hunter@intel.com>

Michal,

Am 05.04.2017 um 13:31 schrieb Michal Hocko:
> On Wed 05-04-17 09:47:00, Vlastimil Babka wrote:
>> Nandsim has own functions set_memalloc() and clear_memalloc() for robust
>> setting and clearing of PF_MEMALLOC. Replace them by the new generic helpers.
>> No functional change.
> 
> This one smells like an abuser. Why the hell should read/write path
> touch memory reserves at all!

Could be. Let's ask Adrian, AFAIK he wrote that code.
Adrian, can you please clarify why nandsim needs to play with PF_MEMALLOC?

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
