Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B6A7B6B4DC6
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 11:02:46 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e29so12889365ede.19
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 08:02:46 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 28 Nov 2018 17:02:42 +0100
From: osalvador@suse.de
Subject: Re: [PATCH v2 5/5] mm, memory_hotplug: Refactor
 shrink_zone/pgdat_span
In-Reply-To: <20181128155030.GM6923@dhcp22.suse.cz>
References: <20181127162005.15833-1-osalvador@suse.de>
 <20181127162005.15833-6-osalvador@suse.de>
 <20181128065018.GG6923@dhcp22.suse.cz> <1543388866.2920.5.camel@suse.de>
 <20181128101426.GH6923@dhcp22.suse.cz>
 <ddee6546c35aaada14b196c83f5205e0@suse.de>
 <20181128123120.GJ6923@dhcp22.suse.cz>
 <ddd7474af7162dcfa3ce328587b4a916@suse.de>
 <20181128130824.GL6923@dhcp22.suse.cz>
 <bac2ab7c71bf8b14535a8d1031e219d9@suse.de>
 <20181128155030.GM6923@dhcp22.suse.cz>
Message-ID: <ccb78b1cf7879017f52f1803956f5e91@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, linux-mm@kvack.org, owner-linux-mm@kvack.org

>> Maybe that is fine, I am not sure.
>> Sorry for looping here, but it is being difficult for me to grasp it.
> 
> OK, so let me try again. What is the difference for a pfn walker to
> start at an offline pfn start from any other offlined section withing a
> zone boundary? I believe there is none because the pfn walker needs to
> skip over offline pfns anyway whether they start at a zone boundary or
> not.

If the pfn walker in question skips over "invalid" (not online) pfn, 
then we
are fine I guess.
But we need to make sure that this is the case, and that we do not have 
someone
relaying on zone_start_pfn and trusting it blindly.

I will go through the code and check all cases to be sure that this is 
not the case.
If that is the case, then I am fine with getting rid of the shrink code.

Thanks for explanations ;-)
