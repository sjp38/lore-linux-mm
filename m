Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id AE57D6B0006
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 02:48:24 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id z72-v6so7854702ede.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 23:48:24 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s20-v6si6747461edr.396.2018.11.13.23.48.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 23:48:23 -0800 (PST)
Date: Wed, 14 Nov 2018 08:48:21 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, page_alloc: skip zone who has no managed_pages in
 calculate_totalreserve_pages()
Message-ID: <20181114074821.GE23419@dhcp22.suse.cz>
References: <20181112071404.13620-1-richard.weiyang@gmail.com>
 <20181112080926.GA14987@dhcp22.suse.cz>
 <20181112142641.6oxn4fv4pocm7fmt@master>
 <20181112144020.GC14987@dhcp22.suse.cz>
 <20181113013942.zgixlky4ojbzikbd@master>
 <20181113080834.GK15120@dhcp22.suse.cz>
 <20181113081644.giu5vxhsfqjqlexh@master>
 <20181113090758.GL15120@dhcp22.suse.cz>
 <20181114074341.r53rukmj25ydvaqi@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114074341.r53rukmj25ydvaqi@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org

On Wed 14-11-18 07:43:41, Wei Yang wrote:
> On Tue, Nov 13, 2018 at 10:07:58AM +0100, Michal Hocko wrote:
> >On Tue 13-11-18 08:16:44, Wei Yang wrote:
> >
> >No, I believe we want all three of them. But reviewing
> >for_each_populated_zone users and explicit checks for present/managed
> >pages and unify them would be a step forward both a more optimal code
> >and more maintainable code. I haven't checked but
> >for_each_populated_zone would seem like a proper user for managed page
> >counter. But that really requires to review all current users.
> >
> 
> To sync with your purpose, I searched the user of
> for_each_populated_zone() and replace it with a new loop
> for_each_managed_zone().

I do not think we really want a new iterator. Is there any users of
for_each_populated_zone which would be interested in something else than
managed pages?
-- 
Michal Hocko
SUSE Labs
