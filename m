Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 697556B0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 21:51:42 -0500 (EST)
Received: by mail-vc0-f178.google.com with SMTP id m8so4022342vcd.9
        for <linux-mm@kvack.org>; Mon, 18 Feb 2013 18:51:41 -0800 (PST)
Message-ID: <5122E8C0.4020404@gmail.com>
Date: Mon, 18 Feb 2013 21:51:44 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [Lsf-pc] [LSF/MM TOPIC][ATTEND] a few topics I'd like to discuss
References: <CAHGf_=rb0t4gbm0Egw9D3RUuwbgL8U6hPwBwS46C27mgAvJp0g@mail.gmail.com> <20130218145018.GJ4365@suse.de>
In-Reply-To: <20130218145018.GJ4365@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

>> * Hugepage migration ? Currently, hugepage is not migratable and can?t
>> use pages in ZONE_MOVABLE.  It is not happy from point of CMA/hotplug
>> view.
>>
> 
> migrate_huge_page() ?
> 
> It's also possible to allocate hugetlbfs pages in ZONE_MOVABLE but must
> be enabled via /proc/sys/vm/hugepages_treat_as_movable.

Oops. I missed that. Sorry for noise.

But but... I wonder why this knob is disabled by default. I don't think anybody
get a benefit form current default.


>> * Remove ZONE_MOVABLE ?Very long term goal. Maybe not suitable in this year.
> 
> Whatever about removing it totally I would like to see node memory hot-remove
> not depending on ZONE_MOVABLE.

Yup. I also think so. the first target is page table and icache/dcache because they
use a lot of memory. second step is to implement slab migration callback likes shrinker_slab. etc.
it is very long term story.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
