Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 394656B08D7
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 04:57:22 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id z10so5887550edz.15
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 01:57:22 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cb13-v6si1326282ejb.102.2018.11.16.01.57.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 01:57:20 -0800 (PST)
Date: Fri, 16 Nov 2018 10:57:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: use managed_zone() for more exact check in zone
 iteration
Message-ID: <20181116095720.GE14706@dhcp22.suse.cz>
References: <20181114235040.36180-1-richard.weiyang@gmail.com>
 <20181115133735.bb0313ec9293c415d08be550@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115133735.bb0313ec9293c415d08be550@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 15-11-18 13:37:35, Andrew Morton wrote:
[...]
> Worse, the situations in which managed_zone() != populated_zone() are
> rare(?), so it will take a long time for problems to be discovered, I
> expect.

We would basically have to deplete the whole zone by the bootmem
allocator or pull out all pages from the page allocator. E.g. memory
hotplug decreases both managed and present counters. I am actually not
sure that is 100% correct (put on my TODO list to check). There is no
consistency in that regards.

That being said, I will review the patch (today hopefully) but
fundamentally most users should indeed care about managed pages when
iterating zones with memory. There should be a good reason why they
might want to look at reserved pages.

-- 
Michal Hocko
SUSE Labs
