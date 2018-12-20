Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B24AB8E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 08:49:02 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id z10so2400293edz.15
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 05:49:02 -0800 (PST)
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id c1-v6si3569990ejf.257.2018.12.20.05.49.01
        for <linux-mm@kvack.org>;
        Thu, 20 Dec 2018 05:49:01 -0800 (PST)
Date: Thu, 20 Dec 2018 14:49:00 +0100
From: Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v2] mm, page_alloc: Fix has_unmovable_pages for HugePages
Message-ID: <20181220134900.zk4djsoenspltdx6@d104.suse.de>
References: <20181217225113.17864-1-osalvador@suse.de>
 <20181219142528.yx6ravdyzcqp5wtd@master>
 <20181219233914.2fxe26pih26ifvmt@d104.suse.de>
 <20181220091228.GB14234@dhcp22.suse.cz>
 <20181220124925.itwuuacgztpgsk7s@d104.suse.de>
 <20181220130857.yrzv5wzmiw7jbycb@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181220130857.yrzv5wzmiw7jbycb@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, vbabka@suse.cz, pavel.tatashin@microsoft.com, rppt@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 20, 2018 at 01:08:57PM +0000, Wei Yang wrote:
> This complicated the calculation. 
> 
> The original code is correct.
> 
> iter = round_up(iter + 1, 1<<compound_order(head)) - 1;

I think it would be correct if we know for sure that everthing
is pageblock aligned.
Because 2mb-hugepages fit in one pageblock, and 1gb-hugepages expands
512 pageblocks exactly.

But I think that it is better if we leave the assumption behind.
-- 
Oscar Salvador
SUSE L3
