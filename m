Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 429496B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 07:17:06 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y15so1238545wrc.6
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 04:17:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j3si1484842wmh.121.2017.12.13.04.17.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Dec 2017 04:17:05 -0800 (PST)
Date: Wed, 13 Dec 2017 13:17:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/3] mm, numa: rework do_pages_move
Message-ID: <20171213121703.GD25185@dhcp22.suse.cz>
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
 <20171208161559.27313-2-mhocko@kernel.org>
 <20171213120733.umeb7rylswl7chi5@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171213120733.umeb7rylswl7chi5@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 13-12-17 15:07:33, Kirill A. Shutemov wrote:
[...]
> The approach looks fine to me.
> 
> But patch is rather large and hard to review. And how git mixed add/remove
> lines doesn't help too. Any chance to split it up further?

I was trying to do that but this is a drop in replacement so it is quite
hard to do in smaller pieces. I've already put the allocation callback
cleanup into a separate one but this is about all that I figured how to
split. If you have any suggestions I am willing to try them out.

> One nitpick: I don't think 'chunk' terminology should go away with the
> patch.

Not sure what you mean here. I have kept chunk_start, chunk_node, so I
am not really changing that terminology

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
