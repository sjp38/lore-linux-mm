Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id D3B33280271
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 04:14:48 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id d4so2808552plr.8
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 01:14:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r16si337336pgu.173.2018.01.05.01.14.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Jan 2018 01:14:47 -0800 (PST)
Date: Fri, 5 Jan 2018 10:14:43 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm, numa: rework do_pages_move
Message-ID: <20180105091443.GJ2801@dhcp22.suse.cz>
References: <20180103082555.14592-1-mhocko@kernel.org>
 <20180103082555.14592-2-mhocko@kernel.org>
 <db9b9752-a106-a3af-12f5-9894adee7ba7@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <db9b9752-a106-a3af-12f5-9894adee7ba7@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrea Reale <ar@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 05-01-18 09:22:22, Anshuman Khandual wrote:
[...]
> Hi Michal,
> 
> After slightly modifying your test case (like fixing the page size for
> powerpc and just doing simple migration from node 0 to 8 instead of the
> interleaving), I tried to measure the migration speed with and without
> the patches on mainline. Its interesting....
> 
> 					10000 pages | 100000 pages
> 					--------------------------
> Mainline				165 ms		1674 ms
> Mainline + first patch (move_pages)	191 ms		1952 ms
> Mainline + all three patches		146 ms		1469 ms
> 
> Though overall it gives performance improvement, some how it slows
> down migration after the first patch. Will look into this further.

What are you measuring actually? All pages migrated to the same node?
Do you have any profiles? How stable are the results?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
