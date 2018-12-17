Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E16088E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 11:03:54 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id u17so10942267pgn.17
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 08:03:54 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o127si12271100pfo.251.2018.12.17.08.03.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:03:53 -0800 (PST)
Date: Mon, 17 Dec 2018 17:03:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [-next] lots of messages due to "mm, memory_hotplug: be more
 verbose for memory offline failures"
Message-ID: <20181217160350.GV30879@dhcp22.suse.cz>
References: <20181217155922.GC3560@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181217155922.GC3560@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <osalvador@suse.de>, Anshuman Khandual <anshuman.khandual@arm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-next@vger.kernel.org, linux-s390@vger.kernel.org

On Mon 17-12-18 16:59:22, Heiko Carstens wrote:
> Hi Michal,
> 
> with linux-next as of today on s390 I see tons of messages like
> 
> [   20.536664] page dumped because: has_unmovable_pages
> [   20.536792] page:000003d081ff4080 count:1 mapcount:0 mapping:000000008ff88600 index:0x0 compound_mapcount: 0
> [   20.536794] flags: 0x3fffe0000010200(slab|head)
> [   20.536795] raw: 03fffe0000010200 0000000000000100 0000000000000200 000000008ff88600
> [   20.536796] raw: 0000000000000000 0020004100000000 ffffffff00000001 0000000000000000
> [   20.536797] page dumped because: has_unmovable_pages
> [   20.536814] page:000003d0823b0000 count:1 mapcount:0 mapping:0000000000000000 index:0x0
> [   20.536815] flags: 0x7fffe0000000000()
> [   20.536817] raw: 07fffe0000000000 0000000000000100 0000000000000200 0000000000000000
> [   20.536818] raw: 0000000000000000 0000000000000000 ffffffff00000001 0000000000000000
> 
> bisect points to b323c049a999 ("mm, memory_hotplug: be more verbose for memory offline failures")
> which is the first commit with which the messages appear.

I would bet this is CMA allocator. How much is tons? Maybe we want a
rate limit or the other user is not really interested in them at all?
-- 
Michal Hocko
SUSE Labs
