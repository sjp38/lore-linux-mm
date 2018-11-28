Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7A2116B4D18
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 08:09:52 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id v4so12134609edm.18
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 05:09:52 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 28 Nov 2018 14:09:50 +0100
From: osalvador@suse.de
Subject: Re: [PATCH v2 5/5] mm, memory_hotplug: Refactor
 shrink_zone/pgdat_span
In-Reply-To: <ddd7474af7162dcfa3ce328587b4a916@suse.de>
References: <20181127162005.15833-1-osalvador@suse.de>
 <20181127162005.15833-6-osalvador@suse.de>
 <20181128065018.GG6923@dhcp22.suse.cz> <1543388866.2920.5.camel@suse.de>
 <20181128101426.GH6923@dhcp22.suse.cz>
 <ddee6546c35aaada14b196c83f5205e0@suse.de>
 <20181128123120.GJ6923@dhcp22.suse.cz>
 <ddd7474af7162dcfa3ce328587b4a916@suse.de>
Message-ID: <847bd02df77b33f3c42d2482674a6d25@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, linux-mm@kvack.org, owner-linux-mm@kvack.org

On 2018-11-28 13:51, osalvador@suse.de wrote:
>> yep. Or when we extend a zone/node via hotplug.
>> 
>>> The only thing I am worried about is that by doing that, the system
>>> will account spanned_pages incorrectly.
>> 
>> As long as end_pfn - start_pfn matches then I do not see what would be
>> incorrect.

Or unless I misunderstood you, and you would like to instead of having
this shrink code, re-use resize_zone/pgdat_range to adjust
end_pfn and start_pfn when offlining first or last sections.
