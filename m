Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id F292B6B30CD
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 08:12:41 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id y35so5782776edb.5
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 05:12:41 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b18si877223edc.268.2018.11.23.05.12.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 05:12:40 -0800 (PST)
Date: Fri, 23 Nov 2018 14:12:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/4] mm, memory_hotplug: allocate memmap from
 hotadded memory
Message-ID: <20181123131237.GO8625@dhcp22.suse.cz>
References: <20181116101222.16581-1-osalvador@suse.com>
 <2571308d-0460-e8b9-ad40-75d6b13b2d09@redhat.com>
 <20181123115519.2dnzscmmgv63fdub@d104.suse.de>
 <20181123124228.GI8625@dhcp22.suse.cz>
 <4fd2e8fe-a85d-af96-ee04-8ddfd1fbe79d@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4fd2e8fe-a85d-af96-ee04-8ddfd1fbe79d@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.com>, linux-mm@kvack.org, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, arunks@codeaurora.org, bhe@redhat.com, dan.j.williams@intel.com, Pavel.Tatashin@microsoft.com, Jonathan.Cameron@huawei.com, jglisse@redhat.com, linux-kernel@vger.kernel.org

On Fri 23-11-18 13:51:57, David Hildenbrand wrote:
> On 23.11.18 13:42, Michal Hocko wrote:
> > On Fri 23-11-18 12:55:41, Oscar Salvador wrote:
[...]
> >> It is not memory that the system can use.
> > 
> > same as bootmem ;)
> 
> Fair enough, just saying that it represents a change :)
> 
> (but people also already complained if their VM has XGB but they don't
> see actual XGB as total memory e.g. due to the crash kernel size)

I can imagine. I have seen many "where's my memory dude" questions... We
have so many unaccounted usages that it is simply impossible to see the
full picture of where the memory is consumed. The current implementation
would account memmaps in unreclaimable slabs but you still do not know
how much was spent for it...
 
> >> I also guess that if there is a strong opinion on this, we could create
> >> a counter, something like NR_VMEMMAP_PAGES, and show it under /proc/meminfo.
> > 
> > Do we really have to? Isn't the number quite obvious from the size of
> > the hotpluged memory?
> 
> At least the size of vmmaps cannot reliably calculated from "MemTotal" .
> But maybe based on something else. (there, it is indeed obvious)

Everybody knows the struct page size obviously :p and the rest is a
simple exercise. But more seriously, I see what you are saying. We do
not have a good counter now and the patch doesn't improve that. But I
guess this is a separate discussion.

-- 
Michal Hocko
SUSE Labs
