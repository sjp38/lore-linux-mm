Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0956B0003
	for <linux-mm@kvack.org>; Sun, 21 Oct 2018 08:12:58 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l51-v6so23032507edc.14
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 05:12:58 -0700 (PDT)
Received: from outbound-smtp13.blacknight.com (outbound-smtp13.blacknight.com. [46.22.139.230])
        by mx.google.com with ESMTPS id g27-v6si11746822edj.72.2018.10.21.05.12.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Oct 2018 05:12:56 -0700 (PDT)
Received: from mail.blacknight.com (unknown [81.17.254.11])
	by outbound-smtp13.blacknight.com (Postfix) with ESMTPS id 34E4B1C2445
	for <linux-mm@kvack.org>; Sun, 21 Oct 2018 13:12:56 +0100 (IST)
Date: Sun, 21 Oct 2018 13:12:51 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC] put page to pcp->lists[] tail if it is not on the same node
Message-ID: <20181021121251.GA8041@techsingularity.net>
References: <20181019043303.s5axhjfb2v2lzsr3@master>
 <20181019083818.GQ5819@techsingularity.net>
 <20181020163318.72oqszgdtqfafycu@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181020163318.72oqszgdtqfafycu@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: willy@infradead.org, mhocko@suse.com, linux-mm@kvack.org, akpm@linux-foundation.org

On Sat, Oct 20, 2018 at 04:33:18PM +0000, Wei Yang wrote:
> >Pages from remote nodes are not placed on local lists. Even in the slab
> >context, such objects are placed on alien caches which have special
> >handling.
> >
> 
> Hmm... I am not sure get your point correctly.
> 

The point is that one list should not contain a mix of pages belonging to
different nodes or zones or it'll result in unexpected behaviour. If you
are just shuffling the ordering of pages in the list, it needs justification
as to why that makes sense.

-- 
Mel Gorman
SUSE Labs
