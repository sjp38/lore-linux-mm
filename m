Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 667DB8E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 06:30:32 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id z17-v6so12176898wrr.16
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 03:30:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q1-v6sor4096891wrw.17.2018.09.21.03.30.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Sep 2018 03:30:31 -0700 (PDT)
Date: Fri, 21 Sep 2018 12:30:29 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH 4/5] mm/memory_hotplug: Simplify
 node_states_check_changes_online
Message-ID: <20180921103029.GA15555@techadventures.net>
References: <20180919100819.25518-1-osalvador@techadventures.net>
 <20180919100819.25518-5-osalvador@techadventures.net>
 <71676241-8aa5-2b58-b2fa-706bf21b9cfb@microsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <71676241-8aa5-2b58-b2fa-706bf21b9cfb@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "david@redhat.com" <david@redhat.com>, "Jonathan.Cameron@huawei.com" <Jonathan.Cameron@huawei.com>, "yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>, "malat@debian.org" <malat@debian.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oscar Salvador <osalvador@suse.de>

On Fri, Sep 21, 2018 at 12:15:53AM +0000, Pasha Tatashin wrote:

Hi Pavel,

> But what if that changes, will this function need to change as well?

That's true.

> Should not we have:
> 			else
> 				arg->status_change_nid_high = -1; ?
> 
> > +		} else
> > +			arg->status_change_nid_high = -1;

Yes, I forgot about that else.

> I think it is simpler to have something like this:
> 
>         int nid = zone_to_nid(zone);
> 
>         arg->status_change_nid_high = -1;
>         arg->status_change_nid = -1;
>         arg->status_change_nid = -1;
> 
>         if (!node_state(nid, N_MEMORY))
>                 arg->status_change_nid = nid; 
>         if (zone_idx(zone) <= ZONE_NORMAL && !node_state(nid, N_NORMAL_MEMORY))
>                 arg->status_change_nid_normal = nid; 
> #ifdef CONFIG_HIGHMEM
>         if (zone_idx(zone) <= N_HIGH_MEMORY && !node_state(nid, N_HIGH_MEMORY))
>                 arg->status_change_nid_high = nid; 
> #endif

I can write it that way, I also like it more.

I will send it in V2.

Thanks for reviewing it!
-- 
Oscar Salvador
SUSE L3
