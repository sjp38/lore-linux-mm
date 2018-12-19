Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id CCA188E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 09:12:37 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c3so16666178eda.3
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 06:12:37 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p37si4603717edc.272.2018.12.19.06.12.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 06:12:36 -0800 (PST)
Date: Wed, 19 Dec 2018 15:12:35 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2] mm, page_isolation: remove drain_all_pages() in
 set_migratetype_isolate()
Message-ID: <20181219141235.GM5758@dhcp22.suse.cz>
References: <20181214023912.77474-1-richard.weiyang@gmail.com>
 <20181218204656.4297-1-richard.weiyang@gmail.com>
 <20181219095110.GB5758@dhcp22.suse.cz>
 <20181219132934.65vymftfgd2atcxa@master>
 <20181219134056.GL5758@dhcp22.suse.cz>
 <20181219135635.yloh2sn4uskzpy7g@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219135635.yloh2sn4uskzpy7g@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, osalvador@suse.de, david@redhat.com

On Wed 19-12-18 13:56:35, Wei Yang wrote:
> On Wed, Dec 19, 2018 at 02:40:56PM +0100, Michal Hocko wrote:
> >On Wed 19-12-18 13:29:34, Wei Yang wrote:
[...]
> >> As the comment mentioned, in current implementation the range must be in
> >> one zone.
> >
> >I do not see anything like that documented for set_migratetype_isolate.
> 
> The comment is not on set_migratetype_isolate, but for its two
> (grandparent) callers:
> 
>    __offline_pages
>    alloc_contig_range

But those are consumers while the main api here is
start_isolate_page_range. What happens if we grow a new user?
Go over the same problems? See the difference?

Please try to look at these things from a higher level. We really do not
want micro optimise on behalf of a sane API. Unless there is a very good
reason to do that - e.g. when the performance difference is really huge.
-- 
Michal Hocko
SUSE Labs
