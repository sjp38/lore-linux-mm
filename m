Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5436B006E
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 17:26:41 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id h11so182582wiw.3
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 14:26:41 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id mw9si16629482wib.47.2015.01.12.14.26.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 14:26:40 -0800 (PST)
Date: Mon, 12 Jan 2015 17:26:34 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm 2/2] mm: vmscan: init reclaim_state in
 do_try_to_free_pages
Message-ID: <20150112222634.GC25609@phnom.home.cmpxchg.org>
References: <880700a513472a8b86fd3100aef674322c66c68e.1421054931.git.vdavydov@parallels.com>
 <20a8ae66cc2b9412b1bf81c0a46f4e8c737aa537.1421054931.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20a8ae66cc2b9412b1bf81c0a46f4e8c737aa537.1421054931.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 12, 2015 at 12:30:38PM +0300, Vladimir Davydov wrote:
> All users of do_try_to_free_pages() want to have current->reclaim_state
> set in order to account reclaimed slab pages. So instead of duplicating
> the reclaim_state initialization code in each call site, let's do it
> directly in do_try_to_free_pages().

Couldn't this be contained in shrink_slab() directly?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
