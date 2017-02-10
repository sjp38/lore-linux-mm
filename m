Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0CB416B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 04:15:03 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id o16so11377526wra.2
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 01:15:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u88si427715wma.25.2017.02.10.01.15.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Feb 2017 01:15:01 -0800 (PST)
Date: Fri, 10 Feb 2017 10:15:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3 staging-next] android: Collect statistics from
 lowmemorykiller
Message-ID: <20170210091459.GF10893@dhcp22.suse.cz>
References: <9febd4f7-a0a7-5f52-e67b-df3163814ac5@sonymobile.com>
 <20170209192640.GC31906@dhcp22.suse.cz>
 <20170209200737.GB11098@kroah.com>
 <20170209205407.GF31906@dhcp22.suse.cz>
 <845d420f-dd26-fb48-c8ef-10ca1995daf8@sonymobile.com>
 <20170210075149.GA17166@kroah.com>
 <20170210075949.GB10893@dhcp22.suse.cz>
 <e836d455-2c12-d3a9-81f8-384194428c5f@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e836d455-2c12-d3a9-81f8-384194428c5f@sonymobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sonymobile.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Riley Andrews <riandrews@android.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri 10-02-17 10:05:34, peter enderborg wrote:
> On 02/10/2017 08:59 AM, Michal Hocko wrote:
[...]
> > The approach was wrong from the day 1. Abusing slab shrinkers
> > is just a bad place to stick this logic. This all belongs to the
> > userspace.
>
> But now it is there and we have to stick with it.

It is also adding maintenance cost. Just have a look at the git log and
check how many patches were just a result of the core changes which
needed a sync.

I seriously doubt that any of the android devices can run natively on
the Vanilla kernel so insisting on keeping this code in staging doesn't
give much sense to me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
