Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id CBFF64402F0
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 13:10:04 -0500 (EST)
Received: by pfu207 with SMTP id 207so68481170pfu.2
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 10:10:04 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id r134si3410739pfr.18.2015.12.07.10.10.04
        for <linux-mm@kvack.org>;
        Mon, 07 Dec 2015 10:10:04 -0800 (PST)
Subject: Re: [Intel-gfx] [PATCH v2 1/2] mm: Export nr_swap_pages
References: <1449244734-25733-1-git-send-email-chris@chris-wilson.co.uk>
 <20151207134812.GA20782@dhcp22.suse.cz> <20151207164831.GA7256@cmpxchg.org>
From: Dave Gordon <david.s.gordon@intel.com>
Message-ID: <5665CB78.7000106@intel.com>
Date: Mon, 7 Dec 2015 18:10:00 +0000
MIME-Version: 1.0
In-Reply-To: <20151207164831.GA7256@cmpxchg.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, "Goel, Akash" <akash.goel@intel.com>

On 07/12/15 16:48, Johannes Weiner wrote:
> On Mon, Dec 07, 2015 at 02:48:12PM +0100, Michal Hocko wrote:
>> On Fri 04-12-15 15:58:53, Chris Wilson wrote:
>>> Some modules, like i915.ko, use swappable objects and may try to swap
>>> them out under memory pressure (via the shrinker). Before doing so, they
>>> want to check using get_nr_swap_pages() to see if any swap space is
>>> available as otherwise they will waste time purging the object from the
>>> device without recovering any memory for the system. This requires the
>>> nr_swap_pages counter to be exported to the modules.
>>
>> I guess it should be sufficient to change get_nr_swap_pages into a real
>> function and export it rather than giving the access to the counter
>> directly?
>
> What do you mean by "sufficient"? That is actually more work.
>
> It should be sufficient to just export the counter.
> _______________________________________________

Exporting random uncontrolled variables from the kernel to loaded 
modules is not really considered best practice. It would be preferable 
to provide an accessor function - which is just what the declaration 
says we have; the implementation as a static inline (and/or macro) is 
what causes the problem here.

.Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
