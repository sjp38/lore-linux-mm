Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 622806B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 01:59:22 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v82so25987525pgb.5
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 22:59:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h8si9647411plk.815.2017.09.12.22.59.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Sep 2017 22:59:21 -0700 (PDT)
Date: Wed, 13 Sep 2017 07:59:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memory_hotplug: fix wrong casting for
 __remove_section()
Message-ID: <20170913055914.3npcxevhdwghcmdd@dhcp22.suse.cz>
References: <51a59ec3-e7ba-2562-1917-036b8181092c@gmail.com>
 <20170912124952.uraxdt5bgl25zhf7@dhcp22.suse.cz>
 <587bdecd-2584-21be-94b8-61b427f1b0e8@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <587bdecd-2584-21be-94b8-61b427f1b0e8@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, qiuxishi@huawei.com, arbab@linux.vnet.ibm.com, Vlastimil Babka <vbabka@suse.cz>

On Tue 12-09-17 13:05:39, YASUAKI ISHIMATSU wrote:
> Hi Michal,
> 
> Thanks you for reviewing my patch.
> 
> On 09/12/2017 08:49 AM, Michal Hocko wrote:
> > On Fri 08-09-17 16:43:04, YASUAKI ISHIMATSU wrote:
> >> __remove_section() calls __remove_zone() to shrink zone and pgdat.
> >> But due to wrong castings, __remvoe_zone() cannot shrink zone
> >> and pgdat correctly if pfn is over 0xffffffff.
> >>
> >> So the patch fixes the following 3 wrong castings.
> >>
> >>   1. find_smallest_section_pfn() returns 0 or start_pfn which defined
> >>      as unsigned long. But the function always returns 32bit value
> >>      since the function is defined as int.
> >>
> >>   2. find_biggest_section_pfn() returns 0 or pfn which defined as
> >>      unsigned long. the function always returns 32bit value
> >>      since the function is defined as int.
> > 
> > this is indeed wrong. Pfns over would be really broken 15TB. Not that
> > unrealistic these days
> 
> Why 15TB?

0xffffffff>>28

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
