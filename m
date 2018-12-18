Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F17EC8E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 18:29:52 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c3so14409215eda.3
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 15:29:52 -0800 (PST)
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id r23-v6si1483086ejb.173.2018.12.18.15.29.51
        for <linux-mm@kvack.org>;
        Tue, 18 Dec 2018 15:29:51 -0800 (PST)
Date: Wed, 19 Dec 2018 00:29:50 +0100
From: Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v2] mm, page_isolation: remove drain_all_pages() in
 set_migratetype_isolate()
Message-ID: <20181218232950.gsgyhmdh4zvbeah6@d104.suse.de>
References: <20181214023912.77474-1-richard.weiyang@gmail.com>
 <20181218204656.4297-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181218204656.4297-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.com, david@redhat.com

On Wed, Dec 19, 2018 at 04:46:56AM +0800, Wei Yang wrote:
> Below is a brief call flow for __offline_pages() and
> alloc_contig_range():
> 
>   __offline_pages()/alloc_contig_range()
>       start_isolate_page_range()
>           set_migratetype_isolate()
>               drain_all_pages()
>       drain_all_pages()
> 
> Current logic is: isolate and drain pcp list for each pageblock and
> drain pcp list again. This is not necessary and we could just drain pcp
> list once after isolate this whole range.
> 
> The reason is start_isolate_page_range() will set the migrate type of
> a range to MIGRATE_ISOLATE. After doing so, this range will never be
> allocated from Buddy, neither to a real user nor to pcp list.
> 
> Since drain_all_pages() is zone based, by reduce times of
> drain_all_pages() also reduce some contention on this particular zone.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

It is a bit late and I hope I did not miss anything, but looks good to me.

Reviewed-by: Oscar Salvador <osalvador@suse.de>

Thanks!
-- 
Oscar Salvador
SUSE L3
