Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D0BE38E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:23:06 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e29so2844216ede.19
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 08:23:06 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y3si1408368edu.364.2018.12.20.08.23.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 08:23:05 -0800 (PST)
Date: Thu, 20 Dec 2018 17:23:02 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2] mm, page_isolation: remove drain_all_pages() in
 set_migratetype_isolate()
Message-ID: <20181220162302.GA8131@dhcp22.suse.cz>
References: <20181214023912.77474-1-richard.weiyang@gmail.com>
 <20181218204656.4297-1-richard.weiyang@gmail.com>
 <20181219095110.GB5758@dhcp22.suse.cz>
 <20181219095715.73x6hvmndyku2rec@d104.suse.de>
 <20181219135307.bjd6rckseczpfeae@master>
 <20181219141343.GN5758@dhcp22.suse.cz>
 <20181219143327.wdsufbn2oh6ygnne@master>
 <20181219143927.GO5758@dhcp22.suse.cz>
 <20181220155803.m4ebl6euq2yq4ezu@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181220155803.m4ebl6euq2yq4ezu@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org, akpm@linux-foundation.org, david@redhat.com

On Thu 20-12-18 15:58:03, Wei Yang wrote:
> On Wed, Dec 19, 2018 at 03:39:27PM +0100, Michal Hocko wrote:
> >On Wed 19-12-18 14:33:27, Wei Yang wrote:
> >[...]
> >> Then I am confused about the objection to this patch. Finally, we drain
> >> all the pages in pcp list and the range is isolated.
> >
> >Please read my emails more carefully. As I've said, the only reason to
> >do care about draining is to remove it from where it doesn't belong.
> 
> I go through the thread again and classify two main opinions from you
> and Oscar.
> 
> 1) We can still allocate pages in a specific range from pcp list even we
>    have already isolate this range.
> 2) We shouldn't rely on caller to drain pages and
>    set_migratetype_isolate() may handle a range cross zones.
> 
> I understand the second one and agree it is not proper to rely on caller
> and make the assumption on range for set_migratetype_isolate().
> 
> My confusion comes from the first one. As you and Oscar both mentioned
> this and Oscar said "I had the same fear", this makes me think current
> implementation is buggy. But your following reply said this is not. This
> means current approach works fine.
> 
> If the above understanding is correct, and combining with previous
> discussion, the improvement we can do is to remove the drain_all_pages()
> in __offline_pages()/alloc_contig_range(). By doing so, the pcp list
> drain doesn't rely on caller and the isolation/drain on each pageblock
> ensures pcp list will not contain any page in this range now and future.
> This imply the drain_all_pages() in
> __offline_pages()/alloc_contig_range() is not necessary.
> 
> Is my understanding correct?

Yes

-- 
Michal Hocko
SUSE Labs
