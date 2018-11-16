Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E594F6B0902
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 06:26:08 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id m1-v6so16703728plb.13
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 03:26:08 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a20si6685457pgw.195.2018.11.16.03.26.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 03:26:07 -0800 (PST)
Date: Fri, 16 Nov 2018 12:26:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: use managed_zone() for more exact check in zone
 iteration
Message-ID: <20181116112603.GI14706@dhcp22.suse.cz>
References: <20181114235040.36180-1-richard.weiyang@gmail.com>
 <20181115133735.bb0313ec9293c415d08be550@linux-foundation.org>
 <20181116095720.GE14706@dhcp22.suse.cz>
 <1542366304.3020.15.camel@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1542366304.3020.15.camel@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador <osalvador@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 16-11-18 12:05:04, osalvador wrote:
> On Fri, 2018-11-16 at 10:57 +0100, Michal Hocko wrote:
[...]
> > E.g. memory hotplug decreases both managed and present counters. I
> > am actually not sure that is 100% correct (put on my TODO list to
> > check). There is no consistency in that regards.
> 
> We can only offline non-reserved pages (so, managed pages).

Yes

> Since present pages holds reserved_pages + managed_pages, decreasing
> both should be fine unless I am mistaken.

Well, present_pages is defined as "physical pages existing within the zone"
and those pages are still existing but they are offline. But as I've
said I have to think about it some more
-- 
Michal Hocko
SUSE Labs
