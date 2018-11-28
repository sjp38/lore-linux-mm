Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 974A06B4BAE
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 02:08:05 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id w15so12062100edl.21
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 23:08:05 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v4si2267644ede.46.2018.11.27.23.08.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 23:08:04 -0800 (PST)
Message-ID: <1543388866.2920.5.camel@suse.de>
Subject: Re: [PATCH v2 5/5] mm, memory_hotplug: Refactor
 shrink_zone/pgdat_span
From: Oscar Salvador <osalvador@suse.de>
Date: Wed, 28 Nov 2018 08:07:46 +0100
In-Reply-To: <20181128065018.GG6923@dhcp22.suse.cz>
References: <20181127162005.15833-1-osalvador@suse.de>
	 <20181127162005.15833-6-osalvador@suse.de>
	 <20181128065018.GG6923@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, linux-mm@kvack.org

On Wed, 2018-11-28 at 07:50 +0100, Michal Hocko wrote:
> 
> I didn't get to read through this whole series but one thing that is
> on
> my todo list for a long time is to remove all this stuff. I do not
> think
> we really want to simplify it when there shouldn't be any real reason
> to
> have it around at all. Why do we need to shrink zone/node at all?
> 
> Now that we can override and assign memory to both normal na movable
> zones I think we should be good to remove shrinking.

I feel like I am missing a piece of obvious information here.
Right now, we shrink zone/node to decrease spanned pages.
I thought this was done for consistency, and in case of the node, in
try_offline_node we use the spanned pages to go through all sections
to check whether the node can be removed or not.

>From your comment, I understand that we do not really care about
spanned pages. Why?
Could you please expand on that?

And if we remove it, would not this give to a user "bad"/confusing
information when looking at /proc/zoneinfo?


Thanks
-- 
Oscar Salvador
SUSE L3
