Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id AD71A6B0931
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 06:05:22 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id z7-v6so11747610edh.19
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 03:05:22 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y11si5151229edw.172.2018.11.16.03.05.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 03:05:21 -0800 (PST)
Message-ID: <1542366304.3020.15.camel@suse.de>
Subject: Re: [PATCH] mm: use managed_zone() for more exact check in zone
 iteration
From: osalvador <osalvador@suse.de>
Date: Fri, 16 Nov 2018 12:05:04 +0100
In-Reply-To: <20181116095720.GE14706@dhcp22.suse.cz>
References: <20181114235040.36180-1-richard.weiyang@gmail.com>
	 <20181115133735.bb0313ec9293c415d08be550@linux-foundation.org>
	 <20181116095720.GE14706@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2018-11-16 at 10:57 +0100, Michal Hocko wrote:
> On Thu 15-11-18 13:37:35, Andrew Morton wrote:
> [...]
> > Worse, the situations in which managed_zone() != populated_zone()
> > are
> > rare(?), so it will take a long time for problems to be discovered,
> > I
> > expect.
> 
> We would basically have to deplete the whole zone by the bootmem
> allocator or pull out all pages from the page allocator. E.g. memory
> hotplug decreases both managed and present counters. I am actually
> not
> sure that is 100% correct (put on my TODO list to check). There is no
> consistency in that regards.

We can only offline non-reserved pages (so, managed pages).
Since present pages holds reserved_pages + managed_pages, decreasing
both should be fine unless I am mistaken.

Oscar Salvador
